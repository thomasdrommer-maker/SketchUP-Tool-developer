# SU Objektinfo – Cursor Information

Version 0.1.0.dev01 · 18.11.2026 · Auftraggeber: Tom

Entwicklungsbuild. Ziel: SketchUp Desktop 2026 / Windows 11. SketchUp-Laufzeittest offen. SketchUp 2025 ist ein weiteres, ungeprüftes Ziel; Web/iPad werden nicht unterstützt.

## Installation und Bedienung

1. `downloads/SU_Productivity_Tools_v0.1.0_dev01.rbz` herunterladen (GitHub: Datei öffnen, „Download raw file“).
2. In SketchUp über Erweiterungsmanager → Erweiterung installieren auswählen. Der Entwicklungsbuild ist unsigniert; die lokale Laderichtlinie kann eine Freigabe erfordern.
3. Erweiterungen → TD Produktivitätswerkzeuge → Objektinfo am Cursor starten, alternativ den blauen Info-Button der Toolbar verwenden.
4. Cursor kurz über einem Bauteil stehen lassen. Standardverzögerung: 400 ms. Es erscheint eine dunkle Infobox.
5. TAB oder Menü → Objektinfo – Optionen: Felder einzeln auswählen, Verzögerung, Schriftgröße, Position und Zielhierarchie einstellen. „Speichern und starten“ übernimmt die Optionen und aktiviert das Werkzeug. ESC beendet das Werkzeug.
6. Ein Tastenkürzel kann über SketchUp-Voreinstellungen dem Menüeintrag zugeordnet werden; keine Taste wird automatisch belegt.

Optionen werden in SketchUp-Benutzervorgaben gespeichert. Deinstallation über Erweiterungsmanager und Neustart. Gespeicherte Optionen können für eine spätere Installation erhalten bleiben.

## Umfang und Datenbedeutung

- Gruppen und Komponenten: Typ, Instanzname, Definitionsname, Komponentenbeschreibung, Tag, zugewiesenes Material, Volumen, Sperre, eigener Ausblendstatus, Schattenoptionen.
- Einzelne Flächen: Fläche und Vorder-/Rückseitenmaterial; einzelne Kanten: Länge. Hierfür in Optionen „Einzelne Fläche / Kante“ wählen.
- Leere oder nicht zutreffende Felder werden standardmäßig ausgeblendet. Optional wird „Nicht angegeben / nicht zutreffend“ angezeigt.
- Material bedeutet direkte Objektzuweisung. Geerbte Materialien, Texturen einzelner Unterflächen oder Tag-Farben werden nicht als Objektmaterial ausgegeben.
- Volumen wird für einen von SketchUp erkannten Volumenkörper angezeigt, mit Skalierung der konkreten Instanz und ihrer Vorfahren; kein Summieren von Baugruppen. Nicht geschlossene Körper erhalten einen Hinweis.
- Flächen und Volumen in m² bzw. m³, Länge gemäß Modelleinstellung. Keine Boundingbox-Maße als Bauteillängen.
- „Innerstes Bauteil“ zeigt die tiefste Gruppe/Komponente unter dem Cursor. „Äußerste Baugruppe“ zeigt die erste Gruppe/Komponente im aktiven Bearbeitungskontext. Geöffnete Vorfahren dienen nur zur Transformation. Bei loser Geometrie wird Fläche/Kante verwendet.
- Ausgeblendet meint den eigenen Objektstatus, keine zusammengefasste Sichtbarkeitsanalyse von Tags und Vorfahren. Picking folgt SketchUps Trefferauswahl im aktuellen Ansichtsmodus; Röntgen und ausgeblendete Geometrie separat testen.
- Lange Werte werden für die Infobox gekürzt. Sehr kleine Ansichtsfenster zeigen nur die passenden ersten Zeilen.

Es ist ein eigenes aktives Prüfwerkzeug. Kein Hover während beliebiger anderer Werkzeuge. Mittlere Maustaste/Orbit kann das Werkzeug vorübergehend unterbrechen; nach Rückkehr wird die Anzeige neu aufgebaut. Keine Auswahländerung per Klick in dieser Version.

Diese erste Stufe bildet die oben aufgelisteten Elementinformationen ab. Erweiterte Komponentenattribute wie Preis, URL, Eigentümer oder Status sowie IFC- und BASF_General-Felder siehe Abschnitt unten (ab 0.3.0.dev01).

## Integrität und Leistung

Reiner Lesezugriff auf das Modell, keine Undo-Operation, keine Attribute/Dictionaries/Tags/Materialien werden angelegt. Auswahl wird nicht verändert. Nur persönliche Optionen werden gespeichert. Fehler beenden das Werkzeug mit Meldung. Technisches Protokoll im System-Tempverzeichnis: `TD_CursorInfo.log` (Version, Fehlerklasse und Stack; keine Objektwerte).

Picking und Datenlesen erfolgen erst nach Verweildauer; keine Modellrekursion bei Mausbewegungen. Modell, Bearbeitungspfad und Timer-Generation werden vor verzögertem Zugriff geprüft. ESC, Werkzeugwechsel und Suspend verwerfen Anzeige und Timer. Kein dauerhafter Observer.

Leistungsziel: nach Ablauf der Verzögerung <200 ms bis zur Anzeige für einfache Objekte. Zu messen mit 10/100/1.000/10.000 Instanzen und komplexem Einzelkörper, jeweils Median und Maximum über zehn Hover-Vorgänge; Ziel noch nicht nachgewiesen. Volumenabfrage kann bei komplexer Geometrie Zeit benötigen.

## Entwicklung und offizielle Quellen

Quellcode: `src/`. Paketbau: `python scripts/build.py`. Paket enthält Loader und gleichnamigen Supportordner. SHA-256 liegt neben der RBZ. Quellstand und Paket werden gemeinsam auf dem Feature-Branch eingecheckt.

API am 18.11.2026 anhand der offiziellen Dokumentation geprüft:

- https://ruby.sketchup.com/Sketchup/Tool.html – Maus, Draw, Suspend/Resume, Abbruch.
- https://ruby.sketchup.com/Sketchup/PickHelper.html – best_picked, path_at, Kontextpfade.
- https://ruby.sketchup.com/Sketchup/View.html – draw2d, draw_text, text_bounds, logische Pixel ab SU2025.
- https://ruby.sketchup.com/Sketchup/ComponentInstance.html – Definition, Transformation, Volumen.
- https://ruby.sketchup.com/Sketchup/Face.html – transformierte Fläche, Rückseitenmaterial.
- https://ruby.sketchup.com/Sketchup/Edge.html – transformierte Länge.
- https://ruby.sketchup.com/UI.html – Timer.
- https://ruby.sketchup.com/UI/HtmlDialog.html – lokaler Optionsdialog.

Prüfprotokoll und Abnahmeschritte: `docs/acceptance/OBJEKTINFO_dev01.md`.

## BASF- und IFC-Attribute (ab 0.3.0.dev01)

- **IFC-Klasse** (Feld in der Liste): liest das SketchUp-Klassifizierungswörterbuch `AppliedSchemaTypes` (Instanz, sonst Definition), z. B. `IFC 4: IfcWall`. Nur Lesen.
- **BASF- und IFC-Attribute**: Im Optionsdialog werden die im Modell vorhandenen Schlüssel aus `BASF_General` und aus Wörterbüchern mit Namen `IFC…` zur Auswahl angeboten. Die Suche läuft nur beim Öffnen der Optionen (Obergrenze 50 000 Instanzen, dann Hinweis). Bei der Anzeige hat die Instanz Vorrang vor der Definition.
- Es werden keine Dictionaries, Attribute oder Klassifizierungen angelegt oder geändert. Ausgewählte Schlüssel, die im Modell fehlen, bleiben gespeichert und erscheinen nur, wenn leere Angaben eingeblendet werden.
- Annahme, noch zu prüfen: Name und Aufbau von `AppliedSchemaTypes` und der IFC-Wörterbücher stammen aus dem Verhalten der SketchUp-Klassifizierung, nicht aus einer offiziellen API-Referenz. Praxistest mit Ihrem IFC-Manager-Modell nötig.
