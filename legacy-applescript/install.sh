#!/bin/bash
set -e

APP="Convert to MP4.app"
DEST="/Applications/$APP"

# Check ffmpeg is available
if ! command -v ffmpeg &>/dev/null && ! /opt/homebrew/bin/ffmpeg -version &>/dev/null; then
    echo "Error: ffmpeg not found. Install it with: brew install ffmpeg"
    exit 1
fi

# Install the app
rm -rf "$DEST"
cp -R "$APP" "$DEST"

# Register with Launch Services so it appears in Open With
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$DEST"

echo "Installed '$APP' to /Applications/"
echo ""
echo "Done! Right-click any .webm file in Finder → Open With → Convert to MP4"
