# GFA / BSV Creator 0.1.0.dev02 – Startkorrektur

Stand: 27.11.2026. Entwicklungsbuild; native SketchUp-Prüfung weiterhin offen.

## Fehler und Korrektur

Der Nutzer meldet eine Versionssperre trotz SketchUp 2026 Desktop. Ursache im dev01: `Sketchup.version.to_i < 2026` vergleicht die interne Hauptversion 26 mit der Jahreszahl 2026. dev02 akzeptiert numerische Versionszeichenfolgen mit Hauptversion 26; andere Hauptversionen bleiben gesperrt. Die Ablehnung zeigt die tatsächlich erkannte interne Version an.

Offizielle API-Referenz am 27.11.2026 geprüft: https://ruby.sketchup.com/Sketchup.html#version-class_method – die Methode liefert eine dezimale Versionszeichenfolge.

## Automatisch geprüft

- 8 Tests des tatsächlichen `BuildingMetrics.open`-Startpfads mit Host-/UI-Doubles: 26, 26.0, 26.0.429, 26.1.123 öffnen den simulierten Dialog; 25.0.0, 27.0.0, 2026 und ungültige Zeichenfolgen werden mit Diagnose abgewiesen.
- Alle bisherigen 36 Geometrie-/Referenz-/Collector-Prüfungen bestanden.
- Ruby-Syntax in Ruby 3.4 WASI; JavaScript-Syntax, Paketstruktur, Quellenidentität, Unabhängigkeit, ZIP-CRC und SHA-256 geprüft.
- Reproduzierbarer Paketbau; dev01-Paket unverändert erhalten.

Reproduktion: `node plugins/gfa_bsv_creator/scripts/check_geometry.cjs` mit den dort dokumentierten Ruby-WASI-Entwicklungsabhängigkeiten. Build und Paketprüfung wie im dev01-Protokoll.

## Praxistest

1. `SU_GFA_BSV_Creator_v0.1.0_dev02.rbz` über den Erweiterungsmanager über die bestehende Creator-Version installieren.
2. SketchUp vollständig beenden und neu starten, damit geladene Ruby-Dateien ersetzt werden.
3. Im Erweiterungsmanager Version 0.1.0.dev02 prüfen.
4. In SketchUp Desktop 2026 den Creator öffnen: keine Versionssperre; Dialog muss erscheinen.
5. Den vorhandenen Geometrie-/Undo-/Koexistenz-Praxistest aus [dev01](GFA_BSV_CREATOR_dev01.md) fortsetzen.

Die simulierten Starttests ersetzen keinen Test des nativen HtmlDialog oder der Körpererstellung in SketchUp.
