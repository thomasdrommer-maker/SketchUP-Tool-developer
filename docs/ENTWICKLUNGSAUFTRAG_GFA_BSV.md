# Entwicklungsauftrag – GFA- und BSV-Messwerkzeug für SketchUp

Version: **1.1.0**
Stand: **24.11.2026**
Auftraggeber und fachliche Abnahme: **Tom**
Repository: **thomasdrommer-maker/SketchUP-Tool-developer**
Zielmodul: **TD::GFABSVCreator::BuildingMetrics**
Status: **Entwicklungsgrundlage zur Prüfung; keine Produktfreigabe**

## 1. Auftrag und erwarteter Nutzen

Entwickle ein deutschsprachiges SketchUp-Werkzeug, mit dem Anwender vorhandene Modellobjekte auswählen und daraus prüfbare Geschossflächen und geschlossene Gebäude-/Strukturhüllen erzeugen können.

**Zentrale Muss-Funktion:** Gruppen, Komponenten oder eine offene Tragstruktur auswählen → äußere Geometriebegrenzung ableiten → transparente Umhüllung vorschlagen → nach Anwenderprüfung einen geschlossenen Messkörper mit Volumen in m³ erstellen.

Die Anwendung richtet sich an Gebäude sowie offene Stahl-, Beton- und Anlagenstrukturen. Sie muss auch funktionieren, wenn die ausgewählten Quellobjekte zusammen keinen geschlossenen Körper bilden. Quellen dienen als geometrische Referenz; die erzeugte Messgeometrie ist ein eigenes Objekt.

Dieser Einzelauftrag ergänzt [den allgemeinen Entwicklungsauftrag](ENTWICKLUNGSAUFTRAG.md) und unterliegt [AGENTS.md](../AGENTS.md). Er ersetzt keine bestehenden Werkzeugaufträge.

## 2. Begriffe und verbindliche Messregeln

| Begriff | Einheit | Bedeutung in diesem Werkzeug |
| --- | --- | --- |
| GFA – GrossFloorArea | m² | Horizontale Geschoss-/Ebenenfläche nach dokumentierter Projektabgrenzung |
| BSV – BuildingStructureVolume | m³ | Von einer festgelegten Hülle umschlossener Gebäude-/Strukturraum |
| Materialvolumen | m³ | Volumen der einzelnen Bauteile; eigenständige Messgröße, nicht BSV |
| BGF / BRI | m² / m³ | Normbezogene Größen; nur mit gesondert geprüfter Regelanwendung ausweisen |

BSV wird als **Projektbegriff** verwendet. Eine universelle normative Definition wird damit nicht behauptet. Eine geometrische Hülle ist nicht automatisch eine Berechnung nach DIN 277. Eine spätere Normauswertung erfordert die maßgebliche Normfassung, ein nachvollziehbares Regelprofil und eigene fachliche Abnahme.

Für jede Messung sind zu speichern:

- Bezugsgebäude und Ebene bzw. Teilbereich;
- Messgröße und Einheit;
- geometrisches Verfahren und dessen Parameter;
- Abgrenzungsregel einschließlich Umgang mit Öffnungen und Zwischenräumen;
- Prüfstatus, Quellbezug und Berechnungsstand.

Vorläufiges Standardprofil: **Geometrische Projektermittlung**. Bei konvexer Umhüllung sind Rücksprünge und Zwischenräume eingeschlossen. Diese Wirkung muss vor der Übernahme sichtbar erklärt werden.

Für offene Strukturen ist die Wahl der Begrenzung fachlich relevant: tatsächliche Bauteilaußenkanten, Belagskanten und Stützenachsen sind unterschiedliche Ansätze. Der erste Build arbeitet mit tatsächlicher Geometrie; Achs- oder andere Regelbegrenzungen müssen später ausdrücklich implementiert und benannt werden.

## 3. Ausgangsstand und Abgrenzung

Ein lokaler Entwicklungsstand **0.4.0.dev01**, Commit **cc44107**, liegt aus der vorangegangenen Arbeit vor. Er enthält Quader, konvexe 3D-Hülle, bearbeitbare Grundrisskontur, Vorschau, Messgruppen und CSV-Auswertung.

Dort dokumentiert: 15 Geometrie-Regressionsfälle, 15 Vergleiche mit unabhängigen Referenzvolumen und sechs Tests der Auswahlverarbeitung mit vereinfachten Testobjekten. **SketchUp-Laufzeit, native Körpererstellung, UI und Undo/Redo sind noch nicht abgenommen.**

Bei Erstellung dieses Auftrags ist der lokale GFA-/BSV-Code nicht auf dem geprüften Remote-main vorhanden. Dieser Dokumentationsbranch veröffentlicht ausschließlich den Auftrag. Bestehender Code darf erst nach Quellenprüfung, Abgleich mit dem aktuellen main und gesonderter Integration als Repository-Implementierung bezeichnet werden. Insbesondere neuere Änderungen an Objektinfo und Einstellungen dürfen nicht durch den älteren lokalen Stand überschrieben werden.

Der Nutzer hat am 24.11.2026 ausdrücklich eine eigenständige Extension beauftragt. Der Prototyp wird deshalb unter einer eigenen Produktversion **0.1.0.dev01** übernommen; die Versionsfolge der Produktivitätswerkzeuge wird nicht fortgeschrieben.

## 4. Plattform und Integration

- Primärziel: SketchUp Desktop 2026 unter Windows 11.
- SketchUp 2025 erst nach eigenem API-/Kompatibilitätsnachweis; Web/iPad sind keine Ruby-Zielplattform.
- Eigenständiges Plugin **GFA / BSV Creator** mit eigenem Extension-Loader, Supportordner, Menü, Toolbar, Versionsfolge und RBZ. Keine Laufzeitabhängigkeit von TD Produktivitätswerkzeugen oder BDM. Quellen unter `plugins/gfa_bsv_creator/`; Loader `td_gfa_bsv_creator.rb`, Supportordner `td_gfa_bsv_creator/`.
- Vorhandene Objektinfo und Auswahlhervorhebung bleiben funktionsfähig.
- BDM, IQA und IFC sind klar abgegrenzte spätere Schnittstellen.
- Offline-Betrieb; keine zusätzliche lokale Python-/Ruby-Installation für Anwender.
- Menü, Toolbar und geeignetes Kontextmenü nutzen denselben zentralen Befehl.

## 5. Bedienablauf

1. Quellen im Modell auswählen.
2. **GFA / BSV aus Auswahl** öffnen.
3. Auswahlumfang und Eignung anzeigen; Gebäude, Ebene und Messprofil festlegen.
4. Verfahren auswählen; vorgeschlagene Kontur und Höhen prüfen.
5. **Vorschau berechnen**: Messgeometrie und Wert werden angezeigt, ohne persistente Modelländerung.
6. Grenzen bei Bedarf ändern; nach jeder Änderung Vorschau aktualisieren.
7. **Messobjekt erstellen**: eigene Gruppe mit Messdaten in einem Undo-Schritt erzeugen.
8. Ergebnis in Liste prüfen; Auswahl/Zoom und Export direkt erreichbar.

Auswahländerungen sollen den angezeigten Auswahlstatus automatisch aktualisieren und eine vorhandene Vorschau als veraltet markieren. Teure Geometrieanalysen dürfen gebündelt oder bewusst angefordert werden. Ein automatischer Lesevorgang darf niemals selbst Messobjekte schreiben.

## 6. Funktionale Anforderungen

### AUS-01 – Quellen erfassen und räumlich korrekt auswerten

Unterstützen: Gruppen, Komponenten, Flächen und Kanten; mehrfach platzierte gemeinsame Definitionen; verschachtelte, gedrehte, skalierte und gespiegelte Instanzen.

Tatsächliche Geometriepunkte und Instanztransformationen verwenden. Bounding-Box-Ecken sind ausschließlich für die ausdrücklich gewählte Quaderermittlung zulässig. Identität und Transformation gehören zum konkreten Instanzpfad.

Leere/ungeeignete Auswahl, gelöschte Quellen und unzureichende Geometrie verständlich melden. Keine stille Ausweitung auf das Gesamtmodell. Gesperrte Quellen dürfen lesend berücksichtigt werden.

Erste Integrationsstufe: Ausführung auf Modellebene; offener Bearbeitungskontext wird verständlich abgewiesen. Unterstützung weiterer Kontexte ist gesondert zu prüfen.

### AUS-02 – Sichtbarkeit und Auswahlgrenzen

Auswerteumfang sichtbar festlegen: ausgewählte sichtbare Geometrie einschließlich dokumentierter SketchUp-Anzeigeoptionen. Nicht berücksichtigte Teilobjekte zählen und anzeigen. Schnittdarstellungen dürfen nicht ohne tatsächliche Schnittberechnung als zugeschnittene Geometrie behandelt werden.

Quellen zur Begrenzung hinzufügen/entfernen können; insbesondere Geländer, Konsolen und Ausleger gezielt ausschließen. Keine stille Ausreißerentfernung.

Getrennte Strukturen entweder ausdrücklich gemeinsam umschließen oder separat bearbeiten. Niemals ungekennzeichnet eine Brücke zwischen Gebäuden erzeugen.

### BSV-01 – Geschlossene Umhüllung aus Auswahl

| Verfahren | Definition | Fachliche Grenze |
| --- | --- | --- |
| Ausgerichteter Quader | Geometrie in einem festgelegten, um Z gedrehten Bezugssystem umschließen | Rücksprünge und freie Zwischenräume eingeschlossen |
| Konvexe 3D-Hülle | Konvexe Hülle der tatsächlich ausgewerteten Geometriepunkte | Konkave Bereiche werden überbrückt; keine detailgetreue Außenhaut |
| Grundrisskontur + Höhen | Geschlossene XY-Kontur zwischen definierter Unter-/Oberkante extrudieren | Bei veränderlichen Höhen sind Teilbereiche nötig |
| Vorhandene Hülle übernehmen | Geprüften geschlossenen Referenzkörper als neue Messgeometrie übernehmen | Identität/Attribute der Quelle nicht ungeprüft kopieren |

Eine automatische Grundrisskontur darf zunächst konvex sein. Sie muss als Vorschlag gekennzeichnet und korrigierbar sein. Eine automatische konkave Hülle ist eine eigene Ausbaustufe, keine zugesicherte Eigenschaft des ersten Builds.

Unter-/Oberkante aus globalen Höhenextrema vorschlagen; Zahlenwerte und später Modellpunkte unterstützen. Das Verfahren darf geneigte Dächer nicht als exakt nachgebildet ausgeben, wenn lediglich ein Prisma erstellt wird.

Vor Übernahme prüfen: geschlossene orientierbare Hülle, gültige Flächen, kein Selbstschnitt, positives Volumen und Übereinstimmung zwischen Vorschau, berechnetem Wert und nativer Messgeometrie. Bei automatisch umschließenden Verfahren müssen sämtliche berücksichtigten Quellpunkte innerhalb der dokumentierten Toleranz enthalten sein. Bei manueller Begrenzung dürfen Quellen bewusst außerhalb liegen; dies sichtbar kennzeichnen.

### GFA-01 – Horizontale Flächen erzeugen

Drei Wege vorsehen:

- vorhandene geeignete Fläche übernehmen und horizontal auswerten;
- geeignete Quellkonturen auf eine Ebene projizieren und vereinigen;
- Kontur zeichnen oder bearbeiten.

Eine geneigte Fläche wird für GFA horizontal projiziert; die tatsächliche geneigte Oberfläche ist separat zu benennen. Außenkontur und Innenöffnungen getrennt verwalten. Bruttofläche, Öffnungsabzüge und Ergebnisfläche müssen nachvollziehbar sein; Abzugsregeln dürfen nicht aus dem Namen GFA abgeleitet werden.

Teilflächen derselben Ebene vereinigen, Überschneidungen nur einmal zählen. Unterschiedliche Ebenen getrennt auswerten. Für GFA darf nicht der gesamte Gebäudegrundriss ungeprüft auf jede Ebene kopiert werden.

### GEO-01 – Bearbeitung und Teilbereiche

Konturpunkte verschieben, einfügen und entfernen; numerische Koordinaten als verlässlichen Eingabeweg unterstützen. Nachfolgend direkte Modellgriffe mit SketchUp-Fangfunktionen und punktgestützte Höheneingabe ergänzen.

Teilvolumen für Rücksprünge, gestaffelte Höhen und Dachformen ermöglichen. Erst nach belastbarer Boolescher Vereinigung ein gemeinsames Volumen ausgeben; andernfalls getrennte Werte und Überschneidungshinweis. Keine Summe überlappender Teilkörper als eindeutiges Gesamt-BSV ausgeben.

### UX-01 – Vorschau und Ergebnisse

Transparente Füllung und deutliche Konturkanten, eindeutig benannte Verfahren und verständliche Methodenerklärung. ESC/Werkzeugwechsel verwirft die Vorschau. Dialog und Modellansicht müssen zusammen bedienbar sein.

Tabelle mit Name, Gebäude, Ebene, Messgröße, Wert, Einheit, Verfahren, Prüfstatus und Aktualität. Anzeige zwei Nachkommastellen, intern volle Präzision. Filter einschließlich Leerwerten, Zeilenwahl → Objektwahl/Zoom, Kopieren und CSV für Excel.

Summen nur nach festgelegter Gruppierung und Doppelzählungsprüfung. Filterumfang und Exportumfang müssen erkennbar übereinstimmen oder ausdrücklich auswählbar sein.

### AKT-01 – Änderungen nachvollziehen

Erstellungswert, aktuell aus Messgeometrie ermittelter Wert und Quellenaktualität getrennt behandeln. Quellenänderungen dürfen keine stillen Werteänderungen auslösen.

Befehl **Aus Quellen aktualisieren** mit Änderungsvorschau vorsehen. Manuelle Konturkorrekturen erhalten; bei Konflikten eindeutig zwischen Übernahme, Verwerfen oder weiterer Bearbeitung wählen lassen. Neue Revisionen dürfen nicht unbemerkt eine bestehende Mess-ID duplizieren.

## 7. Datenmodell und Schnittstellen

Eigene Metadaten im Dictionary **TD_GFA_BSV_Creator** verwalten. Keine Änderung fremder Dictionaries durch Lesen oder Erzeugen eigener Messobjekte.

| Feldgruppe | Mindestinhalt |
| --- | --- |
| Identität | Mess-ID, Revision, Messgröße, Schema-/Modulversion |
| Zuordnung | Gebäude/Baunummer, Ebene, Bereich |
| Messregel | Profil-ID/-Version, Verfahren, Öffnungsbehandlung |
| Geometrie | Bezugssystem, Kontur, Unter-/Oberkante, Parameter |
| Ergebnisse | Erstellungswert, Einheit, Berechnungsdatum; aktuelle Werte getrennt |
| Herkunft | Instanzpfade/Quell-IDs, Geometriefingerprint, Modellbezug |
| Prüfung | geometrische Gültigkeit, fachlicher Prüfstatus, Quellenaktualität |

Neue Messgruppen auf eigenen GFA-/BSV-Tags ablegen. Eindeutige Namen mit Zähler; bestehende Namen nicht überschreiben. Fachliche Klassifizierung und BASF_General der Quellen unverändert lassen.

IQA-Zielbild: GFA je Ebene sowie BSV je Gebäude oder Teilbereich. IFC-Zuordnung zu räumlichen Strukturelementen und Quantity-Sets separat spezifizieren und anhand realer Exportdateien nachweisen. Keine pauschale IfcSpace-Klassifizierung jeder Hilfsfläche und kein Versprechen, dass SketchUp-Dictionaries automatisch IFC-Quantities werden.

CSV in UTF-8 mit Excel-tauglicher deutscher Zahlendarstellung. XLSX, BDM-Anbindung und IFC-Export sind Folgestufen mit eigenem Datenvertrag.

## 8. Architektur, Modellsicherheit und Leistung

Schichten: Auswahl-/Instanzauflösung → reine Geometrieberechnung → Validierung → Vorschau → transaktionaler Writer → Ergebnis-/Exportadapter.

Alle SketchUp-API-Zugriffe im Hauptthread. Neue Observer sauber lösen, teure Lesevorgänge nicht je Mausbewegung ausführen. Veraltete Dialogaktionen durch Modell-, Kontext- und Auswahlprüfung abfangen.

Ein dauerhafter Anwenderbefehl entspricht einer eigenen Undo-Operation. Abbruch stellt ausschließlich werkzeugeigene Zustände wieder her. Analysen erzeugen weder Tags noch Materialien oder Attribute.

Geometrie intern mit eindeutigem Einheitensystem, expliziter Umrechnung und dokumentierten Toleranzen berechnen. Numerische Toleranz, native Modelliertoleranz und fachliche Abgrenzung sind verschiedene Größen. Keine stille Rundung oder Punktreduktion, die die Hülle verkleinert oder Rücksprünge unbemerkt schließt.

Als überprüfbare Startbudgets des lokalen Prototyps gelten 150.000 besuchte Objekte, 100.000 eindeutige Punkte, maximal 6.000 Punkte für die 3D-Hülle, 300 Konturpunkte und etwa acht Sekunden je Analysephase. Das sind Schutzgrenzen, keine zugesicherte Produktleistung. Überschreitung muss vollständig abbrechen oder eine ausdrücklich benannte Alternative anbieten.

Leistung mit 10, 100 und 1.000 Instanzen sowie realem Modell dokumentieren: Hardware, SketchUp-Version, Verschachtelung, Punktzahl, Analyse-, Vorschau- und Schreibzeit. Lange Vorgänge benötigen echten Fortschritt und sichere Abbruchpunkte; keine vorgetäuschte Fortschrittsanzeige.

## 9. Umsetzungspakete

| Paket | Inhalt | Lieferkriterium |
| --- | --- | --- |
| AP1 – Integrationsbasis | Lokalen dev01 prüfen, gegen aktuellen main als eigenständiges Plugin bereitstellen; Quader, 3D-Hülle, numerische Kontur, GFA-Prisma, Vorschau und CSV stabilisieren | Installierbarer Entwicklungsbuild, Tests und dokumentierte Grenzen |
| AP2 – Produktive Eingabe | Flächenübernahme, Konturzeichnen/Griffe, punktgestützte Höhen, Öffnungen, Quellenwahl und automatischer Auswahlstatus | Kurzer Modellworkflow, belastbare Rücksprung-/Öffnungsfälle |
| AP3 – Bauwerksauswertung | Ebenenzuordnung, Flächenvereinigung, Teilvolumenvereinigung, kontrollierte Summen, Aktualisierung aus Quellen | Keine Doppelzählung; Änderungen nachvollziehbar |
| AP4 – Datenaustausch | BDM-/IQA-Vertrag, geprüfte IFC-Zuordnung, optional XLSX und Normprofile | Nachweis an exportierten Dateien und separater fachlicher Abnahme |

AP1 ist der nächste konkrete Umsetzungsschritt. AP2–AP4 beschreiben den Zielausbau; Details werden vor der jeweiligen Implementierung revisioniert. Ein fertig gebautes Paket ist keine Freigabe der späteren Pakete.

## 10. Abnahmekriterien

| ID | Prüffall | Erwartung |
| --- | --- | --- |
| AB-01 | Quader 10 × 5 × 3 m | BSV 150,00 m³, GFA 50,00 m² |
| AB-02 | Tetraeder mit Achskanten 1 m | Konvexes Volumen 1/6 m³; Anzeige 0,17 m³ |
| AB-03 | L-Kontur (0;0), (4;0), (4;1), (1;1), (1;4), (0;4); Höhen 2–5 m | GFA 7,00 m²; Prisma 21,00 m³ |
| AB-04 | Konvexe Hülle derselben L-Struktur | Überbrückter Rücksprung sichtbar; nicht als exakte L-Hülle bezeichnet |
| AB-05 | Drehung, Spiegelung, nichtuniforme Skalierung, große Modellkoordinaten | Weltkoordinaten und Messwerte korrekt; keine Quelländerung |
| AB-06 | Gemeinsame Definition mehrfach verschachtelt platziert | Jede gewählte Instanz richtig berücksichtigt |
| AB-07 | Selbstschnitt, ebene/linienförmige 3D-Auswahl, degenerierte Geometrie | Verständlicher Abbruch, kein ungültiger Messkörper |
| AB-08 | Vorschau, ESC, Werkzeugwechsel, Modellwechsel, geänderte Auswahl | Kein temporärer Rest und keine Übernahme veralteter Ergebnisse |
| AB-09 | Erstellen, Undo, Redo | Ein Undo-Schritt; Quellgeometrie/-attribute unverändert |
| AB-10 | Ausgeblendete/gesperrte Quellen und Schnittdarstellung | Dokumentierter, im Dialog erkennbarer Auswerteumfang |
| AB-11 | Überlappende Teilflächen/-körper | Bei Vereinigung nur einmal gezählt; sonst keine ungeprüfte Gesamtsumme |
| AB-12 | Öffnungen und mehrere Ebenen | Abzugsregel und Ebenenzuordnung prüfbar; keine Doppelzählung |
| AB-13 | Manuelle Änderungen und Quellenänderungen | Erstellungswert, aktuelle Geometrie und Aktualität getrennt erkennbar |
| AB-14 | CSV, Umlaute, Filter, Einheiten, Dezimalkomma | In Excel lesbar und fachlich eindeutig |
| AB-15 | Installation/Update, 150/200 % DPI, bestehende Werkzeuge | Keine Ladefehler, doppelten Befehle oder Regressionen |
| AB-16 | Große Auswahl / Schutzgrenzen | Gemessene Laufzeiten; kein still gekürztes Ergebnis |

AB-11 bis AB-13 vollständig erst in den zugehörigen Ausbaupaketen; vorher ausdrücklich als offen ausweisen. Geometrische Gültigkeit und fachliche Freigabe sind getrennte Status.

Numerische Tests verwenden bekannte Körper und unabhängige Referenzen. UI, native Volumenkörper, Sichtbarkeit, Undo/Redo und Export erfordern zusätzlich SketchUp-Praxistests. Reine Tests mit vereinfachten Objekten ersetzen diese nicht.

## 11. Lieferung und Definition of Done

Je Implementierung: kleiner Feature-Branch, versionierte RBZ mit SHA-256, zugehöriger Quellcommit, reproduzierbarer Paketbau, Changelog, Bedienhinweise, Kompatibilitätsmatrix und ausgefülltes Prüfprotokoll. Keine Kundenmodelle oder internen Projektdaten veröffentlichen.

PR beschreibt Anwenderproblem, resultierendes Verhalten, geprüfte Fälle und offene Grenzen. Ohne SketchUp-Testsystem als **Entwicklungsbuild – Praxistest offen** kennzeichnen. Merge und offizielles Release benötigen eigenen Auftrag.

Freigabefähig erst bei korrekten Messwerten, gültiger Messgeometrie, unveränderten Quellen, sicherem Abbruch/Undo und bestandenen Tests des freizugebenden Pakets. Einschränkungen müssen sichtbar und fachlich akzeptiert sein.

## 12. Technische Referenzen und Revisionen

Vor jeder API-Implementierung die konkret verwendeten Methoden und unterstützten SketchUp-Versionen in der offiziellen Dokumentation prüfen. Diese Links sind Arbeitsreferenzen, keine pauschale Kompatibilitätsbestätigung:

- https://ruby.sketchup.com/Sketchup/Model.html
- https://ruby.sketchup.com/Sketchup/Entities.html
- https://ruby.sketchup.com/Sketchup/Group.html
- https://ruby.sketchup.com/Sketchup/Face.html
- https://ruby.sketchup.com/Sketchup/InstancePath.html
- https://ruby.sketchup.com/Sketchup/Tool.html
- https://ruby.sketchup.com/Sketchup/View.html
- https://ruby.sketchup.com/UI/HtmlDialog.html
- https://ruby.sketchup.com/file.extension_requirements.html

| Version | Datum | Änderung |
| --- | --- | --- |
| 1.0.0 | 23.11.2026 | Erstfassung aus dem abgestimmten GFA-/BSV-Konzept; zentrale Hüllenfunktion, Ausbaupakete, Datenvertrag und Abnahme festgelegt |
| 1.1.0 | 24.11.2026 | Nutzerkorrektur: eigenständiger GFA / BSV Creator mit eigenem Loader, Namensraum, UI, Datenbereich und RBZ; AP1 entsprechend angepasst |
