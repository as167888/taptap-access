#!/bin/bash
# Install Chromium system dependencies without sudo.
# Downloads .deb packages and extracts .so files into libs/.
# After running this, set:
#   export LD_LIBRARY_PATH="$(pwd)/libs/usr/lib/x86_64-linux-gnu"

set -e

TARGET_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LIBS_DIR="$TARGET_DIR/libs"
TMP_DIR=$(mktemp -d)

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

if [ ! -d "$HOME/.cache/ms-playwright" ]; then
    echo "Run 'playwright install chromium' first to download the browser."
    exit 1
fi

PACKAGES=(
    libnspr4 libnss3 libasound2 libgbm1 libx11-6 libxcomposite1 libxdamage1
    libxext6 libxfixes3 libxrandr2 libxcb1 libxkbcommon0 libatspi2.0-0
    libatk1.0-0 libatk-bridge2.0-0 libxrender1 libx11-xcb1 libxcb-dri3-0
    libxcb-present0 libxcb-sync1 libxcb-shape0 libxcb-xfixes0 libxcb-randr0
    libxshmfence1 libglib2.0-0 libcups2 libdbus-1-3 libexpat1
    libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libgtk-3-0
    libgdk-pixbuf-2.0-0 libcairo2 libdrm2 libwayland-client0 libwayland-server0
    libwayland-egl1-mesa libegl1-mesa libegl1 libgl1-mesa-dri libgl1 libgles2
    libharfbuzz0b libfontconfig1 libfreetype6 libpixman-1-0 libpng16-16
    libxcb-render0 libxcb-shm0 libxau6 libxdmcp6 libxcursor1 libxi6
    libxinerama1 libavahi-client3 libavahi-common3 libcairo-gobject2
    libepoxy0 libfribidi0 libgraphite2-3 libjpeg8 libthai0 libwayland-cursor0
    libwayland-egl1 libglx0 libglx-mesa0 libgcc-s1
)

echo "Downloading and extracting packages to $LIBS_DIR ..."
cd "$TMP_DIR"
for pkg in "${PACKAGES[@]}"; do
    echo "  $pkg"
    apt download "$pkg" 2>/dev/null || echo "    (skipped, not available)"
done

mkdir -p "$LIBS_DIR"
for deb in *.deb; do
    [ -f "$deb" ] && dpkg-deb -x "$deb" "$LIBS_DIR" 2>/dev/null
done

echo ""
echo "Done. Add this to your environment:"
echo "  export LD_LIBRARY_PATH=\"$LIBS_DIR/usr/lib/x86_64-linux-gnu\""
