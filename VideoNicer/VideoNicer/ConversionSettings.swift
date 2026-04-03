import Foundation

@Observable
class ConversionSettings {
    static let shared = ConversionSettings()

    /// Video quality: 1 (best) to 5 (smallest file). Maps to CRF 18–32.
    var videoQuality: Int {
        didSet { UserDefaults.standard.set(videoQuality, forKey: "videoQuality") }
    }

    /// Conversion speed: 1 (fastest) to 3 (slowest/best compression).
    var conversionSpeed: Int {
        didSet { UserDefaults.standard.set(conversionSpeed, forKey: "conversionSpeed") }
    }

    /// Audio quality: 1 (low) to 3 (high). Maps to 96k / 192k / 320k.
    var audioQuality: Int {
        didSet { UserDefaults.standard.set(audioQuality, forKey: "audioQuality") }
    }

    private init() {
        let defaults = UserDefaults.standard
        // Register defaults on first launch
        defaults.register(defaults: [
            "videoQuality": 3,
            "conversionSpeed": 2,
            "audioQuality": 2,
        ])
        self.videoQuality = defaults.integer(forKey: "videoQuality")
        self.conversionSpeed = defaults.integer(forKey: "conversionSpeed")
        self.audioQuality = defaults.integer(forKey: "audioQuality")
    }

    // MARK: - ffmpeg argument mapping

    var crfValue: String {
        // 1=18 (best), 2=21, 3=23, 4=28, 5=32 (smallest)
        let table = [1: "18", 2: "21", 3: "23", 4: "28", 5: "32"]
        return table[videoQuality] ?? "23"
    }

    var preset: String {
        switch conversionSpeed {
        case 1: return "fast"
        case 2: return "medium"
        case 3: return "slow"
        default: return "medium"
        }
    }

    var audioBitrate: String {
        switch audioQuality {
        case 1: return "96k"
        case 2: return "192k"
        case 3: return "320k"
        default: return "192k"
        }
    }

    var videoQualityLabel: String {
        switch videoQuality {
        case 1: return "Excellent"
        case 2: return "High"
        case 3: return "Good (default)"
        case 4: return "Fair"
        case 5: return "Low (small file)"
        default: return "Good"
        }
    }

    var conversionSpeedLabel: String {
        switch conversionSpeed {
        case 1: return "Fast (larger file)"
        case 2: return "Balanced (default)"
        case 3: return "Slow (smaller file)"
        default: return "Balanced"
        }
    }

    var audioQualityLabel: String {
        switch audioQuality {
        case 1: return "Low (96 kbps)"
        case 2: return "Normal (192 kbps)"
        case 3: return "High (320 kbps)"
        default: return "Normal"
        }
    }
}
