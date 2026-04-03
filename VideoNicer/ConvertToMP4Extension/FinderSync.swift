import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    private static let supportedExtensions: Set<String> = ["webm", "mp4", "wmv", "avi", "mov", "mpg", "mpeg"]

    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        guard menuKind == .contextualMenuForItems else { return nil }

        guard let items = FIFinderSyncController.default().selectedItemURLs(),
              items.contains(where: { Self.supportedExtensions.contains($0.pathExtension.lowercased()) }) else {
            return nil
        }

        let menu = NSMenu(title: "VideoNicer")
        let item = NSMenuItem(
            title: "Convert to MP4",
            action: #selector(convertToMP4(_:)),
            keyEquivalent: ""
        )
        item.image = NSImage(systemSymbolName: "film", accessibilityDescription: nil)
        menu.addItem(item)
        return menu
    }

    @objc func convertToMP4(_ sender: Any?) {
        guard let items = FIFinderSyncController.default().selectedItemURLs() else { return }
        let videoFiles = items.filter { Self.supportedExtensions.contains($0.pathExtension.lowercased()) }

        for file in videoFiles {
            // Use custom URL scheme to pass file path to the main app.
            // This avoids sandbox restrictions on passing file URLs directly.
            var components = URLComponents()
            components.scheme = "videonicerconvert"
            components.path = file.path
            if let url = components.url {
                NSWorkspace.shared.open(url)
            }
        }
    }
}
