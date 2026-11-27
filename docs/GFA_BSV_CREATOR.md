# GFA / BSV aus Modellobjekten

Version 0.1.0.dev03 | 27.11.2026 | Auftraggeber Tom | Entwicklungsbuild, SketchUp-Praxistest offen

## Ziel und Lieferumfang

**Eigenständiges Plugin „GFA / BSV Creator“.** Eine vorhandene Objektauswahl wird in eine geometrisch prüfbare Messfläche (GFA, m²) oder eine geschlossene Umhüllung (BSV, m³) überführt. Eigene Extension mit eigenem Menü und Toolbar; TD Produktivitätswerkzeuge und BDM werden nicht benötigt und sind nicht im Paket enthalten.

SketchUp bietet nativ Flächen, Volumenkörper und Solid Tools. Dieses Werkzeug ergänzt die Ableitung einer gemeinsamen Umhüllung aus offenen, getrennten und verschachtelten Modellobjekten sowie Dokumentation und Auswertung dieser Messobjekte.

## Installation und schneller Ablauf

1. `downloads/SU_GFA_BSV_Creator_v0.1.0_dev03.rbz` herunterladen; im Erweiterungsmanager installieren und SketchUp neu starten.
2. Auf Modellebene Gruppen, Komponenten, Flächen oder Kanten auswählen. Ein geöffneter Bearbeitungskontext muss zuvor verlassen werden.
3. Erweiterungen → GFA / BSV Creator → **GFA / BSV Creator öffnen**; alternativ Toolbar oder Kontextmenü.
4. **Aktuelle Auswahl übernehmen**. Gebäude und Ebene/Bereich eingeben.
5. Verfahren auswählen und Begrenzung prüfen.
6. **Vorschau berechnen**. Im Modell transparent dargestellte Umhüllung prüfen; im Dialog steht der Wert mit zwei Nachkommastellen. Orbit/Zoom über mittlere Maustaste möglich. Wechsel zu einem anderen Werkzeug oder ESC beendet die Vorschau.
7. **Messobjekt erstellen**. Es entsteht eine neue Gruppe auf Modellebene; ein Undo-Schritt nimmt die gesamte Erstellung zurück. Keine dauerhafte Vorschaugeometrie.
8. Ergebniszeile auswählen, um das Messobjekt im Modell auszuwählen und heranzuzoomen. CSV speichert alle Messobjekte der Modellebene (nicht nur gefilterte Zeilen), mit Semikolon, Dezimalkomma und UTF-8-BOM für Excel.

## Verfahren und Messregeln

| Verfahren | GFA | BSV | Begrenzung |
| --- | --- | --- | --- |
| Ausgerichteter Quader / Rechteck | horizontales umschließendes Rechteck | Rechteck × Höhe | Winkel um globale Z-Achse wird eingegeben; keine automatische Optimierung |
| Konvexe 3D-Hülle | nicht vorgesehen | konvexe Hülle tatsächlicher Geometriepunkte | Rücksprünge, Höfe und Zwischenräume werden überbrückt; keine Eingabe von Höhen |
| Bearbeitbare Grundrisskontur | horizontale Polygonfläche | senkrechtes Prisma | Startkontur ist die konvexe XY-Projektion der Auswahl; konkave Kontur manuell über Koordinaten bearbeitbar |

Unter- und Oberkante werden aus globalen Z-Extremwerten vorgeschlagen. GFA liegt auf der eingegebenen Unterkante/Ebene. Länge in Dialogfeldern ist ausdrücklich **Meter**; Dezimalpunkt und Dezimalkomma sind möglich. Winkel in Grad. Im Kontureditor eine Zeile je Eckpunkt: `X ; Y`. Punkte umlaufend eingeben, die letzte Verbindung wird automatisch geschlossen. Beispiel einer L-Kontur: `(0;0), (4;0), (4;1), (1;1), (1;4), (0;4)` → 7 m²; zwischen 2 m und 5 m → 21 m³.

Das Werkzeug umhüllt immer die **gesamte Auswahl gemeinsam**. Getrennte Strukturen separat auswählen, wenn der Zwischenraum nicht eingeschlossen werden soll. Anbauteile, Konsolen und Geländer bei Bedarf vor dem Übernehmen abwählen. Es gibt keine stillschweigende Ausreißerunterdrückung.

GFA ist eine geometrische horizontale Messfläche. Die Gebäudesumme über mehrere Ebenen und die fachliche Berücksichtigung von Öffnungen sind gesondert festzulegen. BSV ist umgrenzter Raum einschließlich Zwischenräumen, keine Summe der Materialvolumina. DIN-277-Konformität oder eine generelle Gleichsetzung von GFA/BSV mit BGF/BRI wird nicht zugesichert.

## Quellgeometrie und Sicherheit

- Quellen werden ausschließlich gelesen. Keine Änderung bestehender Geometrie, Materialien, Klassifizierungen, GUIDs oder BASF_General.
- Tatsächliche Eckpunkte statt Bounding-Box-Ecken; Instanztransformationen werden über die Hierarchie verkettet. Gemeinsame Definitionen werden je platzierter Instanz ausgewertet, nicht verändert.
- Sichtbarkeit gemäß SketchUp `drawing_element_visible?`, einschließlich Tag-/Objektzuständen und Anzeigeoptionen für ausgeblendete Geometrie. Schnittdarstellung schneidet die Quelldaten nicht geometrisch zu. Ausgeblendete Teilbäume werden gezählt und angezeigt.
- Gesperrte Quellobjekte dürfen gelesen werden. Neues Messobjekt entsteht außerhalb ihrer Definitionen auf Modellebene.
- Vor Vorschau und Erstellung werden Auswahl und sichtbare Koordinaten erneut geprüft. Bei Änderungen muss die Auswahl neu übernommen werden. Modellwechsel und aktive Bearbeitungskontexte werden vor Befehlen abgefangen.
- Modelländerungen beginnen erst bei **Messobjekt erstellen**; Fehler brechen nur die eigene Operation ab. Native Geometrie wird auf Manifold-Eigenschaft und Übereinstimmung mit dem berechneten Messwert geprüft. Zu kleine oder degenerierte Hüllen werden nicht als Erfolg übernommen.
- Bei Fehlern erscheint eine Meldung. Technisches Log: `TD_GFA_BSV_Creator.log` im temporären Systemordner; ohne Objektinhalte und Kundengeometrie.

## Ergebnis, Bearbeitung und Daten

Gruppenname `BSV_<Gebäude>_<Bereich>_001` bzw. `GFA_...`; leere Bestandteile werden ausgelassen. Tags: `TD_GFA_BSV_BSV` / `TD_GFA_BSV_GFA`. Neue transparente Materialien gehören nur den Messgruppen.

Dictionary `TD_GFA_BSV_Creator`: Mess-ID, Messgröße, Einheit, Wert bei Erstellung, Gebäude, Ebene, Verfahren, Messregel, Quell-IDs, Quellgeometrie-Prüfsumme, Parameter, Version und UTC-Erstellungszeit. Keine IFC-Klassifizierung und kein IFC-Quantity-Export in dev01.

Messgruppen lassen sich mit nativen SketchUp-Werkzeugen bearbeiten. **Werte aus Geometrie aktualisieren** liest die aktuelle Messgeometrie erneut; es schreibt keine Attribute. Der gespeicherte `value_at_creation` bleibt ausdrücklich der Erstellungswert. Offene BSV-Körper oder geneigte GFA-Flächen werden als ungültig angezeigt. Keine automatische Aktualisierung aus Quellobjekten. Bei Quellenänderungen neue Hülle erzeugen und die alte bewusst ersetzen.

Die Liste kann nach Name, Gebäude, Ebene oder Messgröße gefiltert werden. Kein pauschales Aufsummieren unabhängiger Hüllen: Überschneidungen würden sonst doppelt zählen. Jeder Messkörper hat seinen eigenen Wert.

## Grenzen und nächste Ausbaustufen

- Nur SketchUp Desktop **2026**, Hauptziel Windows 11. Andere Versionen werden für diese Funktion abgefangen. SketchUp-Laufzeit noch nicht getestet.
- Keine automatische konkave Außenkontur, keine Innenlöcher, kein interaktives Verschieben von Konturgriffen und keine punktgestützte Höheneingabe in dev01. Koordinaten und Höhen sind im Dialog bearbeitbar.
- Keine automatische Erkennung von Ebenen, Gebäudeattributen, getrennten Gebäuden oder fachlichen Abgrenzungen.
- Keine Vereinigung mehrerer Messkörper, keine Gesamtsumme und kein automatischer Quellenabgleich nach Erstellung.
- Detaillierte nichtkonvexe 3D-Hüllen für Dachformen/Rücksprünge, BDM-/IQA-Übergabe, IFC-Mapping und DIN-Regelprofile sind Folgestufen.
- Analysegrenzen: 150.000 besuchte Objekte, 100.000 eindeutige Koordinaten; 8 Sekunden je Analysephase. Konvexe 3D-Hülle maximal 6.000 Punkte und Zeitbudget. Kontur maximal 300 Eckpunkte. Überschreitung führt zu einer Meldung, nicht zu einer gekürzten Hülle. Kein Performance-Versprechen für beliebige Modelle.
- Koordinatentoleranz 0,0000001 m für Punktzusammenfassung/Hüllberechnung; Konturkanten mindestens 0,1 mm, Prismahöhe mindestens 1 mm. Die native SketchUp-Geometrieprüfung entscheidet zusätzlich über die Erstellbarkeit.

## Offizielle API-Referenzen

Am 27.11.2026 geprüft: Model (`drawing_element_visible?`, aktive Kontexte, Operationen), Entities (`add_group`, `add_face`), Group (`manifold?`, `volume`, `transformation`), Face (`normal`, `reverse!`, `area`), Tool/View (rein gezeichnete Vorschau), HtmlDialog (Callbacks), SketchupExtension/UI::Command. Besonders relevant: `drawing_element_visible?` hatte vor 2026 einen dokumentierten Fehler bei Gruppen/Komponenten als letztem Pfadelement; deshalb Begrenzung auf 2026.

- https://ruby.sketchup.com/Sketchup/Model.html
- https://ruby.sketchup.com/Sketchup/Entities.html
- https://ruby.sketchup.com/Sketchup/Group.html
- https://ruby.sketchup.com/Sketchup/Face.html
- https://ruby.sketchup.com/Sketchup/Tool.html
- https://ruby.sketchup.com/Sketchup/View.html
- https://ruby.sketchup.com/UI/HtmlDialog.html
- https://ruby.sketchup.com/file.extension_requirements.html

## Eigenständige Installation und Entwicklung

Nur die neue RBZ installieren. Im Erweiterungsmanager erscheint „GFA / BSV Creator“, unter Ansicht → Symbolleisten eine eigene Toolbar. Installation/Deinstallation ist unabhängig von den Produktivitätswerkzeugen. Vorhandene Messobjekte bleiben beim Deinstallieren als normale SketchUp-Gruppen im Modell erhalten. Messdaten des alten lokalen Sammelprototyps werden nicht automatisch migriert.

Quellen: `plugins/gfa_bsv_creator/src/`; Build: `python plugins/gfa_bsv_creator/scripts/build.py`. Tests: `NODE_PATH=<Ruby-WASI-node_modules> node plugins/gfa_bsv_creator/scripts/check_geometry.cjs`. Loader-/Paketprüfung: `python plugins/gfa_bsv_creator/scripts/check_package.py`. Alle Entwicklungsabhängigkeiten sind ausschließlich für Entwickler.

## Korrektur dev02

Die Versionsprüfung akzeptiert nun die interne SketchUp-Version 26.x für SketchUp 2026; zuvor wurde sie fehlerhaft mit 2026 verglichen. Installieren Sie die neue RBZ über den Erweiterungsmanager über die bestehende Version und starten Sie SketchUp neu. Andere Hauptversionen bleiben gesperrt.

## Korrektur dev03

Alle Summen im Plugin werden lokal gebildet. Eine durch ältere Erweiterungen ersetzte Array#sum-Funktion kann so die Messung nicht mehr über den gemeldeten Array::Fixnum-Fehler abbrechen. Die verursachende Erweiterung ist ohne Stacktrace nicht identifiziert. Ruby- oder SketchUp-Kernklassen werden nicht verändert. Fehlerdialog und Protokoll enthalten ab diesem Build die konkrete Fehlermeldung.
