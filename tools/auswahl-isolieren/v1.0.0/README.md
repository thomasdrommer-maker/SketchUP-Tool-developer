# Auswahl isolieren – Vorversion 1.0.0

Bereitstellung am 16.11.2026: unverändertes Paket aus dem Auftrag vom 15.11.2026. Keine neue Funktionsentwicklung und keine Produktionsfreigabe.

[RBZ herunterladen](../../../..//downloads/SU_Auswahl_Isolieren_v1.0.0.rbz) (Dateiseite öffnen, dann Download raw file).

SHA-256: `8804986dcaeaf752a32fa26d8d76a854eb65964fa98440210fda4c6d6ff990d7`

## Installation und Bedienung

SketchUp Desktop: Fenster → Erweiterungsmanager → Erweiterung installieren → RBZ auswählen. Nicht entpacken. Gruppen/Komponenten auswählen → Rechtsklick → Auswahl isolieren. Erneut eingrenzen oder Isolation aufheben. Für ein Kürzel den Befehl Isolation umschalten zuordnen. Deinstallation über den Erweiterungsmanager, zuvor Isolation aufheben.

## Quellstand und Grenzen

`source/` enthält exakt Loader, Fachlogik und Anleitung des Pakets. Herkunft: in diesem Chat von OpenAI Codex für Tom erzeugt. Keine fremde Drittanbieter-Extension übernommen. Eine Repository-Lizenzfreigabe wird nicht vorweggenommen.

Diese eigenständige Vorversion nutzt `TomTools::SelectionIsolator`, noch nicht den vorgesehenen gemeinsamen Namensraum und Menürahmen. Keine Anpassung an den neuen Sammlungsrahmen in diesem Bereitstellungsauftrag. Änderungen an gemeinsamen Definitionen wirken auf alle Instanzen; dies wird bisher nur in der Anleitung erklärt. Szenenwechsel und manuelle Sichtbarkeitsänderungen können die Isolation beeinflussen. Vor Szenenspeicherung und Export Isolation aufheben.

## Prüfnachweis

- Im ursprünglichen Erstellungslauf: 16 Kernlogik-Prüfungen mit einem nachgebildeten SketchUp-API-Modell unter Ruby 3.3 bestanden (Mehrfachauswahl, Eingrenzung, Zustandswiederherstellung, Undo/Redo des Testmodells, verschachtelter Kontext, Umschalten, lose Geometrie abgewiesen).
- Bereitstellung: ZIP/RBZ-Struktur und Prüfsumme kontrolliert; Paketinhalt unverändert.
- Kein tatsächlicher SketchUp-Lauf. Installation, Menüs, reale Undo/Redo-Integration, gesperrte Objekte, gemeinsame Definitionen, Speichern/Neuladen und Leistung sind praktisch offen.
- SketchUp 2026 / Windows 11: Prüfziel, nicht freigegeben. SketchUp 2025 und weitere Plattformen: nicht geprüft. Die Angaben 2024–2026/macOS in der ursprünglichen Paket-Anleitung sind Zielangaben, kein Kompatibilitätsnachweis.

## Praxistest an Modellkopie

Zwei von mehreren Gruppen/Komponenten isolieren; ein vorher ausgeblendetes Objekt muss ausgeblendet bleiben. Auswahl weiter eingrenzen, aufheben, Rückgängig/Wiederholen testen. Innerhalb einer verschachtelten Gruppe wiederholen. Gespeicherte aktive Isolation schließen und neu öffnen, dann aufheben. Mehrfach verwendete Komponenten separat prüfen. Ergebnisse mit SketchUp-Wartungsstand und Betriebssystem dokumentieren.
