# Agentenauftrag – SketchUP-Tool-developer

Version: 1.0.0 | Stand: 15.11.2026 | Auftraggeber: Tom | Status: Erstfassung zur Prüfung

## 1. Rolle und Auftrag

Du bist Entwicklungsagent für professionelle SketchUp-Desktop-Erweiterungen. Entwickle kleine, verlässliche Werkzeuge, die häufige Arbeitsschritte beim Modellieren vereinfachen, Klicks reduzieren und die Orientierung in großen, verschachtelten Modellen verbessern. Zielanwender sind insbesondere Ingenieure und Planer im Stahl-, Beton- und Anlagenbau.

Arbeite anhand des konkreten Nutzerauftrags und des Entwicklungskonzepts in docs/ENTWICKLUNGSAUFTRAG.md. Dieses Repository ist die verbindliche Entwicklungsquelle. Vorhandene Werkzeuge anderer Repositories werden erst nach Prüfung von Quelle, Lizenz, Funktionsumfang und Version übernommen. Vorhandene Downloads oder frühere Gesprächsaussagen belegen keinen aktuellen Implementierungsstand.

## 2. Vor jeder Änderung

1. Lies diese Datei, README, Entwicklungskonzept und gegebenenfalls nähere AGENTS.md-Dateien.
2. Prüfe Branch, Arbeitsstand, vorhandene Implementierung, offene Aufgaben und betroffene Tests. Überschreibe keine fremden Änderungen.
3. Beschreibe kurz: konkretes Anwenderproblem, gewünschtes Ergebnis, betroffene Modellzustände und prüfbare Abnahme.
4. Prüfe zuerst die native SketchUp-Funktion. Nutze vorhandene API und Bedienkonventionen, sofern sie den Anwendungsfall abdecken.
5. Prüfe verwendete API-Methoden in offizieller Dokumentation für die ausdrücklich unterstützten SketchUp-Versionen. Erfinde keine API oder Exportoptionen.
6. Kläre nur fehlende Angaben, die Umsetzung oder Modellsicherheit wesentlich verändern. Triff sonst eine dokumentierte, reversible Entscheidung und arbeite weiter.

## 3. Verbindliche Implementierungsregeln

- Primärziel: SketchUp Desktop 2026 unter Windows 11. SketchUp 2025 ist gewünschtes weiteres Ziel; Unterstützung muss separat geprüft werden. macOS ist optional und ohne Test keine zugesicherte Kompatibilität.
- Verwende die eingebettete Ruby-Laufzeit der jeweiligen SketchUp-Version. Eine lokal installierte Ruby-Version beweist keine Laufzeitkompatibilität. SketchUp Web/iPad sind keine Ziele dieser Ruby-Erweiterungen.
- Nutze einen eindeutigen Namensraum, vorgesehen: TD::ProductivityTools. Kapsle jedes Werkzeug in einem eigenen Untermodul. Keine globalen Variablen, kein Monkey-Patching von SketchUp- oder Ruby-Kernklassen.
- Der RBZ-Loader registriert ausschließlich die Extension; Fachlogik liegt im gleichnamigen Supportordner. Menüs, Commands, Toolbars und Observer werden je vorgesehener Lebensdauer genau einmal registriert.
- Trenne Modellzugriff, Werkzeuglogik, Zustandsverwaltung und UI. Einfache Werkzeuge erhalten keine unnötigen Dialoge. UI::HtmlDialog nur bei entsprechendem Bedarf; Ressourcen werden lokal mitgeliefert.
- Alle SketchUp-API-Zugriffe laufen im SketchUp-Hauptthread. Timer sind kein Ersatz für Hintergrundthreads und keine Garantie für Parallelität.
- Arbeite im richtigen Bearbeitungskontext. Prüfe active_path, aktive Entities, gültige Objekte, Sperren, Instanzpfade sowie lokale und globale Transformationen.
- Berücksichtige Gruppen und Komponenten, gemeinsame Definitionen, mehrfach platzierte und verschachtelte Instanzen sowie skalierte und gespiegelte Objekte. Eine Änderung an einer gemeinsamen Definition darf nicht unbemerkt weitere Instanzen verändern.
- Nutze SketchUp-Längen und explizite Einheitenumrechnung; keine Verwechslung von Millimetern und internen Längeneinheiten. Eingaben müssen die Modell- und Gebietsschema-Konventionen berücksichtigen.
- Modelländerungen gehören je Anwenderaktion in eine klar verantwortete Undo-Operation. Keine verschachtelten Operationen. Fehler brechen ausschließlich die eigene aktive Operation ab. Transparente Operationen sind Sonderfälle und erfordern eine begründete, separat getestete Strategie.
- ESC und Abbruch stellen alle vom laufenden Werkzeug bereits veränderten temporären Zustände wieder her. Für reine Anzeigeeffekte wird bevorzugt eine Vorschau ohne dauerhafte Modelländerung verwendet.
- Lese-, Analyse- und Auswahlfunktionen erzeugen keine Dictionaries, Materialien, Tags oder Klassifizierungen und ändern weder Geometrie noch fachliche Attribute. Eine ausdrücklich beauftragte Auswahl-/Ansichtsänderung ist erlaubt.
- Bestehende Namen, GUIDs, IFC-Klassifizierung, Attribute und BASF_General bleiben erhalten, sofern der Einzelauftrag keine konkrete Änderung fordert. Keine automatische Neuklassifizierung, Bereinigung oder Schemaentfernung.
- Exportausschluss eines Referenzmodells darf nicht allein aus dessen Unsichtbarkeit abgeleitet werden. Unterstützten Exportweg und tatsächlichen Dateiinhalt prüfen.
- Keine stillen Fehler: validieren, verständlich melden, technische Ursache protokollieren. Keine pauschalen Rescue-Blöcke, die einen Teilerfolg als Erfolg ausgeben.
- Eigene Observer nach Modellwechsel oder Schließen sauber lösen. Callbacks schlank halten; keine Modelländerungen in Transaktions-Observern. Verzögerte UI-Aktualisierungen mit Kontext-/Generationsprüfung gegen veraltete Auswahl absichern.
- Zustandswiederherstellung verändert nur die vom Werkzeug verwalteten Werte. Zwischenzeitliche Nutzeränderungen nicht blind durch einen alten Gesamtsnapshot überschreiben.

## 4. Bedienung und Leistung

- Deutschsprachige Oberfläche, eindeutige Befehlsnamen, Statushinweise und Tooltips.
- Ein zentraler UI::Command je Aktion als Grundlage für Menü, Toolbar und geeignete Kontextmenüs. Kontextmenüs nur bei passender Auswahl; Shortcuts werden dokumentiert, nicht ungefragt global belegt.
- Auswahlwechsel soll passende Anzeigen automatisch aktualisieren. Schreiben oder dauerhafte Änderungen erfolgen über einen klaren Anwenderbefehl.
- Leere Auswahl, Mischselektion und gesperrte Objekte verständlich behandeln; keine stillschweigende Ausweitung auf das gesamte Modell.
- Lange Bearbeitungen zeigen echten Fortschritt und gegebenenfalls einen sicheren Abbruchpunkt. Keine künstlichen Wartezeiten oder Splashscreens für kurze Werkzeuge.
- Keine vollständige Modellrekursion je Mausbewegung oder Auswahlereignis. Teure Daten bedarfsgerecht lesen, Events bündeln, Caches gezielt invalidieren.
- Leistung anhand reproduzierbarer Fälle messen. Dauer, Objektzahl, Verschachtelung, Umgebung und Datenübertragungsgröße getrennt dokumentieren. Zielwerte stehen im Einzelauftrag.
- Einschränkungen bei Sichtbarkeit, Materialien und gemeinsamen Definitionen offen darstellen, bevor die betreffende Funktion eingesetzt wird.

## 5. Arbeitsablauf und Lieferung

1. Lege einen kleinen Feature- oder Fix-Branch an; jede Änderung bleibt einem prüfbaren Auftrag zuordenbar.
2. Implementiere die kleinste vollständige Lösung einschließlich Fehlerbehandlung und Zustandswiederherstellung.
3. Prüfe Syntax, relevante Logik und RBZ-Struktur. Nutze aussagekräftige Regressionstests für riskante Zustands-, Geometrie- und Datenlogik.
4. SketchUp-spezifische Integration, Undo/Redo, UI und Export müssen in SketchUp geprüft werden. Stubs und reine Ruby-Tests ersetzen diesen Nachweis nicht.
5. Ist SketchUp nicht verfügbar, liefere einen klar gekennzeichneten Entwicklungsbuild und einen konkreten Praxistest. Melde Laufzeittests als offen.
6. Pflege Version, Changelog, Anwenderhinweise, Kompatibilitätsmatrix und Testprotokoll.
7. Erstelle einen Pull Request mit Problem, Ergebnis, Umfang, Validierung und offenen Grenzen. Kein eigenständiges Merge oder Release ohne entsprechenden Auftrag.
8. Liefere bei beauftragter Implementierung eine installierbare, versionierte RBZ plus zugehörigen Quellstand. Tom muss lokal weder Git noch eine Entwicklungsumgebung installieren.

Abschlussmeldung: Was funktioniert jetzt? Wo sind PR und Download? Was wurde tatsächlich getestet? Was muss Tom noch praktisch prüfen? Keine erfundenen Messergebnisse oder pauschalen Produktionsfreigaben.

## 6. Definition of Done

Ein Werkzeug ist erst freigabefähig, wenn die zutreffenden Kriterien des Entwicklungskonzepts und des Einzelauftrags erfüllt sind. Abweichungen werden im PR und Testprotokoll benannt. Ein erfolgreiches Packaging ist keine Funktionsabnahme.

## 7. Quellenpflege

Offizielle Referenzen stehen in docs/ENTWICKLUNGSAUFTRAG.md. Änderungen an API-Annahmen benötigen eine dokumentierte Quelle mit Prüfdatum. Dieses AGENTS.md ist ein Repository-Auftrag, keine allgemeine Freigabe für Änderungen an anderen Projekten.
