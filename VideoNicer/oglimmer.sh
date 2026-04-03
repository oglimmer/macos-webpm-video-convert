#!/bin/bash
set -e

APP="VideoNicer.app"
DEST="/Applications/$APP"

# Check ffmpeg is available
if ! /opt/homebrew/bin/ffmpeg -version &>/dev/null; then
    echo "Error: ffmpeg not found. Install it with: brew install ffmpeg"
    exit 1
fi

# Build Release
echo "Building $APP (Release)..."
xcodebuild -project VideoNicer.xcodeproj -scheme VideoNicer -configuration Release clean build 2>&1 | tail -5

# Find the built app
BUILD_DIR=$(xcodebuild -project VideoNicer.xcodeproj -scheme VideoNicer -configuration Release -showBuildSettings 2>/dev/null | grep -m1 '^\s*BUILT_PRODUCTS_DIR' | awk '{print $3}')
BUILT_APP="$BUILD_DIR/$APP"

if [ ! -d "$BUILT_APP" ]; then
    echo "Error: Build product not found at $BUILT_APP"
    exit 1
fi

# Install
echo "Installing to $DEST..."
rm -rf "$DEST"
cp -R "$BUILT_APP" "$DEST"

# Register with Launch Services
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$DEST"

echo "Installed '$APP' to /Applications/"
echo ""
echo "Done! Right-click any video file in Finder → Open With → VideoNicer"
