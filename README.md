# FORM3D — Photogrammetrie Studio

Photogrammetrie-App für Apple M-Series Macs. Aus 70 iPhone-Fotos wird automatisch ein druckfertiges 3D-Modell erzeugt.

![App Screenshot](screenshots/app-01-start.png)

## Features

- **Foto-Import**: Drag & Drop oder Datei-Picker — JPG, JPEG, PNG, HEIC
- **Photogrammetrie**: Apple RealityKit `PhotogrammetrySession` (Neural Engine + Metal) 
- **3D-Viewer**: Three.js mit OrbitControls — STL & OBJ laden, drehen, zoomen
- **Mesh-Ansicht**: Wireframe-Modus mit 4-Punkt-Beleuchtung
- **Export**: USDZ (AR Quick Look), OBJ (Blender/Maya), STL (3D-Druck)
- **Echtzeit-Log**: Fortschrittsanzeige mit Phase-Info während der Rekonstruktion

## Projekt-Inhalt

```
WS 3D-Modelle/
├── index.html              # App (alles-in-einer-Datei, kein Build-Schritt)
├── reconstruct.swift       # RealityKit Photogrammetrie (Swift CLI)
├── convert_model.swift     # USDZ → OBJ + STL Konverter (Swift CLI)
├── bali_guardian.usdz      # Fertiges 3D-Modell (312 MB, AR Quick Look)
├── bali_guardian.obj       # OBJ für Blender/Maya/Meshmixer (15 MB)
├── bali_guardian.stl       # STL für Bambu Lab / Cura / 3D-Druck (7.5 MB)
├── Texture_*.png           # PBR-Texturen (diffuse, normal, AO, roughness)
└── photos/                 # 70 iPhone-Fotos (IMG_6230–IMG_6299)
```

## App starten

```bash
open index.html
# oder per Browser: file:///Users/.../WS\ 3D-Modelle/index.html
```

Kein Server, kein Build. Einfach `index.html` im Browser öffnen.

Der Viewer lädt `bali_guardian.stl` automatisch (wenn im gleichen Ordner), alternativ über den Button **⬡ 3D-MODELL IN VIEWER LADEN**.

## Eigene Fotos rekonstruieren

### 1. Fotos aufnehmen

- Objekt von allen Seiten fotografieren (mind. 50 Fotos)
- Gleichmäßiger Abstand, konstante Belichtung
- Ordner `photos/` erstellen und Fotos ablegen

### 2. Swift CLI kompilieren

```bash
# Einmalig kompilieren
swiftc -framework RealityKit -framework Foundation reconstruct.swift -o reconstruct
swiftc -framework ModelIO -framework Foundation convert_model.swift -o convert_model
```

### 3. Rekonstruktion starten

```bash
./reconstruct ./photos ./mein_objekt.usdz
```

Läuft ~15–25 Min. auf M4 Mac. Erzeugt `.usdz` im angegebenen Pfad.

### 4. In OBJ + STL konvertieren

```bash
# Pfade in convert_model.swift anpassen, dann:
./convert_model
```

### 5. In App laden

STL-Datei per Button laden oder als `bali_guardian.stl` neben `index.html` ablegen.

## Technologien

| Komponente | Technologie |
|---|---|
| App | HTML/CSS/JS (Single File, kein Framework) |
| 3D-Rendering | [Three.js r0.150.0](https://threejs.org) |
| Photogrammetrie | Apple RealityKit `PhotogrammetrySession` |
| 3D-Konvertierung | Apple ModelIO `MDLAsset` |
| Shader | MeshPhongMaterial, ACESFilmicToneMapping |

## Voraussetzungen

- macOS 12.0+ (Monterey oder neuer) — für RealityKit
- Apple Silicon Mac (M1/M2/M3/M4) — empfohlen für Neural Engine
- Xcode Command Line Tools: `xcode-select --install`

## Das Modell

Das enthaltene Modell ist ein **Balinesischer Steinwächter** (Dvarapala), fotografiert mit 70 iPhone-Fotos im Halbkreis. Rekonstruiert in ~17 Minuten auf einem M4 MacBook Pro.

- Polygon-Auflösung: `detail: .full`
- Texturiertes PBR-Material (4 Texture-Maps)
- USDZ direkt in iOS/macOS AR Quick Look öffenbar

## Lizenz

MIT — freie Verwendung, auch kommerziell.
