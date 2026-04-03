import SwiftUI

struct SettingsView: View {
    @State private var settings = ConversionSettings.shared

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Video Quality")
                        .fontWeight(.medium)
                    Slider(
                        value: Binding(
                            get: { Double(settings.videoQuality) },
                            set: { settings.videoQuality = Int($0) }
                        ),
                        in: 1...5,
                        step: 1
                    )
                    HStack {
                        Text("Smaller file")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Higher quality")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(settings.videoQualityLabel)
                        .font(.callout)
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 4)
            } header: {
                Label("Video", systemImage: "film")
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Conversion Speed")
                        .fontWeight(.medium)
                    Picker("", selection: $settings.conversionSpeed) {
                        Text("Fast").tag(1)
                        Text("Balanced").tag(2)
                        Text("Slow").tag(3)
                    }
                    .pickerStyle(.segmented)
                    Text(settings.conversionSpeedLabel)
                        .font(.callout)
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 4)
            } header: {
                Label("Speed", systemImage: "gauge.with.dots.needle.67percent")
            } footer: {
                Text("Slower conversion produces smaller files at the same quality.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Audio Quality")
                        .fontWeight(.medium)
                    Picker("", selection: $settings.audioQuality) {
                        Text("Low").tag(1)
                        Text("Normal").tag(2)
                        Text("High").tag(3)
                    }
                    .pickerStyle(.segmented)
                    Text(settings.audioQualityLabel)
                        .font(.callout)
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 4)
            } header: {
                Label("Audio", systemImage: "speaker.wave.2")
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 420)
    }
}

#Preview {
    SettingsView()
}
