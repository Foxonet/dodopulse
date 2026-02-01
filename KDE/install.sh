#!/bin/bash

# DodoPulse KDE Plasma Widget Installer
# This script installs the DodoPulse widget for KDE Plasma

set -e

WIDGET_NAME="com.dodoapps.dodopulse"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

echo "╔══════════════════════════════════════════╗"
echo "║     DodoPulse KDE Widget Installer       ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Handle --package option to create .plasmoid file
if [ "$1" == "--package" ]; then
    echo "📦 Creating .plasmoid package..."
    cd "$SCRIPT_DIR"
    rm -f "$PARENT_DIR/dodopulse.plasmoid"
    zip -r "$PARENT_DIR/dodopulse.plasmoid" metadata.json contents/
    echo ""
    echo "✅ Package created: $PARENT_DIR/dodopulse.plasmoid"
    echo ""
    echo "To install: plasmapkg2 -i dodopulse.plasmoid"
    exit 0
fi

# Check if running on KDE Plasma
if [ -z "$KDE_SESSION_VERSION" ] && [ -z "$KDE_FULL_SESSION" ]; then
    echo "⚠ Warning: KDE Plasma session not detected."
    echo "  This widget requires KDE Plasma 5.x or 6.x"
    echo ""
fi

# Determine installation directory
if [ "$1" == "--system" ]; then
    INSTALL_DIR="/usr/share/plasma/plasmoids/$WIDGET_NAME"
    echo "📦 Installing system-wide (requires sudo)..."
    SUDO="sudo"
else
    INSTALL_DIR="$HOME/.local/share/plasma/plasmoids/$WIDGET_NAME"
    echo "📦 Installing for current user..."
    SUDO=""
fi

# Create installation directory
$SUDO mkdir -p "$INSTALL_DIR"

# Copy files
echo "📁 Copying widget files..."
$SUDO cp -r "$SCRIPT_DIR/metadata.json" "$INSTALL_DIR/"
$SUDO cp -r "$SCRIPT_DIR/contents" "$INSTALL_DIR/"

# Set permissions
$SUDO chmod -R 755 "$INSTALL_DIR"

echo ""
echo "✅ Installation complete!"
echo ""
echo "📍 Installed to: $INSTALL_DIR"
echo ""
echo "To add the widget:"
echo "  1. Right-click on your desktop or panel"
echo "  2. Select 'Add Widgets...'"
echo "  3. Search for 'DodoPulse'"
echo "  4. Drag it to your desktop or panel"
echo ""
echo "Or add from command line:"
echo "  plasmapkg2 -i $SCRIPT_DIR"
echo ""
echo "To uninstall:"
echo "  ./uninstall.sh"
echo ""
echo "To create .plasmoid package:"
echo "  $0 --package"
echo ""
