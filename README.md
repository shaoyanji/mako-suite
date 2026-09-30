# 🏮 mako-suite

> **Ultra-lightweight zero-terminal HUD & telemetry suite for Wayland and Mako.**  
> Built for maximum responsiveness on low-resource machines (tested on Intel Celeron N3060, 1.8 GiB RAM).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Wayland Ready](https://img.shields.io/badge/Wayland-Niri%20%7C%20Sway%20%7C%20Hyprland-blue)](https://wayland.freedesktop.org/)
[![Theme](https://img.shields.io/badge/Theme-Catppuccin%20Mocha-mauve)](https://github.com/catppuccin/catppuccin)
[![Memory Footprint](https://img.shields.io/badge/RAM-~0MB%20idle%20/%20<5MB%20active-success)](#performance)

---

## 💡 Why mako-suite?

On lightweight laptops, netbooks, and handhelds, launching a full terminal emulator or GUI monitoring app (like `btop`, `htop`, or `kando`) costs **50–150 MB of RAM**, causes disk swapping, and distracts from your active workspace.

**`mako-suite` transforms your existing notification daemon ([Mako](https://github.com/emersion/mako)) into an instant heads-up telemetry display:**
* **Zero persistent RAM footprint:** Pure bash/awk scripts that sample `/proc` or `sysfs` in milliseconds and immediately exit or idle.
* **Non-intrusive:** Telemetry pops up cleanly in the corner without stealing window focus or re-tiling your workspace.
* **Instant toggle:** Hit a keybinding to summon; hit it again (or click) to dismiss.
* **Interactive power:** Integrates with [Fuzzel](https://codeberg.org/dnkl/fuzzel) for interactive menus (kill processes, switch Wi-Fi, change CPU governors).

---

## 🧰 The Suite

| Tool | Icon | Purpose | Default Hotkey | Border Color |
| :--- | :---: | :--- | :---: | :--- |
| **`makotop`** | ⚡ | Live CPU, RAM & Swap monitor HUD with top memory hogs | `Mod + BackSpace` | Mocha Green (`#a6e3a1`) |
| **`makofetch`** | 🐧 | Instant hardware & OS specifications card | `Mod + Shift + BackSpace` | Mocha Blue (`#89b4fa`) |
| **`makodf`** | 💾 | Storage usage, mounted partitions & Nix GC trigger | `Mod + Ctrl + BackSpace` | Mocha Peach (`#fab387`) |
| **`makokill`** | 🎯 | Process sniper & panic runaway process killer | `Mod + Alt + BackSpace` | Mocha Red (`#f38ba8`) |
| **`makonet`** | 📡 | Network telemetry, Wi-Fi signal & parallel latency | `Mod + Shift + Ctrl + BackSpace` | Mocha Mauve (`#cba6f7`) |
| **`makobatt`** | 🔋 | Battery telemetry, CPU governor & power manager | Waybar click / `makobatt` | Mocha Yellow (`#f9e2af`) |

---

## ⚡ Component Breakdown

### 1. `makotop` — Live System Monitor HUD
* Real-time CPU usage percentage calculated directly from `/proc/stat` delta.
* RAM and ZRAM/Swap visual usage bars.
* Top 3 memory-consuming processes (`comm`, PID, RSS).
* Dynamic update loop (1s interval) that automatically shuts down when the notification is dismissed.

```text
⚡ System Monitor
CPU:  [████░░░░░░] 38%
RAM:  [███████░░░] 72% (1.3G / 1.8G)
Swap: [██░░░░░░░░] 21% (210M / 1.0G)

Top Consumers:
1. alacritty (PID 1420) — 148M
2. agy (PID 2891) — 96M
3. niri (PID 1102) — 64M
```

### 2. `makofetch` — Instant Hardware Specs
* Executes in under **15 milliseconds**.
* Extracts distribution, kernel, uptime, desktop compositor, CPU, memory, root disk, and battery.
* Displays your system logo / icon with crisp typography.

### 3. `makodf` — Storage & Filesystem Monitor
* Visual capacity bars for all mounted physical, virtual, and removable filesystems.
* Highlights warning thresholds: Green (<70%), Peach (70–85%), Red (>85%).
* Interactive mode (`makodf -m`):
  * Trigger Nix garbage collection (`nix-collect-garbage -d`).
  * Check inode saturation (`df -i`).
  * Copy disk summary to clipboard (`wl-copy`).

### 4. `makokill` — Process Sniper & Panic HUD
* One-click rescue for frozen or unresponsive desktops.
* **Kill Top CPU Hog:** Automatically terminates the runaway thread consuming the most cycles.
* **Clean Stuck Audio:** Kills orphaned `pw-record` audio loops and removes lockfiles.
* **Interactive Sniper (`makokill -k`):** Opens a Fuzzel fuzzy search prompt to search and send `SIGTERM` or `SIGKILL` to any process.

### 5. `makonet` — Network Telemetry & Wi-Fi HUD
* Real-time network telemetry: active interface, local IP, public IP, and gateway.
* Wi-Fi SSID, connection frequency (2.4/5GHz), bitrate, and visual signal strength.
* **Parallel Multi-Endpoint Latency:** Pings Cloudflare (`1.1.1.1`), Google (`8.8.8.8`), and GitHub (`github.com`) simultaneously in < 1 second.
* **Wi-Fi Picker (`makonet -s`):** Fast Fuzzel menu to scan and connect to available SSIDs.

```text
📡 Network Telemetry (wlan0)
SSID:      Home-Fiber-5G (5240 MHz)
Signal:    [████████░░] 82% (-54 dBm)
IP:        192.108.1.42 (Public: 104.28.x.x)

Latency:
• 1.1.1.1       14.2 ms
• 8.8.8.8       18.5 ms
• github.com    24.1 ms
```

### 6. `makobatt` — Battery & Power Manager
* Real-time battery charge percentage, status (Charging, Discharging, Full), and remaining time.
* Battery health & wear rate calculation (`charge_full / charge_full_design`).
* **CPU Governor Switcher:** Instant toggle between `schedutil` (power save) and `performance` (boost).
* **Power Menu (`makobatt -m`):** Suspend, reboot, shutdown, and governor options via Fuzzel.
* **Low-Battery Sentinel (`makobatt -s`):** Background daemon (~0.01% CPU) sending alerts at 20%, 10%, and critical 5%.

---

## ⌨️ Ergonomic Hotkey Cluster (Niri / Sway)

All monitor HUDs are clustered logically around the **BackSpace** key for effortless one-handed triggering:

```
[ Mod ] + ─────────────────────────── [ BackSpace ]  --> makotop   (System Monitor)
[ Mod ] + [ Shift ] + ─────────────── [ BackSpace ]  --> makofetch (Specs Card)
[ Mod ] + [ Ctrl ]  + ─────────────── [ BackSpace ]  --> makodf    (Disk Usage)
[ Mod ] + [ Alt ]   + ─────────────── [ BackSpace ]  --> makokill  (Process Sniper)
[ Mod ] + [ Shift ] + [ Ctrl ] + ──── [ BackSpace ]  --> makonet   (Network Telemetry)
```

---

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/shaoyanji/mako-suite.git
cd mako-suite
```

### 2. Run the Installer
```bash
./install.sh
```
* Installs binaries to `~/.local/bin/`.
* Installs desktop entries to `~/.local/share/applications/`.
* Automatically appends Catppuccin Mocha rules to `~/.config/mako/config`.
* Reloads the running Mako daemon.

*(To copy files instead of symlinking, use `./install.sh --copy`)*

### 3. Add Keybindings
Add the snippets from [`config/niri.kdl`](config/niri.kdl) into your `~/.config/niri/config.kdl` (or adapt for `sway/config` / `hyprland.conf`).

---

## 📊 Waybar Integration

You can effortlessly bind modules in `~/.config/waybar/config.jsonc` to trigger mako-suite HUDs on click:

```jsonc
"cpu": {
    "format": " {usage}%",
    "on-click": "makotop",
    "on-click-right": "makokill -k"
},
"memory": {
    "format": " {percentage}%",
    "on-click": "makotop",
    "on-click-right": "makodf -m"
},
"network": {
    "format-wifi": " {essid}",
    "format-disconnected": "⚠ Disconnected",
    "on-click": "makonet",
    "on-click-right": "makonet -m"
},
"battery": {
    "format": "{icon} {capacity}%",
    "on-click": "makobatt",
    "on-click-right": "makobatt --menu"
}
```

---

## 📦 Dependencies

* **Required:** `bash`, `awk`, `mako` (or another D-Bus notification daemon supporting Pango markup).
* **Recommended:**
  * `fuzzel` — for interactive fuzzy search menus.
  * `fastfetch` — for `makofetch` spec cards.
  * `networkmanager` (`nmcli`) — for `makonet` Wi-Fi scanning and telemetry.
  * `wl-clipboard` (`wl-copy`) — for clipboard exports.

---

## 📜 License

MIT License © 2026 Shao-yan (Matt) Ji & Antigravity. See [LICENSE](LICENSE) for details.
