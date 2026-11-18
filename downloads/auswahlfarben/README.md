# Auswahlfarbe in SketchUp ändern

Version 1.0.0 · Stand 16.11.2026 · Auftraggeber: Tom

Zwei einzelne Ruby-Konsolenbefehle zum besseren Erkennen der nativen Auswahl im aktiven Modell. Keine Extension-Installation erforderlich.

## Download

- [Auswahlfarbe_Magenta.rb](Auswahlfarbe_Magenta.rb) – RGB 255, 0, 255
- [Auswahlfarbe_Orange.rb](Auswahlfarbe_Orange.rb) – RGB 255, 128, 0

Datei auf GitHub öffnen und „Download raw file“ (Pfeil nach unten) wählen.

## Schnell anwenden

SketchUp Desktop öffnen und die Ruby-Konsole aufrufen (unter Windows je nach Version unter Fenster → Entwickler → Ruby-Konsole). Genau einen der folgenden Befehle einfügen und Enter drücken:

Magenta:

```ruby
Sketchup.active_model.rendering_options["HighlightColor"] = Sketchup::Color.new(255, 0, 255)
```

Orange:

```ruby
Sketchup.active_model.rendering_options["HighlightColor"] = Sketchup::Color.new(255, 128, 0)
```

Alternativ die heruntergeladene Datei in der Ruby-Konsole laden, zum Beispiel:

```ruby
load "C:/Users/DEIN_NAME/Downloads/Auswahlfarbe_Magenta.rb"
```

Den Beispielpfad durch den tatsächlichen Speicherort ersetzen; unter Windows Schrägstriche verwenden. Die Dateien gehören nicht in den Plugins-Ordner und werden nicht im Extension Manager installiert.

## Wirkung und Wiederherstellung

Die zuletzt gesetzte Farbe gilt für die gesamte native Auswahl des aktiven Modells. Die Befehle ändern ausschließlich die Darstellungsoption HighlightColor; sie fügen keine Rahmen, Beschriftungen oder Durchsicht durch verdeckende Bauteile hinzu. Zum dauerhaften Übernehmen den aktuellen Stil aktualisieren und das Modell speichern. Für neue Modelle die Einstellung zusätzlich in einer Modellvorlage speichern.

Vorherige Farbe bei Bedarf vor dem ersten Wechsel in der Ruby-Konsole sichern:

```ruby
auswahlfarbe_vorher = Sketchup.active_model.rendering_options["HighlightColor"]
```

Im selben Modell und derselben Konsolensitzung wiederherstellen:

```ruby
Sketchup.active_model.rendering_options["HighlightColor"] = auswahlfarbe_vorher
```

## Prüfstand und Praxistest

- API-Nachweis: HighlightColor und der Schreibzugriff auf RenderingOptions sind in der offiziellen Referenz dokumentiert; geprüft am 16.11.2026: https://ruby.sketchup.com/Sketchup/RenderingOptions.html
- Ziel: SketchUp Desktop 2026 unter Windows 11; SketchUp 2025 als weiteres Prüfziel.
- Kein SketchUp-Laufzeittest verfügbar; beide Zielversionen praktisch noch ungeprüft. Keine Produktionsfreigabe.
- Praxistest: Einige Gruppen und Komponenten auswählen, Magenta anwenden und sichtbare Auswahlfarbe kontrollieren; anschließend Orange anwenden und erneut kontrollieren. Wiederherstellung sowie Speichern und erneutes Öffnen mit aktualisiertem Stil prüfen.
- RBZ, Menü-/Toolbar-Registrierung und Geometrieprüfung sind für diese zwei ausdrücklich beauftragten Konsolenbefehle nicht zutreffend.
