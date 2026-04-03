import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Video Nicer")
                .font(.largeTitle)
                .fontWeight(.bold)

            dropZone
                .frame(width: 400, height: 200)

            if let url = appState.fileURL {
                HStack {
                    Image(systemName: "film")
                    Text(url.lastPathComponent)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .font(.callout)
                .foregroundStyle(.secondary)
            }

            Button(action: { appState.convert() }) {
                if appState.isConverting {
                    ProgressView()
                        .controlSize(.small)
                        .padding(.trailing, 4)
                    Text("Converting...")
                } else {
                    Label("Convert to MP4", systemImage: "arrow.triangle.2.circlepath")
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(appState.fileURL == nil || appState.isConverting)
            .keyboardShortcut(.return, modifiers: .command)

            if let result = appState.result {
                resultView(result)
            }
        }
        .padding(30)
        .frame(width: 460)
        .onChange(of: appState.autoConvert) {
            if appState.autoConvert {
                appState.autoConvert = false
                appState.convert()
            }
        }
    }

    private var dropZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 2, dash: [8])
                )
                .foregroundStyle(isTargeted ? .blue : .secondary)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isTargeted ? Color.blue.opacity(0.08) : Color.clear)
                )

            VStack(spacing: 8) {
                Image(systemName: "arrow.down.doc")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)
                Text("Drop a video file here")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers)
        }
    }

    @ViewBuilder
    private func resultView(_ result: AppState.ConversionResult) -> some View {
        switch result {
        case .success(let url):
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                VStack(alignment: .leading) {
                    Text("Conversion complete!")
                        .fontWeight(.medium)
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Reveal in Finder") {
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }
                .controlSize(.small)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)

        case .error(let message):
            HStack(alignment: .top) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
                Text(message)
                    .font(.callout)
                    .textSelection(.enabled)
                Spacer()
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
        }
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { data, _ in
            guard let data = data as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil),
                  AppState.supportedExtensions.contains(url.pathExtension.lowercased()) else {
                DispatchQueue.main.async {
                    self.appState.result = .error("Unsupported file type. Supported: \(AppState.supportedExtensions.sorted().joined(separator: ", "))")
                }
                return
            }
            DispatchQueue.main.async {
                self.appState.fileURL = url
                self.appState.result = nil
            }
        }
        return true
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
