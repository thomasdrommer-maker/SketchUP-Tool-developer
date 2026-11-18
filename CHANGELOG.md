# Changelog

## Plugin 0.3.3.dev01 – 18.11.2026

- Fix: Start-Fehler (SyntaxError in selection_highlight/settings.rb) durch Sketchup.read_default. Einstellungen liegen jetzt als JSON unter %APPDATA%\TD_ProductivityTools. Gespeicherte Optionen werden dadurch einmalig auf Standard zurückgesetzt.

## Plugin 0.3.2.dev01 – 18.11.2026

- Objektinfo: Attributscanner und Anzeige lesen jetzt verschachtelte Dictionaries (IFC-PropertySets wie `BASF_General` unter `IFC 4/...`). Pfade werden als `A/B/C` geführt. Nur lesend. Praxistest in SketchUp offen.

## Plugin 0.3.1.dev01 – 18.11.2026

- Infobox und Optionsdialog zeigen die Plugin-Version.

## Plugin 0.3.0.dev01 – 18.11.2026

- Objektinfo: neues Feld IFC-Klasse und frei wählbare Attribute aus BASF_General und IFC-Wörterbüchern (Schlüssel werden aus dem Modell gelesen).
- Nur lesend: es werden keine Dictionaries angelegt oder geändert.
- Entwicklungsbuild; SketchUp-Praxistest offen.

## Plugin 0.2.0.dev01 – 18.11.2026

- Neu: Auswahl hervorheben als `Sketchup::Overlay` mit transparenter Flächenfüllung und kräftigen Kanten; nur Anzeige, keine Modelländerung.
- Ein/Aus per Menü, Toolbar und Overlays-Fenster; Farben, Deckkraft und Randstärke einstellbar.
- Entwicklungsbuild; SketchUp-Laufzeit und Leistung offen.

## Plugin 0.1.0.dev01 – 18.11.2026

- Minimaler gemeinsamer Extension-Rahmen mit Menü und Toolbar.
- Objektinfo am Cursor mit verzögertem Picking und eigener Infobox.
- Einzeln schaltbare Elementinformationen, Zielhierarchie, Schriftgröße, Position und gespeicherte Optionen.
- Kontextbezogene Größen bei skalierten und gespiegelten Vorfahren; keine Modelländerung.
- Reproduzierbarer RBZ-Bau, Prüfsumme und Praxistest-Anleitung.
- Entwicklungsbuild; SketchUp-Laufzeit, DPI und Leistung noch offen. IFC/BASF-Felder folgen separat.

## Dokumentation 1.0.0 – 15.11.2026

- Agentenauftrag mit Regeln für Modellintegrität, Kontext, Transaktionen, Bedienung und Lieferung.
- Entwicklungsauftrag mit Zielplattform, Anforderungen, Architektur, Leistungszielen und Abnahmekriterien.
- Vorgeschlagene Roadmap für Auswahl-, Sichtbarkeits-, Referenz- und Modellierwerkzeuge.
- Vorlagen für Werkzeugaufträge und Praxistests.
- README mit Einstieg und Startauftrag für Entwicklungsagenten.
