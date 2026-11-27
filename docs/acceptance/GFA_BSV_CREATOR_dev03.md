# GFA / BSV Creator dev03 – Summenkompatibilität

Stand: 27.11.2026 | Version 0.1.0.dev03 | Entwicklungsbuild, nativer Praxistest offen

## Befund und Korrektur

Der Screenshot zeigt `uninitialized constant Array::Fixnum` während der Ausführung von dev02. Die Quellprüfung findet Array#sum-Aufrufe in Vektor-, Hüll- und Flächenberechnungen. Ein ersetztes Array#sum kann diesen Fehler auslösen. Der konkrete Anbieter einer solchen Überschreibung ist ohne Benutzer-Stacktrace nicht nachgewiesen; diese Änderung behauptet deshalb keinen identifizierten Fehler im SketchUp-Kern oder in einer bestimmten fremden Extension.

Alle Summenbildungen im Laufzeitcode wurden durch `Geometry.total` mit expliziter Iteration ersetzt. Keine globalen Monkey-Patches und keine Wiederherstellung der entfernten Konstante Fixnum. Diagnosemeldungen und Log enthalten nun zusätzlich `error.message`.

## Automatische Validierung

- In einer isolierten Ruby-3.4-WASI-Testlaufzeit wird Array#sum absichtlich durch eine Funktion ersetzt, die exakt die gemeldete NameError-Meldung auslöst. Diese Überschreibung ist ausschließlich Testcode und wird nicht ausgeliefert.
- Alle 15 Geometrie-Regressionsfälle und 15 unabhängigen Referenzvolumenvergleiche bestehen unter dieser Testbedingung.
- Die sechs Collector-Vertragstests und acht Startpfadtests bestehen ebenfalls.
- Quellprüfung verhindert verbleibende `.sum`-Aufrufe im Laufzeitcode; Ruby-Syntax, JavaScript-Syntax und eigenständige RBZ-Struktur geprüft.
- Paketbau prüft Quellenidentität, ZIP-CRC und SHA-256; Reproduzierbarkeit separat geprüft. Ältere Downloadpakete werden nicht überschrieben.

Reproduktion: `node plugins/gfa_bsv_creator/scripts/check_geometry.cjs` mit den im Skript genannten Entwicklungsabhängigkeiten; Build und Paketprüfung wie zuvor.

## Nativer Praxistest – offen

1. `SU_GFA_BSV_Creator_v0.1.0_dev03.rbz` installieren, SketchUp vollständig schließen und neu starten.
2. Creator-Titel muss 0.1.0.dev03 zeigen. Dieselbe Modellauswahl übernehmen: Höhen und Kontur sollen gefüllt werden.
3. BSV-Vorschau für Quader und konvexe Hülle berechnen und Messkörper erstellen; bekannten Prüfkörper 10 × 5 × 3 m mit 150 m³ vergleichen.
4. GFA-Vorschau/Erstellung und anschließende Ergebnisliste prüfen (50 m² beim selben Grundriss).
5. Undo/Redo und Parallelbetrieb mit den vorhandenen Erweiterungen prüfen. Quellen unverändert.
6. Bei weiteren Fehlern zeigt der Dialog jetzt die konkrete Ursache; Log mit Stacktrace befindet sich weiterhin im temporären Systemordner.

Die früheren Grenzen (keine automatische konkave Hülle, Quellenaktualisierung, Öffnungsvereinigung oder IFC-/DIN-Freigabe) bestehen fort. Geometrietests beweisen keine vollständige native SketchUp-Kompatibilität.
