import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        guard menuKind == .contextualMenuForItems else { return nil }

        guard let items = FIFinderSyncController.default().selectedItemURLs(),
              items.contains(where: { $0.pathExtension.lowercased() == "webm" }) else {
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
        let webmFiles = items.filter { $0.pathExtension.lowercased() == "webm" }

        for file in webmFiles {
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
