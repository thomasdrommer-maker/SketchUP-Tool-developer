# Auswahl hervorheben

Version 0.2.0.dev01 · 18.11.2026 · Auftraggeber: Tom

Entwicklungsbuild. Ziel: SketchUp Desktop 2026 / Windows 11. SketchUp-Laufzeittest offen. Voraussetzung: SketchUp 2023 oder neuer (`Sketchup::Overlay`).

## Bedienung

- Erweiterungen → TD Produktivitätswerkzeuge → **Auswahl hervorheben** schaltet die Anzeige ein/aus (Häkchen = aktiv), ebenso der orange Toolbar-Button. Zusätzlich im SketchUp-Overlays-Fenster schaltbar.
- **Auswahl hervorheben – Optionen**: Flächen füllen, Füllfarbe, Deckkraft (5–90 %), Randfarbe, Randstärke (1–8 Pixel). Werte werden in den SketchUp-Benutzervorgaben gespeichert.
- Die Hervorhebung ist unabhängig vom aktiven Werkzeug und folgt der Auswahl, Undo/Redo und Kontextwechseln.

## Umfang

- Gruppen und Komponenten (auch verschachtelt): alle sichtbaren Flächen halbtransparent gefüllt, alle sichtbaren, nicht weichen Kanten kräftig.
- Einzelne Flächen: Fläche und ihre Kanten. Einzelne Kanten: nur die Kante.
- Transformationen (Skalierung, Spiegelung, geöffneter Bearbeitungskontext) werden berücksichtigt.

## Grenzen

- Nur Anzeige: keine Modelländerung, keine Auswahl-/Undo-Wirkung, nicht pickbar und nicht exportierbar.
- Die Füllung liegt 1 mm vor und hinter jeder Fläche, um Z-Fighting zu vermeiden. Bei sehr großem Abstand zur Kamera kann dennoch Flackern auftreten.
- Obergrenze: 60 000 Dreiecke / 120 000 Kantenlinien; darüber wird gekürzt und ein Hinweis eingeblendet.
- Verdeckte Flächen sind verdeckt; Röntgen-/Drahtgittermodus nicht geprüft.
- Während Verschieben wird die Darstellung je Bild neu berechnet (bei bis zu 200 gewählten Objekten); bei großen Auswahlen kann das die Leistung mindern.
- API-Grundlage: `Sketchup::Overlay` (ab 2023.0, https://ruby.sketchup.com/Sketchup/Overlay.html, geprüft 18.11.2026).
