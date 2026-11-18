# Prüfprotokoll Auswahl hervorheben 0.2.0.dev01

Stand: 18.11.2026. Entwicklungsbuild, keine Produktionsfreigabe.

## Automatische Prüfung

- Ruby-Quellen mit tree-sitter-ruby ohne ERROR/MISSING geprüft. Kein Ruby-Interpreter in dieser Umgebung; Ausführung offen.
- RBZ-Struktur, ZIP-CRC und bytegleiche Quellen durch `scripts/build.py` geprüft.
- Quellprüfung: keine Modellschreib-API, keine Modelländerung in Overlay-/Observer-Callbacks.

## SketchUp-Praxistest – alle Schritte offen

| Umgebung | Stand |
|---|---|
| SketchUp 2026 / Windows 11 | Offen |
| SketchUp 2025 | Offen; nicht freigegeben |

1. Installieren, Neustart: Menü, Toolbar mit zwei Buttons, Overlay „TD Auswahl hervorheben“ im Overlays-Fenster, keine Ruby-Fehler.
2. Würfel als Gruppe auswählen: Flächen orange transparent, Kanten rot und kräftig. Abwählen: Hervorhebung verschwindet.
3. Einzelne Fläche, einzelne Kante, Mehrfachauswahl, Komponente mit mehrfach platzierter Definition: nur gewählte Instanzen hervorgehoben.
4. Verschachtelt, skaliert (2×3×4), gespiegelt, im geöffneten Bearbeitungskontext: Hervorhebung deckungsgleich mit Geometrie.
5. Z-Fighting prüfen: Nah, fern, schräg; Röntgen- und Drahtgittermodus.
6. Verschieben/Drehen einer Auswahl, Undo/Redo, Löschen, Tag ausblenden: Anzeige folgt, keine Fehler.
7. Ein/Aus per Menü, Toolbar und Overlays-Fenster; Optionen ändern, SketchUp neu starten: Einstellungen bleiben.
8. Modellwechsel, neues Modell, zwei Modelle: je Modell ein Overlay, keine Doppelungen.
9. Vorher/nachher Geometrie, Materialien, Dictionaries, Auswahl, Undo-Stapel, Speicherstatus: unverändert.
10. Leistung: Auswahl mit ca. 1 000 / 20 000 / über 60 000 Dreiecken; Hardware, Modellgröße, Bildrate und Hinweis „gekürzt“ dokumentieren.
