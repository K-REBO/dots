#!/usr/bin/env python3
"""Demo replay engine.

Reads a JSON demo script and executes WM-agnostic actions.
Runs inside the demo VM after the compositor has started.

Action types:
  { "wait": 0.5 }                             - sleep in seconds
  { "launch": "alacritty" }                   - launch app
  { "focus_window": "Alacritty" }             - focus window by class/app-id
  { "wait_window": "Alacritty" }              - wait until window appears
  { "wait_window": "Alacritty", "count": 2 }  - wait until N windows of class appear
  { "type": "hello\n" }                        - type text via clipboard
  { "key": "SUPER+RETURN" }                   - keyboard shortcut
  { "move": [0.4, 0.6] }                      - mouse move (relative 0.0-1.0)
  { "click": 1 }                              - 1=left, 2=middle, 3=right
  { "workspace": 2 }                          - switch workspace
  { "screenshot": "/recordings/s.png" }       - capture screenshot via grim
  { "comment": "..." }                        - ignored
"""

import json
import os
import subprocess
import sys
import time


# ===========================================================================
# WM Driver abstraction
# ===========================================================================

class WmDriver:
    """Abstract WM driver interface."""

    def launch(self, cmd: str):
        raise NotImplementedError

    def focus_window(self, identifier: str, by: str = "class"):
        raise NotImplementedError

    def wait_window(self, identifier: str, timeout: float = 10.0, count: int = 1, by: str = "class"):
        raise NotImplementedError

    def workspace(self, num: int):
        raise NotImplementedError


class HyprlandDriver(WmDriver):
    def launch(self, cmd: str):
        run(["hyprctl", "dispatch", "exec", cmd])

    def focus_window(self, identifier: str, by: str = "class"):
        if by == "title":
            run(["hyprctl", "dispatch", "focuswindow", f"title:^({identifier})$"])
        else:
            run(["hyprctl", "dispatch", "focuswindow", f"class:^({identifier})$"])

    def wait_window(self, identifier: str, timeout: float = 10.0, count: int = 1, by: str = "class"):
        deadline = time.time() + timeout
        field = "title" if by == "title" else "class"
        while time.time() < deadline:
            result = subprocess.run(
                ["hyprctl", "clients", "-j"],
                capture_output=True, text=True,
            )
            if result.returncode == 0 and result.stdout.strip():
                clients = json.loads(result.stdout)
                matching = [c for c in clients if c.get(field) == identifier]
                if len(matching) >= count:
                    return
            time.sleep(0.2)
        print(
            f"  Warning: wait_window timeout ({timeout}s) "
            f"for '{identifier}' (by={by}) x{count}",
            file=sys.stderr,
        )

    def workspace(self, num: int):
        run(["hyprctl", "dispatch", "workspace", str(num)])


class NiriDriver(WmDriver):
    def launch(self, cmd: str):
        # niri msg spawn は shell を経由しないため sh -c でラップ
        run(["niri", "msg", "action", "spawn", "--", "sh", "-c", cmd])

    def focus_window(self, identifier: str, by: str = "class"):
        if by == "title":
            # niri: タイトルでフォーカスするには IPC で window id を取得してから
            result = subprocess.run(
                ["niri", "msg", "-j", "windows"],
                capture_output=True, text=True,
            )
            if result.returncode == 0 and result.stdout.strip():
                windows = json.loads(result.stdout)
                match = next((w for w in windows if w.get("title") == identifier), None)
                if match:
                    run(["niri", "msg", "action", "focus-window", "--id", str(match["id"])])
                    return
            print(f"  Warning: window '{identifier}' not found", file=sys.stderr)
        else:
            run(["niri", "msg", "action", "focus-window-by-app-id", identifier])

    def wait_window(self, identifier: str, timeout: float = 10.0, count: int = 1, by: str = "class"):
        deadline = time.time() + timeout
        field = "title" if by == "title" else "app_id"
        while time.time() < deadline:
            result = subprocess.run(
                ["niri", "msg", "-j", "windows"],
                capture_output=True, text=True,
            )
            if result.returncode == 0 and result.stdout.strip():
                windows = json.loads(result.stdout)
                matching = [w for w in windows if w.get(field) == identifier]
                if len(matching) >= count:
                    return
            time.sleep(0.2)
        print(
            f"  Warning: wait_window timeout ({timeout}s) "
            f"for '{identifier}' (by={by}) x{count}",
            file=sys.stderr,
        )

    def workspace(self, num: int):
        run(["niri", "msg", "action", "focus-workspace", str(num)])


def detect_driver() -> WmDriver:
    """Auto-detect WM from environment, or use WM_DRIVER env var."""
    override = os.environ.get("WM_DRIVER", "").lower()
    if override == "niri":
        return NiriDriver()
    if override == "hyprland":
        return HyprlandDriver()
    if os.environ.get("HYPRLAND_INSTANCE_SIGNATURE"):
        return HyprlandDriver()
    if os.environ.get("NIRI_SOCKET"):
        return NiriDriver()
    print("Warning: WM not detected, defaulting to Hyprland driver", file=sys.stderr)
    return HyprlandDriver()


# ===========================================================================
# Key/mouse helpers
# ===========================================================================

WTYPE_KEY_MAP = {
    "SUPER": "super_l", "META": "super_l", "WIN": "super_l",
    "CTRL": "ctrl_l", "CONTROL": "ctrl_l",
    "ALT": "alt_l",
    "SHIFT": "shift_l",
    "RETURN": "return", "ENTER": "return",
    "ESC": "escape", "ESCAPE": "escape",
    "TAB": "tab", "SPACE": "space",
    "UP": "up", "DOWN": "down", "LEFT": "left", "RIGHT": "right",
    "BACKSPACE": "backspace", "DELETE": "delete",
    "HOME": "home", "END": "end",
    "PAGEUP": "prior", "PAGEDOWN": "next",
    "F1": "f1", "F2": "f2", "F3": "f3", "F4": "f4",
    "F5": "f5", "F6": "f6", "F7": "f7", "F8": "f8",
    "F9": "f9", "F10": "f10", "F11": "f11", "F12": "f12",
    "MINUS": "minus", "EQUAL": "equal", "SLASH": "slash",
    "SEMICOLON": "semicolon", "APOSTROPHE": "apostrophe",
    "GRAVE": "grave", "COMMA": "comma",
    "DOT": "period", "PERIOD": "period",
}

WTYPE_MODIFIERS = {
    "SUPER": "super", "META": "super", "WIN": "super",
    "CTRL": "ctrl", "CONTROL": "ctrl",
    "ALT": "alt", "SHIFT": "shift",
}

MOUSE_BUTTONS = {1: "0x40", 2: "0x60", 3: "0x80"}


def build_wtype_key_cmd(key_str: str) -> list:
    parts = key_str.upper().split("+")
    modifiers = []
    key = None
    for part in parts:
        if part in WTYPE_MODIFIERS:
            modifiers.append(WTYPE_MODIFIERS[part])
        else:
            key = WTYPE_KEY_MAP.get(part, part.lower())
    if key is None and modifiers:
        key = WTYPE_KEY_MAP.get(parts[-1], parts[-1].lower())
        modifiers = [
            WTYPE_MODIFIERS[p] for p in parts[:-1] if p in WTYPE_MODIFIERS
        ]
    args = []
    for mod in modifiers:
        args += ["-M", mod]
    if key:
        args += ["-k", key]
    for mod in reversed(modifiers):
        args += ["-m", mod]
    return args


# ===========================================================================
# Subprocess helpers
# ===========================================================================

def run(cmd, timeout=10):
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
        print(f"  Warning: {cmd} timed out after {timeout}s", file=sys.stderr)
    except subprocess.CalledProcessError as e:
        print(f"  Warning: {cmd[0]} failed (exit {e.returncode})", file=sys.stderr)
        if e.stdout:
            print(f"  stdout: {e.stdout.strip()}", file=sys.stderr)
        if e.stderr:
            print(f"  stderr: {e.stderr.strip()}", file=sys.stderr)
    except FileNotFoundError:
        print(f"  Warning: command not found: {cmd[0]}", file=sys.stderr)


def wl_paste(text: str):
    """Type text via clipboard (workaround for wtype repeat bug in Hyprland)."""
    wlcopy = subprocess.Popen(
        ["wl-copy", "--", text],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    time.sleep(0.2)
    run(
        ["wtype", "-M", "ctrl", "-M", "shift", "-k", "v", "-m", "shift", "-m", "ctrl"],
        timeout=10,
    )
    time.sleep(0.1)
    try:
        wlcopy.wait(timeout=3)
    except subprocess.TimeoutExpired:
        wlcopy.kill()


# ===========================================================================
# Action executor
# ===========================================================================

def get_monitor_resolution():
    result = subprocess.run(
        ["hyprctl", "monitors", "-j"],
        capture_output=True, text=True,
    )
    if result.returncode != 0 or not result.stdout.strip():
        return 1920, 1080
    monitors = json.loads(result.stdout)
    if not monitors:
        return 1920, 1080
    mon = monitors[0]
    return mon["width"], mon["height"]


def execute_action(action: dict, width: int, height: int, driver: WmDriver):
    if "wait" in action:
        time.sleep(action["wait"])

    elif "launch" in action:
        driver.launch(action["launch"])

    elif "focus_window" in action:
        driver.focus_window(action["focus_window"], by=action.get("by", "class"))

    elif "wait_window" in action:
        driver.wait_window(
            action["wait_window"],
            timeout=action.get("timeout", 10.0),
            count=action.get("count", 1),
            by=action.get("by", "class"),
        )

    elif "workspace" in action:
        driver.workspace(action["workspace"])

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
            wl_paste("\n")
        else:
            run(["wtype"] + build_wtype_key_cmd(action["key"]), timeout=30)

    elif "type" in action:
        wl_paste(action["type"])

    elif "screenshot" in action:
        run(["grim", action["screenshot"]])

    elif "comment" in action:
        pass

    else:
        print(f"  Warning: unknown action: {action}", file=sys.stderr)


# ===========================================================================
# Main
# ===========================================================================

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <demo.json>", file=sys.stderr)
        sys.exit(1)

    with open(sys.argv[1]) as f:
        actions = json.load(f)

    driver = detect_driver()
    print(f"WM driver: {driver.__class__.__name__}")

    width, height = get_monitor_resolution()
    print(f"Monitor: {width}x{height}")
    print(f"Running {len(actions)} actions from {sys.argv[1]}")

    for i, action in enumerate(actions):
        print(f"  [{i + 1}/{len(actions)}] {action}")
        execute_action(action, width, height, driver)

    print("Replay complete.")


if __name__ == "__main__":
    main()
