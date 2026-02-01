#!/bin/bash

# DodoPulse KDE Plasma Widget Uninstaller

WIDGET_NAME="com.dodoapps.dodopulse"

echo "╔══════════════════════════════════════════╗"
echo "║    DodoPulse KDE Widget Uninstaller      ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Check user installation
USER_DIR="$HOME/.local/share/plasma/plasmoids/$WIDGET_NAME"
SYSTEM_DIR="/usr/share/plasma/plasmoids/$WIDGET_NAME"

if [ -d "$USER_DIR" ]; then
    echo "🗑 Removing user installation..."
    rm -rf "$USER_DIR"
    echo "✅ Removed: $USER_DIR"
fi

if [ -d "$SYSTEM_DIR" ]; then
    echo "🗑 Removing system installation (requires sudo)..."
    sudo rm -rf "$SYSTEM_DIR"
    echo "✅ Removed: $SYSTEM_DIR"
fi

echo ""
echo "✅ Uninstallation complete!"
echo ""
echo "Note: You may need to restart Plasma for changes to take effect:"
echo "  kquitapp5 plasmashell && kstart5 plasmashell"
echo ""
