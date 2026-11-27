# GFA / BSV dev01 – Prüfnachweis und Praxistest

Stand 24.11.2026 | Plugin 0.1.0.dev01 | Status: Entwicklungsbuild, keine Produktionsfreigabe

## Automatisch geprüft

- Ruby-Syntax der eigenständigen Pluginquellen unter `plugins/gfa_bsv_creator/src/` und der Geometrietests mit Ruby 3.4 WASI kompiliert. Diese Laufzeit ist kein Nachweis für SketchUps eingebettetes Ruby.
- 15 ausgeführte Geometrie-Regressionsfälle: Quader 150 m³; Tetraeder 1/6 m³; Drehung, Spiegelung, Skalierung und große Koordinaten; Duplikate/Innenpunkte; ebene/linienförmige Auswahl; L-Kontur 7 m²/21 m³; konkave U-Kontur; Selbstschnitt/Selbstberührung; kollineare Zwischenpunkte; ungültige Höhen; GFA ohne Höhe; gedrehter Quader; Punktlimit.
- 15 unabhängige Referenzfälle mit SciPy 1.17.0 / Qhull verglichen: Zufallspunktwolken mit 8, 20, 50, 100, 200 Punkten und Skalierungen 1, 100, 0,01; Seed 31122. Relativer Volumenvergleich 1e-7, absolute Untergrenze 1e-8. Referenzdaten in `plugins/gfa_bsv_creator/test/geometry_oracle.json`.
- Sechs Collector-Vertragstests mit vereinfachten Doubles: verschachtelte gemeinsame Definitionen mit Skalierung/Spiegelung, unsichtbarer Teilbaum, Auswahlidentität im Digest, aktiver Bearbeitungskontext, leere/Mischselektion und Abweisung bereits erzeugter Messobjekte. Kein SketchUp-Laufzeitnachweis.
- JavaScript-Syntax mit `node --check`.
- Paketbau: ZIP-CRC, Loader-/Supportstruktur, Paketinhalt identisch zu `src/`, reproduzierbare SHA-256.

Reproduktion ohne SketchUp: Ruby verfügbar → `ruby -r ./plugins/gfa_bsv_creator/src/td_gfa_bsv_creator/building_metrics/geometry.rb plugins/gfa_bsv_creator/test/building_metrics_geometry_test.rb`. Optional Node 24 und Ruby-WASI-Prüfung: `npm install --no-save @ruby/3.4-wasm-wasi@2.10.1 @ruby/wasm-wasi@2.10.1`, danach `node plugins/gfa_bsv_creator/scripts/check_geometry.cjs`. Entwicklungsabhängigkeiten nicht mit ausliefern. Paketbau: `python plugins/gfa_bsv_creator/scripts/build.py`.

## Kompatibilität

| Umgebung | Status |
| --- | --- |
| Linux / Node 24 / Ruby 3.4 WASI | Syntax und reine Rechenlogik geprüft |
| SketchUp Desktop 2026 / Windows 11 | Hauptziel; Laufzeit offen |
| SketchUp Desktop 2025 | Für dieses Modul gesperrt; API-Sichtbarkeitsfehler vor 2026 |
| SketchUp 2026 / macOS | Nicht getestet |
| Web / iPad | Nicht unterstützt |

## Praxistest in SketchUp 2026

Alle folgenden Prüfungen sind **offen**. In einer Kopie des Modells prüfen; Ergebnisse mit SketchUp-Version/Wartungsstand, Windows-Version und Datum dokumentieren.

1. **Laden:** RBZ installieren, SketchUp neu starten. GFA / BSV Creator als eigene Extension und mit eigener Toolbar vorhanden; ohne Produktivitätswerkzeuge startbar. Zusätzlich beide Plugins gemeinsam installieren: keine doppelten Creator-Befehle, keine Ladefehler und keine Veränderung der bestehenden Objektinfo/Hervorhebung. Creator deaktivieren/deinstallieren; bestehende Werkzeuge weiterhin aufrufbar.
2. **Bekannter Quader:** Gruppe 10 × 5 × 3 m zeichnen. Auswählen → GFA/BSV → Auswahl übernehmen. Quader bei Winkel 0°, UK 0 m, OK 3 m: 150,00 m³. GFA: 50,00 m². Referenzpunkte entsprechend bei anderer Modelllage anpassen.
3. **Offene Struktur:** Vier Stützen und obere Träger mit eindeutigen Außenmaßen auswählen. Quader und 3D-Hülle vergleichen. BSV ist Raumhülle einschließlich Zwischenräumen. Hülle transparent prüfen und über Elementinformationen als Volumenkörper bestätigen.
4. **Konkave Kontur:** Grundrissmodus; Kontur `0;0 / 4;0 / 4;1 / 1;1 / 1;4 / 0;4` zeilenweise eingeben. GFA 7,00 m²; UK 2 m, OK 5 m → BSV 21,00 m³. Selbstüberschneidung eingeben: klare Ablehnung ohne Modelländerung.
5. **Drehung/Transformation:** Ausgangsquader global um 30° drehen. Quaderwinkel 30° → 150,00 m³; konvexe Hülle ebenfalls. Verschachtelte, skaliert/gespiegelt platzierte Kopien testen; mehrere Instanzen gemeinsamer Definition getrennt berücksichtigen.
6. **Sperren/Sichtbarkeit:** Gesperrte Quelle lesen; Quelle unverändert. Ausgeblendeten Ausleger/ausgeblendeten Tag testen; ausgelassene Teilobjekte werden angezeigt. „Ausgeblendete Objekte/Geometrie anzeigen“ beeinflusst die native Sichtbarkeitsauswertung und muss bewusst berücksichtigt werden. Quellgeometrie nicht anhand einer Schnittdarstellung verkürzen.
7. **Kontext/Fehler:** Leere oder nicht unterstützte Auswahl; offener Gruppen-/Komponentenkontext; ebenes Modell bei 3D-Hülle; zu kleine Hülle; Punktlimit. Verständliche Meldung, kein Teilkörper, keine Änderungen bestehender Attribute. Ausschließlich eigene Operation abbrechen.
8. **Veraltete Vorschau:** Auswahl übernehmen, Vorschau berechnen; Geometrie oder Auswahl ändern; Erstellung muss gestoppt bzw. neue Vorschau verlangt werden. Modellwechsel bei offenem Dialog abfangen. Keine Hülle im falschen Modell.
9. **Abbruch:** Vorschau → ESC; Werkzeugwechsel; Dialog schließen; erneutes Öffnen. Keine Vorschaugeometrie, Tags oder Materialien im Modell zurücklassen. „Messobjekt erstellen“ verlangt wieder eine gültige Vorschau.
10. **Undo/Redo:** Messobjekt erstellen, Undo, Redo. Ein Schritt; Quelle einschließlich Klassifizierung, GUIDs und BASF_General unverändert. Tag/Materialzustand mitprüfen.
11. **Nachbearbeitung:** Messkörper nativ ändern; Liste aktualisieren; aktueller Geometriewert. Geschlossenheit zerstören → ungültig, kein gültiger Volumenwert. GFA aus horizontaler Lage drehen → ungültig. Kopierte/geometrisch geänderte Gruppen und negative Skalierung prüfen.
12. **Liste/CSV:** Mehrere Gebäude/Ebenen, Namen mit Umlauten/Sonderzeichen. Filter und Zeilenwahl/Zoom testen. CSV in Excel öffnen: lesbare Umlaute, numerische Werte mit Dezimalkomma, korrekte Einheiten. Überlappende Körper werden nicht ungeprüft summiert.
13. **Leistung:** 10/100/1.000 Instanzen sowie ein reales Stahlmodell; Objekt-/Punktzahl, Analysezeit, Vorschauzeit und Körpererstellung getrennt aufzeichnen. Budgets dürfen keinen gekürzten Messkörper erzeugen. Größere Auswahl muss kontrolliert abgelehnt werden, wenn Limits erreicht sind.
14. **UI:** Fenstergröße und 150/200 % DPI, lange Namen, Tab-Reihenfolge, deutsche Dezimaleingaben und Tastaturbedienung. Vorschau bleibt bei Orbit/Zoom verständlich.

## Abgrenzung

Native API, Installation, UI, Sichtbarkeit, Transformationen im SketchUp-Modell, Performance und Undo/Redo können durch die reinen Rechentests nicht freigegeben werden. Folgestufen stehen in `docs/GFA_BSV_CREATOR.md`; keine IFC-/DIN-Abnahme in diesem Build.

Eigenständigkeit automatisch geprüft: RBZ-Wurzel besteht ausschließlich aus `td_gfa_bsv_creator.rb` und `td_gfa_bsv_creator/`; alle Paketdateien identisch zu den dedizierten Quellen. Keine Referenz auf Produktivitätswerkzeuge in Pluginquellen. Die nativen Koexistenz-/Deinstallationstests sind weiterhin offen.

Paketprüfung: `python plugins/gfa_bsv_creator/scripts/check_package.py` prüft Loader, unabhängige Paketstruktur, Quellenidentität, fehlende Laufzeitreferenzen zu Produktivitätswerkzeugen, ZIP-CRC und SHA-256. Offizielle Extension-/Toolbar-Referenzen am 24.11.2026 erneut geprüft.
