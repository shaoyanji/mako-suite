#!/usr/bin/env bash
# ==============================================================================
# mako-suite: Master Installer & Linker
# Author: Shao-yan (Matt) Ji & Antigravity
# License: MIT
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
DESKTOP_DIR="${HOME}/.local/share/applications"
MAKO_CONF="${HOME}/.config/mako/config"

TOOLS=("makotop" "makofetch" "makodf" "makokill" "makonet" "makobatt")

# --- UNINSTALL MODE ---
if [ "${1:-}" = "--uninstall" ] || [ "${1:-}" = "-u" ]; then
    echo "🗑️  Uninstalling mako-suite..."
    for tool in "${TOOLS[@]}"; do
        rm -f "${BIN_DIR}/${tool}"
        rm -f "${DESKTOP_DIR}/${tool}.desktop"
    done
    echo "✅ Removed binaries and desktop entries."
    echo "💡 Note: ~/.config/mako/config was not modified."
    exit 0
fi

echo "🚀 Installing mako-suite..."

# 1. Ensure target directories exist
mkdir -p "$BIN_DIR"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$(dirname "$MAKO_CONF")"

# 2. Install / Symlink binaries
LINK_MODE=1
if [ "${1:-}" = "--copy" ]; then
    LINK_MODE=0
fi

for tool in "${TOOLS[@]}"; do
    src="${SCRIPT_DIR}/bin/${tool}"
    dst="${BIN_DIR}/${tool}"
    if [ ! -f "$src" ]; then
        echo "⚠️  Warning: $src not found, skipping."
        continue
    fi
    chmod +x "$src"
    if [ "$LINK_MODE" -eq 1 ]; then
        ln -sf "$src" "$dst"
        echo "🔗 Linked: $dst -> $src"
    else
        cp -f "$src" "$dst"
        echo "📄 Copied: $dst"
    fi
done

# 3. Install Desktop entries
for tool in "${TOOLS[@]}"; do
    dsrc="${SCRIPT_DIR}/desktop/${tool}.desktop"
    ddst="${DESKTOP_DIR}/${tool}.desktop"
    if [ -f "$dsrc" ]; then
        cp -f "$dsrc" "$ddst"
        echo "🖥️  Installed desktop entry: $ddst"
    fi
done

# 4. Configure Mako
if [ -f "$MAKO_CONF" ]; then
    if ! grep -q "app-name=makotop" "$MAKO_CONF" 2>/dev/null; then
        echo "" >> "$MAKO_CONF"
        echo "# --- Added by mako-suite installer ---" >> "$MAKO_CONF"
        cat "${SCRIPT_DIR}/config/mako.conf" >> "$MAKO_CONF"
        echo "🎨 Appended styling rules to $MAKO_CONF"
    else
        echo "🎨 Mako rules already present in $MAKO_CONF"
    fi
else
    cp "${SCRIPT_DIR}/config/mako.conf" "$MAKO_CONF"
    echo "🎨 Initialized $MAKO_CONF with mako-suite configuration"
fi

# Reload mako if currently running
if pgrep -x "mako" >/dev/null 2>&1; then
    makoctl reload 2>/dev/null || true
    echo "🔄 Reloaded running Mako daemon."
fi

# 5. Dependency check
echo ""
echo "🔍 Checking optional & recommended dependencies:"
check_dep() {
    local cmd=$1
    local pkg=$2
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  [✓] $cmd"
    else
        echo "  [✗] $cmd (recommended for $pkg)"
    fi
}

check_dep "mako" "notifications HUD"
check_dep "makoctl" "notification management & dismissal"
check_dep "busctl" "D-Bus notifications"
check_dep "fuzzel" "interactive menus (makokill, makonet, makobatt)"
check_dep "fastfetch" "hardware & OS specs (makofetch)"
check_dep "nmcli" "Wi-Fi telemetry & selection (makonet)"
check_dep "ping" "network latency telemetry (makonet)"
check_dep "wl-copy" "clipboard copying"

echo ""
echo "🎉 mako-suite successfully installed!"
echo "👉 Keybindings can be merged from: ${SCRIPT_DIR}/config/niri.kdl"
