# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A macOS app for converting `.webm` files to `.mp4` using ffmpeg. Two implementations exist:

1. **`VideoNicer/`** — The main SwiftUI app with drag-and-drop UI and a Finder Sync Extension for right-click context menu integration.
2. **`legacy-applescript/`** — The original AppleScript applet (headless, "Open With" only).

## Prerequisites

- macOS 26 (Tahoe), ffmpeg installed via Homebrew (`brew install ffmpeg`)
- The app hardcodes the ffmpeg path to `/opt/homebrew/bin/ffmpeg` (Apple Silicon)

## Build & Install

```bash
# Build Release and install to /Applications
cd VideoNicer && ./oglimmer.sh

# Or build via xcodebuild
xcodebuild -project VideoNicer/VideoNicer.xcodeproj -scheme VideoNicer build

# Legacy AppleScript version
cd legacy-applescript && ./install.sh
```

After installing VideoNicer, the Finder extension must be enabled manually:
**System Settings → Login Items & Extensions → Finder Extensions → ConvertToMP4Extension**

## Architecture

### VideoNicer (`VideoNicer/`)

SwiftUI app with two targets:

**Main app (`VideoNicer/VideoNicer/`)**
- **`VideoNicerApp.swift`** — App entry point. Owns `AppState` (shared `@Observable` model). Handles `onOpenURL` for both file URLs (Open With) and `videonicerconvert://` URLs (from the Finder extension). Auto-quits on success when launched from the extension; stays open on error.
- **`ContentView.swift`** — Drop zone UI, file validation, result display. Reads `AppState` via `@Environment`.
- **`Info.plist`** — Registers for `.webm` files and the `videonicerconvert` URL scheme.
- App sandbox is **disabled** (required for `Process` to call ffmpeg).
- Conversion: H.264 CRF 23 medium, AAC 192k, faststart.

**Finder Sync Extension (`VideoNicer/ConvertToMP4Extension/`)**
- **`FinderSync.swift`** — Monitors `/` (all volumes). Shows "Convert to MP4" context menu item for `.webm` files. Opens `videonicerconvert:///path/to/file.webm` URL to hand off to the main app (avoids sandbox restrictions on passing file URLs directly).
- Extension is sandboxed (required for all app extensions).

### Legacy AppleScript (`legacy-applescript/`)

- `Convert to MP4.app/` — Compiled applet. Script at `Contents/Resources/Scripts/main.scpt`.
- `install.sh` — Copies to `/Applications` and runs `lsregister`.
