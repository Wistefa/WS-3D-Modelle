// reconstruct.swift — Photogrammetrie mit Apple RealityKit (M4 optimiert)
// Verwendung: swift reconstruct.swift [input_ordner] [output.obj|.usdz|.stl]

import RealityKit
import Foundation

guard #available(macOS 12.0, *) else {
    print("❌ Benötigt macOS 12.0+"); exit(1)
}

let args       = CommandLine.arguments
let inputPath  = args.count > 1 ? args[1] : "./photos"
let outputPath = args.count > 2 ? args[2] : "./bali_guardian.usdz"

let inputURL  = URL(fileURLWithPath: inputPath,  isDirectory: true)
let outputURL = URL(fileURLWithPath: outputPath, isDirectory: false)

// Bilder zählen
let images = (try? FileManager.default.contentsOfDirectory(
    at: inputURL, includingPropertiesForKeys: nil)
    .filter { ["jpg","jpeg","png","heic"].contains($0.pathExtension.lowercased()) }) ?? []

print("╔══════════════════════════════════════════╗")
print("║   FORM3D — Apple RealityKit Rekonstruktion ║")
print("╠══════════════════════════════════════════╣")
print("║ Bilder:   \(images.count) Fotos".padEnd(44) + "║")
print("║ Input:    \(inputPath.suffix(36))".padEnd(44) + "║")
print("║ Output:   \(outputPath.suffix(36))".padEnd(44) + "║")
print("╚══════════════════════════════════════════╝\n")

if images.isEmpty {
    print("❌ Keine Bilder in: \(inputPath)"); exit(1)
}

// Session konfigurieren
var config = PhotogrammetrySession.Configuration()
config.featureSensitivity = .high
config.sampleOrdering     = .sequential  // Fotos sind im Kreis aufgenommen
config.isObjectMaskingEnabled = false    // kein grüner Screen-Hintergrund

let session: PhotogrammetrySession
do {
    session = try PhotogrammetrySession(input: inputURL, configuration: config)
    print("✅ Session erstellt · Metal + Neural Engine aktiv\n")
} catch {
    print("❌ Session-Fehler: \(error.localizedDescription)")
    exit(1)
}

// Anfrage: Vollauflösung
let request = PhotogrammetrySession.Request.modelFile(url: outputURL, detail: .full)

Task {
    do {
        try session.process(requests: [request])
        var lastPct = -1

        for try await output in session.outputs {
            switch output {

            case .requestProgress(_, let fraction):
                let pct = Int(fraction * 100)
                if pct != lastPct {
                    lastPct = pct
                    let filled = pct / 5
                    let bar    = String(repeating: "▓", count: filled)
                              + String(repeating: "░", count: 20 - filled)
                    print("\r  [\(bar)] \(pct)%  ", terminator: "")
                    fflush(stdout)
                }

            case .requestProgressInfo(_, let info):
                if let stage = info.processingStage {
                    let name: String
                    switch stage {
                    case .preProcessing:   name = "Vorverarbeitung"
                    case .imageAlignment:  name = "Bild-Ausrichtung (SfM)"
                    case .pointCloudGeneration: name = "Punktwolke"
                    case .meshGeneration:  name = "Mesh-Erzeugung"
                    case .textureMapping:  name = "Textur-Mapping"
                    @unknown default:      name = "Verarbeitung"
                    }
                    print("\n\n📍 Phase: \(name)")
                }

            case .requestComplete(_, let result):
                print("\n")
                switch result {
                case .modelFile(let url):
                    print("✅ 3D-Modell gespeichert: \(url.path)")
                    let size = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0
                    print("   Dateigröße: \(size / 1024) KB")
                @unknown default:
                    print("✅ Fertig")
                }

            case .processingComplete:
                print("\n╔══════════════════════════════════════════╗")
                print("║   ✅ REKONSTRUKTION ABGESCHLOSSEN!        ║")
                print("║                                           ║")
                print("║   Öffnen mit:                             ║")
                print("║   • Quick Look (Leertaste im Finder)      ║")
                print("║   • Preview.app (doppelklick auf .usdz)   ║")
                print("║   • Für 3D-Druck: Datei in Bambu/Cura     ║")
                print("╚══════════════════════════════════════════╝")
                exit(0)

            case .requestError(_, let error):
                print("\n❌ Fehler: \(error.localizedDescription)")
                exit(1)

            case .processingCancelled:
                print("\n⚠️  Abgebrochen")
                exit(1)

            default:
                break
            }
        }
    } catch {
        print("\n❌ Fehler: \(error.localizedDescription)")
        exit(1)
    }
}

dispatchMain()

extension String {
    func padEnd(_ n: Int) -> String {
        let s = self.prefix(n - 1)
        return String(s) + String(repeating: " ", count: max(0, n - s.count))
    }
}
