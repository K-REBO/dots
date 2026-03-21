#!/usr/bin/env python3
"""Hyprland demo replay engine.

Reads a JSON demo script and executes actions via hyprctl/ydotool.
Runs inside the demo VM after Hyprland has started.

Action types:
  { "wait": 0.5 }           - sleep in seconds
  { "exec": "kitty" }       - launch app via hyprctl dispatch exec
  { "dispatch": "..." }     - arbitrary hyprctl dispatch
  { "workspace": 2 }        - switch workspace
  { "layout": "..." }       - predefined layout
  { "move": [0.4, 0.6] }   - mouse move (relative 0.0-1.0)
  { "click": 1 }            - 1=left, 2=middle, 3=right
  { "key": "SUPER+RETURN" } - keyboard shortcut
  { "type": "hello" }       - type text
"""

import json
import subprocess
import sys
import time


# Predefined window layouts built via hyprctl dispatch
LAYOUTS = {
    "terminal-left-browser-right": [
        ("exec", "kitty"),
        ("sleep", 1.5),
        ("exec", "firefox"),
        ("sleep", 2.0),
        ("dispatch", "movefocus l"),
        ("dispatch", "resizeactive exact 960 0"),
    ],
    "terminal-fullscreen": [
        ("exec", "kitty"),
        ("sleep", 1.0),
        ("dispatch", "fullscreen 1"),
    ],
    "two-terminals": [
        ("exec", "kitty"),
        ("sleep", 1.0),
        ("exec", "kitty"),
        ("sleep", 1.0),
        ("dispatch", "togglesplit"),
    ],
    "terminal-only": [
        ("exec", "kitty"),
        ("sleep", 1.0),
    ],
}

# Human-readable key names to ydotool/Linux key names
KEY_MAP = {
    "SUPER": "KEY_LEFTMETA",
    "META": "KEY_LEFTMETA",
    "WIN": "KEY_LEFTMETA",
    "CTRL": "KEY_LEFTCTRL",
    "CONTROL": "KEY_LEFTCTRL",
    "ALT": "KEY_LEFTALT",
    "SHIFT": "KEY_LEFTSHIFT",
    "RETURN": "KEY_ENTER",
    "ENTER": "KEY_ENTER",
    "ESC": "KEY_ESC",
    "ESCAPE": "KEY_ESC",
    "TAB": "KEY_TAB",
    "SPACE": "KEY_SPACE",
    "UP": "KEY_UP",
    "DOWN": "KEY_DOWN",
    "LEFT": "KEY_LEFT",
    "RIGHT": "KEY_RIGHT",
    "BACKSPACE": "KEY_BACKSPACE",
    "DELETE": "KEY_DELETE",
    "HOME": "KEY_HOME",
    "END": "KEY_END",
    "PAGEUP": "KEY_PAGEUP",
    "PAGEDOWN": "KEY_PAGEDOWN",
    "F1": "KEY_F1",
    "F2": "KEY_F2",
    "F3": "KEY_F3",
    "F4": "KEY_F4",
    "F5": "KEY_F5",
    "F6": "KEY_F6",
    "F7": "KEY_F7",
    "F8": "KEY_F8",
    "F9": "KEY_F9",
    "F10": "KEY_F10",
    "F11": "KEY_F11",
    "F12": "KEY_F12",
    "MINUS": "KEY_MINUS",
    "EQUAL": "KEY_EQUAL",
    "SLASH": "KEY_SLASH",
    "SEMICOLON": "KEY_SEMICOLON",
    "APOSTROPHE": "KEY_APOSTROPHE",
    "GRAVE": "KEY_GRAVE",
    "COMMA": "KEY_COMMA",
    "DOT": "KEY_DOT",
    "PERIOD": "KEY_DOT",
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


def to_ydotool_key(key_str):
    """Convert 'SUPER+RETURN' to 'KEY_LEFTMETA+KEY_ENTER'."""
    parts = key_str.upper().split("+")
    result = []
    for part in parts:
        if part in KEY_MAP:
            result.append(KEY_MAP[part])
        elif len(part) == 1 and part.isalpha():
            result.append(f"KEY_{part}")
        elif len(part) == 1 and part.isdigit():
            result.append(f"KEY_{part}")
        else:
            result.append(f"KEY_{part}")
    return "+".join(result)


def run(cmd):
    """Run a command, logging errors but not crashing."""
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"  Warning: {cmd[0]} failed: {e}", file=sys.stderr)
    except FileNotFoundError:
        print(f"  Warning: command not found: {cmd[0]}", file=sys.stderr)


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
        ydotool_key = to_ydotool_key(action["key"])
        run(["ydotool", "key", ydotool_key])

    elif "type" in action:
        run(["ydotool", "type", "--", action["type"]])

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
