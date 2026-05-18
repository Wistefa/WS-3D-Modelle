// convert_model.swift — USDZ → OBJ + STL via ModelIO
import ModelIO
import Foundation

let base = "/Users/stefanwilfried/Projekte/WS/WS 3D-Modelle"
let inputURL = URL(fileURLWithPath: "\(base)/bali_guardian.usdz")

print("📦 Lade USDZ...")
let asset = MDLAsset(url: inputURL)
asset.loadTextures()

let meshCount = asset.count
print("✅ \(meshCount) Objekt(e) geladen")

// OBJ exportieren
let objURL = URL(fileURLWithPath: "\(base)/bali_guardian.obj")
do {
    try asset.export(to: objURL)
    let size = (try? FileManager.default.attributesOfItem(atPath: objURL.path)[.size] as? Int64) ?? 0
    print("✅ OBJ gespeichert: \(objURL.path)")
    print("   Größe: \(size / 1024 / 1024) MB")
} catch {
    print("❌ OBJ Fehler: \(error.localizedDescription)")
}

// STL exportieren (für 3D-Druck)
let stlURL = URL(fileURLWithPath: "\(base)/bali_guardian.stl")
do {
    try asset.export(to: stlURL)
    let size = (try? FileManager.default.attributesOfItem(atPath: stlURL.path)[.size] as? Int64) ?? 0
    print("✅ STL gespeichert: \(stlURL.path)")
    print("   Größe: \(size / 1024 / 1024) MB")
} catch {
    print("❌ STL Fehler: \(error.localizedDescription)")
}

print("\n✅ Fertig — beide Dateien im Projektordner")
