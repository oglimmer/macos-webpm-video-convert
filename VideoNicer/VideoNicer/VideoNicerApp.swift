import SwiftUI

@Observable
class AppState {
    var fileURL: URL?
    var isConverting = false
    var result: ConversionResult?
    var autoConvert = false
    var launchedFromExtension = false

    enum ConversionResult {
        case success(URL)
        case error(String)
    }

    func convert() {
        guard let inputURL = fileURL, !isConverting else { return }
        isConverting = true
        result = nil

        let outputURL = inputURL.deletingPathExtension().appendingPathExtension("mp4")

        Task.detached {
            do {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")
                process.arguments = [
                    "-i", inputURL.path,
                    "-c:v", "libx264", "-crf", "23", "-preset", "medium",
                    "-c:a", "aac", "-b:a", "192k",
                    "-movflags", "+faststart",
                    "-y", outputURL.path
                ]

                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = pipe

                try process.run()
                process.waitUntilExit()

                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let outputText = String(data: data, encoding: .utf8) ?? ""

                if process.terminationStatus != 0 {
                    throw NSError(
                        domain: "VideoNicer",
                        code: Int(process.terminationStatus),
                        userInfo: [NSLocalizedDescriptionKey: "ffmpeg failed (exit \(process.terminationStatus)):\n\(outputText.suffix(500))"]
                    )
                }

                await MainActor.run {
                    self.isConverting = false
                    self.result = .success(outputURL)
                    if self.launchedFromExtension {
                        NSApplication.shared.terminate(nil)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isConverting = false
                    self.result = .error(error.localizedDescription)
                }
            }
        }
    }
}

@main
struct VideoNicerApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .onOpenURL { url in
                    let fileURL: URL
                    if url.scheme == "videonicerconvert" {
                        fileURL = URL(fileURLWithPath: url.path)
                        appState.launchedFromExtension = true
                    } else {
                        fileURL = url
                    }
                    guard fileURL.pathExtension.lowercased() == "webm" else { return }
                    appState.fileURL = fileURL
                    appState.result = nil
                    appState.autoConvert = true
                }
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Convert to MP4") {
                    appState.convert()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(appState.fileURL == nil || appState.isConverting)
            }
        }
    }
}
