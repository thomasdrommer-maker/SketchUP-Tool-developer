# Prüfprotokoll Objektinfo 0.1.0.dev01

Stand: 18.11.2026. Entwicklungsbuild, keine Produktionsfreigabe.

## Automatische Prüfung

- Ruby-Quellen mit tree-sitter-ruby auf vollständige Syntaxbäume ohne ERROR/MISSING geprüft. Kein Ruby-Interpreter in dieser Umgebung; `ruby -c` und Ausführung offen.
- JavaScript des Optionsdialogs mit Node `--check` geprüft.
- ZIP-CRC, erwartete Loader-/Supportstruktur und bytegleiche Quellen im Paket geprüft.
- Reproduzierbarkeit: zwei Bauten ergeben dieselbe SHA-256-Prüfsumme.
- Quellprüfung: keine Modellschreib-API, keine globale Modellrekursion, Timer mit Kontext-/Generationsprüfung.

## SketchUp-Praxistest – alle Schritte offen

| Umgebung | Stand |
|---|---|
| SketchUp 2026 / Windows 11 / eingebettetes Ruby / SP und Prüfer noch einzutragen | Offen |
| SketchUp 2025 / Windows / eingebettetes Ruby | Offen; nicht freigegeben |
| macOS | Nicht geprüft; nicht zugesichert |

1. Installieren, Neustart: genau ein Menü und eine Toolbar, keine Ruby-Fehler. Start über Menü und Button.
2. Würfel 1 m³ als Gruppe und Komponente: Hover zeigt korrekten Typ/Namen/Tag/Material und 1,0000 m³ (Dezimalpunkt im Build). Keine Auswahländerung, kein neuer Undo-Eintrag, Speicherstatus unverändert.
3. Gleiche Definition mehrfach platzieren, andere Instanznamen/Tags/Materialien: jeweilige Instanz korrekt. Sperre aktivieren und anzeigen.
4. Gruppe verschachteln, Vorfahr skalieren (2×3×4): Volumen 24 m³. Gespiegelter Vorfahr: Betrag weiterhin korrekt. Im geöffneten Bearbeitungskontext wiederholen. Transformierte Fläche/Kante separat prüfen.
5. Zielhierarchie durchschalten: innerstes Bauteil / äußerste Baugruppe im Kontext / rohe Fläche oder Kante. Nicht geschlossene Geometrie: „Kein Volumenkörper“. Keine rekursive Baugruppensumme.
6. Alle Felder einzeln umschalten, leere Angaben ein-/ausblenden, lange Unicode-Namen, mehrzeilige Beschreibung, Schrift 10/24, Verzögerung 0/400/2000 ms, Ecke/Cursor, kleine Ansichtsfenster und 100/150/200 % Windows-Skalierung prüfen.
7. Optionen schließen/abbrechen/speichern, mehrfach öffnen, SketchUp neu starten: gespeicherte Auswahl bleibt erhalten; TAB öffnet Optionen.
8. Schnelle Mausbewegungen, leere Modellfläche, Ansichtsrand, Cursor außerhalb des Modellfensters, Orbit/Pan/Zoom, ESC, Werkzeugwechsel, Modellwechsel, Undo/Redo und Löschen während Wartezeit: keine veraltete Infobox, keine Fehler, kein verbleibender Timer.
9. Verdeckt liegende Objekte, Röntgen, ausgeblendete Geometrie, Tags und geöffnete Komponente prüfen: Zielobjekt stimmt mit SketchUps Pick-Verhalten überein.
10. Vorher/nachher Namen, GUIDs, IFC/BASF-Dictionaries, Geometrie, Materialien und Auswahl vergleichen: unverändert. Zusammenarbeit mit BDM und IFC Manager prüfen.
11. Leistungsstufen aus `docs/OBJEKTINFO.md` messen und Hardware, Modellgröße, Verschachtelung, Median und Maximum dokumentieren.

Undo/Redo als eigene Schreibfunktion und IFC-Exportausschluss sind nicht zutreffend: Werkzeug schreibt keine Modelldaten und exportiert nicht. In einem produktiven Modell erst nach den obigen Tests einsetzen.
