#!/bin/sh
set -eu

print_usage() {
  cat <<EOF
Usage: $0 [--desktop PATH] [--extras]

Installs Neovide Dolphin integration:
  - icon:        \$HOME/.local/share/icons/hicolor/512x512/apps/neovide.png
  - servicemenu: \$HOME/.local/share/kio/servicemenus/openInNeovide.desktop
  - extras:      \$HOME/.local/share/applications/Neovide.desktop (optional)

Options:
  --desktop PATH     Source .desktop file to install (default: ./openInNeovide.desktop)
  -e, --extras       Also install extras (Neovide.desktop application launcher)
  -h, --help         Show this help
EOF
}

SRC_DESKTOP="./openInNeovide.desktop"
INSTALL_EXTRAS=false

while [ $# -gt 0 ]; do
  case "$1" in
  --desktop)
    shift
    [ $# -gt 0 ] || {
      echo "Missing value for --desktop"
      exit 2
    }
    SRC_DESKTOP="$1"
    shift
    ;;
  -e | --extras)
    INSTALL_EXTRAS=true
    shift
    ;;
  -h | --help)
    print_usage
    exit 0
    ;;
  *)
    echo "Unknown arg: $1"
    print_usage
    exit 2
    ;;
  esac
done

if [ ! -f "$SRC_DESKTOP" ]; then
  echo "Error: Source desktop file not found: $SRC_DESKTOP"
  exit 1
fi

USER_SERVICEMENU_DIR="$HOME/.local/share/kio/servicemenus"
DEST_DESKTOP_PATH="$USER_SERVICEMENU_DIR/$(basename "$SRC_DESKTOP")"

echo "Installing Neovide Dolphin integration..."
echo "SRC_DESKTOP: $SRC_DESKTOP"
if [ "$INSTALL_EXTRAS" = true ]; then
  echo "INSTALL_EXTRAS: true"
fi
echo

USER_ICON_PATH="$HOME/.local/share/icons/hicolor/128x128/apps/neovide.png"
mkdir -p "$(dirname "$USER_ICON_PATH")"

REPO_ICON="./neovide.png"
if [ -f "$REPO_ICON" ]; then
  cp -f "$REPO_ICON" "$USER_ICON_PATH"
  echo "Copied icon from repo $REPO_ICON -> $USER_ICON_PATH"
else
  echo "No icon found at $REPO_ICON. Skipping icon copy."
fi

mkdir -p "$USER_SERVICEMENU_DIR"
cp -f "$SRC_DESKTOP" "$DEST_DESKTOP_PATH"
chmod +x "$DEST_DESKTOP_PATH"
echo "Installed service menu to $DEST_DESKTOP_PATH"

if [ "$INSTALL_EXTRAS" = true ]; then
  USER_APPS_DIR="$HOME/.local/share/applications"
  mkdir -p "$USER_APPS_DIR"
  cp -f "./extras/Neovide.desktop" "$USER_APPS_DIR/Neovide.desktop"
  chmod +x "$USER_APPS_DIR/Neovide.desktop"
  echo "Installed extras to $USER_APPS_DIR/Neovide.desktop"
fi

echo
echo "Installation complete!"
echo
echo "If the icon doesn't appear immediately in Dolphin, try:"
echo "  - Log out and back in"
echo "  - Or run: kbuildsycoca5"
