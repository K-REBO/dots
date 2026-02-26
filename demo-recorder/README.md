# Hyprland Demo VM

*Reproducible Video Generator*

## Overview

This project provides a fully reproducible Hyprland demo environment that:

* Uses the exact same theme/config as the host
* Runs inside a stateless QEMU VM
* Generates deterministic demo videos
* Saves recordings to the host
* Can optionally update README demo videos via CI

The design prioritizes:

* Reproducibility
* Determinism
* Isolation
* Minimal rebuild cost (leveraging Nix binary cache)

---

# Architecture

```
Host (NixOS)
 ├─ flake (host + demo-vm definitions)
 ├─ /nix/store (shared, read-only)
 ├─ ~/vm-recordings (video output)
 └─ QEMU

Demo VM (NixOS)
 ├─ base.qcow2 (read-only)
 ├─ overlay.qcow2 (ephemeral per run)
 ├─ /nix/store (9p shared, read-only)
 ├─ /recordings (9p shared)
 ├─ Hyprland (auto-login)
 ├─ Demo replay engine
 └─ wf-recorder
```

---

# Reproducibility Strategy

## 1. Environment Pinning

* `flake.nix` defines both `host` and `demo-vm`
* Theme, fonts, wallpaper included in flake
* Pinned `nixpkgs`
* Optional: fixed timezone and clock

## 2. Stateless VM

* `base.qcow2` generated once
* Each run creates `overlay.qcow2`
* Overlay deleted after shutdown
* `/nix/store` shared from host (read-only)

Result:
Every run starts from a clean, identical system state.

---

# Demo Execution Model

## Why not replay raw input logs?

Wayland restricts global input capture.
Raw libinput logs are fragile and not resolution-stable.

Instead, we use a deterministic demo script.

---

# Demo Script Format

Example:

```json
[
  { "wait": 0.5 },
  { "layout": "terminal-left-browser-right" },
  { "move": [0.4, 0.6] },
  { "click": 1 },
  { "key": "SUPER+RETURN" }
]
```

Rules:

* Mouse coordinates are relative (0.0–1.0)
* Timing is relative
* Layout is handled via Hyprland dispatch commands

---

# Layout Control (Deterministic)

Never use mouse to build layouts.

Use Hyprland API:

```
hyprctl dispatch exec kitty
hyprctl dispatch movewindow l
hyprctl dispatch workspace 2
```

This makes layout resolution-independent and stable.

---

# Replay Engine (Inside VM)

Execution flow:

```
1. VM boot
2. Auto login
3. Layout construction
4. Start wf-recorder
5. Replay demo JSON
6. Stop recording
7. Shutdown
```

Replay process:

* Read monitor resolution
* Convert relative coordinates to absolute
* Execute via `ydotool`
* Respect relative timing

---

# Input Visualization

Instead of logging, visualization is integrated into replay:

* Key presses are displayed in overlay
* Mouse clicks show animated indicators
* Visual elements are deterministic

This guarantees reproducible video output.

---

# Recording Output

Inside VM:

```
/recordings/demo.mp4
```

On host:

```
~/vm-recordings/demo.mp4
```

Video persists even though VM state is discarded.

---

# CI Integration (Optional)

Goal:

Push → Automatically update README demo video

Constraints on GitHub-hosted runners:

* No GPU
* No KVM

Solution:

```
WLR_RENDERER=pixman
```

CI pipeline:

```
1. Checkout
2. Install Nix
3. Build demo system
4. Run headless demo
5. Generate demo.mp4
6. Deploy to gh-pages
```

README embeds video from `gh-pages`.

---

# Setup Instructions

```
git clone <repo>
cd .configs/nix
sudo nixos-rebuild switch --flake .#host
./scripts/run-demo-vm.sh
```

This generates a deterministic `demo.mp4`.

---

# Design Principles

* Reproducibility > spontaneity
* WM-controlled layout
* Input used only for visual demonstration
* Stateless VM
* Binary cache usage to avoid rebuild cost

---

# Future Extensions

* Versioned demo videos (per commit SHA)
* Self-hosted runner with GPU for pixel-perfect CI
* DSL for demo scripting
* Improved input visualization overlay
