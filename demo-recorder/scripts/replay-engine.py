#!/usr/bin/env python3
"""Hyprland demo replay engine.

Reads a JSON demo script and executes actions via hyprctl/ydotool.
Runs inside the demo VM after Hyprland has started.

Action types:
  { "wait": 0.5 }                        - sleep in seconds
  { "exec": "foot" }                     - launch app via hyprctl dispatch exec
  { "dispatch": "..." }                  - arbitrary hyprctl dispatch
  { "workspace": 2 }                     - switch workspace
  { "layout": "..." }                    - predefined layout
  { "move": [0.4, 0.6] }                - mouse move (relative 0.0-1.0)
  { "click": 1 }                         - 1=left, 2=middle, 3=right
  { "key": "SUPER+RETURN" }             - keyboard shortcut
  { "type": "hello" }                    - type text
  { "screenshot": "/recordings/s.png" } - capture screenshot via grim
"""

import json
import subprocess
import sys
import time


# Predefined window layouts built via hyprctl dispatch
FOOT_CMD = "foot --window-size-pixels=1600x900"

LAYOUTS = {
    "terminal-left-browser-right": [
        ("exec", FOOT_CMD),
        ("sleep", 1.5),
        ("exec", "firefox"),
        ("sleep", 2.0),
        ("dispatch", "movefocus l"),
        ("dispatch", "resizeactive exact 960 0"),
    ],
    "terminal-fullscreen": [
        ("exec", FOOT_CMD),
        ("sleep", 1.0),
        ("dispatch", "fullscreen 1"),
    ],
    "two-terminals": [
        ("exec", FOOT_CMD),
        ("sleep", 1.0),
        ("exec", FOOT_CMD),
        ("sleep", 1.0),
        ("dispatch", "togglesplit"),
    ],
    "terminal-only": [
        ("exec", FOOT_CMD),
        ("sleep", 1.0),
    ],
}

# Human-readable key names to wtype (XKB) key names
# wtype uses XKB keysym names (lowercase)
WTYPE_KEY_MAP = {
    "SUPER": "super_l",
    "META": "super_l",
    "WIN": "super_l",
    "CTRL": "ctrl_l",
    "CONTROL": "ctrl_l",
    "ALT": "alt_l",
    "SHIFT": "shift_l",
    "RETURN": "return",
    "ENTER": "return",
    "ESC": "escape",
    "ESCAPE": "escape",
    "TAB": "tab",
    "SPACE": "space",
    "UP": "up",
    "DOWN": "down",
    "LEFT": "left",
    "RIGHT": "right",
    "BACKSPACE": "backspace",
    "DELETE": "delete",
    "HOME": "home",
    "END": "end",
    "PAGEUP": "prior",
    "PAGEDOWN": "next",
    "F1": "f1", "F2": "f2", "F3": "f3", "F4": "f4",
    "F5": "f5", "F6": "f6", "F7": "f7", "F8": "f8",
    "F9": "f9", "F10": "f10", "F11": "f11", "F12": "f12",
    "MINUS": "minus",
    "EQUAL": "equal",
    "SLASH": "slash",
    "SEMICOLON": "semicolon",
    "APOSTROPHE": "apostrophe",
    "GRAVE": "grave",
    "COMMA": "comma",
    "DOT": "period",
    "PERIOD": "period",
}

# wtype modifier flags: -M presses modifier, -m releases
WTYPE_MODIFIERS = {
    "SUPER": "super",
    "META": "super",
    "WIN": "super",
    "CTRL": "ctrl",
    "CONTROL": "ctrl",
    "ALT": "alt",
    "SHIFT": "shift",
}

MOUSE_BUTTONS = {1: "0x40", 2: "0x60", 3: "0x80"}


def get_monitor_resolution():
    """Get primary monitor resolution via hyprctl."""
    result = subprocess.run(
        ["hyprctl", "monitors", "-j"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0 or not result.stdout.strip():
        print(
            "Warning: could not get monitor info, using 1920x1080",
            file=sys.stderr,
        )
        return 1920, 1080
    monitors = json.loads(result.stdout)
    if not monitors:
        return 1920, 1080
    mon = monitors[0]
    return mon["width"], mon["height"]


def build_wtype_key_cmd(key_str):
    """Build wtype command args for 'SUPER+RETURN' etc.

    Returns a list of args to pass to wtype.
    Example: 'SUPER+RETURN' -> ['-M', 'super', '-k', 'return', '-m', 'super']
    Example: 'RETURN' -> ['-k', 'return']
    """
    parts = key_str.upper().split("+")
    modifiers = []
    key = None
    for part in parts:
        if part in WTYPE_MODIFIERS:
            modifiers.append(WTYPE_MODIFIERS[part])
        else:
            # The actual key (last non-modifier part)
            key = WTYPE_KEY_MAP.get(part, part.lower())
    if key is None and modifiers:
        # All parts are modifiers; use last as key
        key = WTYPE_KEY_MAP.get(parts[-1], parts[-1].lower())
        modifiers = [WTYPE_MODIFIERS[p] for p in parts[:-1]
                     if p in WTYPE_MODIFIERS]
    args = []
    for mod in modifiers:
        args += ["-M", mod]
    if key:
        args += ["-k", key]
    for mod in reversed(modifiers):
        args += ["-m", mod]
    return args


def run(cmd, timeout=10):
    """Run a command, logging errors but not crashing."""
    try:
        result = subprocess.run(
            cmd, check=True, timeout=timeout,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            text=True,
        )
        if result.stdout:
            print(f"  stdout: {result.stdout.strip()}")
        if result.stderr:
            print(f"  stderr: {result.stderr.strip()}")
    except subprocess.TimeoutExpired:
        print(f"  Warning: {cmd} timed out after {timeout}s",
              file=sys.stderr)
    except subprocess.CalledProcessError as e:
        print(f"  Warning: {cmd[0]} failed (exit {e.returncode})",
              file=sys.stderr)
        if e.stdout:
            print(f"  stdout: {e.stdout.strip()}", file=sys.stderr)
        if e.stderr:
            print(f"  stderr: {e.stderr.strip()}", file=sys.stderr)
    except FileNotFoundError:
        print(f"  Warning: command not found: {cmd[0]}",
              file=sys.stderr)


def execute_layout(name):
    if name not in LAYOUTS:
        print(f"  Unknown layout: {name}", file=sys.stderr)
        return
    for step in LAYOUTS[name]:
        if step[0] == "exec":
            run(["hyprctl", "dispatch", "exec", step[1]])
        elif step[0] == "sleep":
            time.sleep(step[1])
        elif step[0] == "dispatch":
            run(["hyprctl", "dispatch"] + step[1].split())


def execute_action(action, width, height):
    if "wait" in action:
        time.sleep(action["wait"])

    elif "layout" in action:
        execute_layout(action["layout"])

    elif "exec" in action:
        run(["hyprctl", "dispatch", "exec", action["exec"]])

    elif "dispatch" in action:
        run(["hyprctl", "dispatch"] + action["dispatch"].split())

    elif "workspace" in action:
        run(["hyprctl", "dispatch", "workspace", str(action["workspace"])])

    elif "move" in action:
        x = int(action["move"][0] * width)
        y = int(action["move"][1] * height)
        run(["ydotool", "mousemove", "--absolute", "-x", str(x), "-y", str(y)])

    elif "click" in action:
        btn = MOUSE_BUTTONS.get(action["click"], "0x40")
        run(["ydotool", "click", btn])

    elif "key" in action:
        key = action["key"].upper()
        if key in ("RETURN", "ENTER"):
            # RETURN は wl-copy + paste で送る (wtype の繰り返しバグ回避)
            # bash は bracketed paste off の場合 \n をそのまま実行する
            wlcopy = subprocess.Popen(
                ["wl-copy", "--", "\n"],
                stdin=subprocess.DEVNULL,
                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            )
            time.sleep(0.1)
            run(["wtype", "-M", "ctrl", "-M", "shift", "-k", "v",
                 "-m", "shift", "-m", "ctrl"], timeout=10)
            time.sleep(0.1)
            try:
                wlcopy.wait(timeout=3)
            except subprocess.TimeoutExpired:
                wlcopy.kill()
        else:
            wtype_args = build_wtype_key_cmd(action["key"])
            run(["wtype"] + wtype_args, timeout=30)

    elif "type" in action:
        # wl-copy をバックグラウンドで起動しクリップボードを保持させ、
        # Ctrl+Shift+V でペースト後に終了させる
        # (wtype 文字注入の繰り返しバグを回避)
        wlcopy = subprocess.Popen(
            ["wl-copy", "--", action["type"]],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        time.sleep(0.2)
        run(["wtype", "-M", "ctrl", "-M", "shift", "-k", "v",
             "-m", "shift", "-m", "ctrl"], timeout=10)
        time.sleep(0.1)
        try:
            wlcopy.wait(timeout=3)
        except subprocess.TimeoutExpired:
            wlcopy.kill()

    elif "screenshot" in action:
        run(["grim", action["screenshot"]])

    elif "comment" in action:
        pass  # コメントは無視

    else:
        print(f"  Warning: unknown action: {action}", file=sys.stderr)


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <demo.json>", file=sys.stderr)
        sys.exit(1)

    script_path = sys.argv[1]
    with open(script_path) as f:
        actions = json.load(f)

    width, height = get_monitor_resolution()
    print(f"Monitor: {width}x{height}")
    print(f"Running {len(actions)} actions from {script_path}")

    for i, action in enumerate(actions):
        print(f"  [{i + 1}/{len(actions)}] {action}")
        execute_action(action, width, height)

    print("Replay complete.")


if __name__ == "__main__":
    main()
