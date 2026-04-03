# Video Nicer

Convert `.webm` files to `.mp4` on macOS using ffmpeg.

## Prerequisites

- macOS 14+ (VideoNicer targets macOS 26 Tahoe)
- [ffmpeg](https://ffmpeg.org/) installed via Homebrew:
  ```
  brew install ffmpeg
  ```

## VideoNicer (recommended)

A native SwiftUI app with drag-and-drop UI and a Finder context menu extension.

### Build & Install

```bash
cd VideoNicer
./oglimmer.sh
```

This builds a Release build, copies it to `/Applications`, and registers it with Launch Services.

Or open `VideoNicer/VideoNicer.xcodeproj` in Xcode and build/run from there.

### Enable the Finder Extension

After installing, enable the Finder context menu integration:

1. Open **System Settings** → **Login Items & Extensions** → **Finder Extensions**
2. Enable **ConvertToMP4Extension**

### Usage

**Context menu:** Right-click any `.webm` file in Finder → **Convert to MP4**. The app opens, converts, and closes automatically. On error it stays open to show what went wrong.

**Drag and drop:** Open VideoNicer, drop a `.webm` file onto the window, click Convert (or press **Cmd+Return**).

**Open With:** Right-click a `.webm` → **Open With** → **VideoNicer**.

### Conversion Settings

- Video: H.264 (`libx264`), CRF 23, medium preset
- Audio: AAC, 192 kbps
- `faststart` flag enabled for web streaming

Output is saved alongside the original file.

### Uninstall

```bash
rm -rf /Applications/VideoNicer.app
```

Then disable or remove the Finder extension in **System Settings** → **Login Items & Extensions** → **Finder Extensions**.

---

## Convert to MP4.app (legacy)

A minimal AppleScript applet — no UI, just right-click → Open With. Lives in `legacy-applescript/`.

### Install

```bash
cd legacy-applescript
./install.sh
```

### Usage

Right-click any `.webm` file in Finder → **Open With** → **Convert to MP4**. A notification appears when done.

### Uninstall

```bash
rm -rf "/Applications/Convert to MP4.app"
```
