# Entwicklungsauftrag – professionelle SketchUp-Produktivitätswerkzeuge

Version: 1.0.0  
Stand: 15.11.2026  
Auftraggeber / fachliche Abnahme: Tom  
Repository: thomasdrommer-maker/SketchUP-Tool-developer  
Status: Erstfassung zur Prüfung; noch keine Implementierung oder Produktfreigabe

## 1. Ziel und Nutzen

Entwickelt wird eine erweiterbare Sammlung professioneller SketchUp-Werkzeuge für schnelleres, übersichtlicheres und zuverlässigeres Arbeiten in umfangreichen Modellen. Die Werkzeuge ergänzen native Funktionen dort, wo sich wiederkehrende Handgriffe sinnvoll zusammenfassen oder Bedienlücken schließen lassen.

Jeder Auftrag beginnt mit einer konkreten Alltagssituation und endet mit einer nachprüfbaren Verbesserung: weniger Bedienhandlungen, kürzere Bearbeitungszeit, bessere Orientierung oder weniger Fehler. Die Sammlung soll sich wie eine konsistente Erweiterung von SketchUp bedienen lassen.

## 2. Projektgrenzen

Enthalten sind Werkzeuge für Auswahl, Sichtbarkeit, Orientierung, Referenzmodelle, Transformation und Modellierhilfen. Diagnosewerkzeuge dürfen zur Funktionsprüfung ergänzt werden.

Nicht automatisch enthalten sind neue Fachkonstrukteure für Geländer, Treppen oder Leitern, eine vollständige BIM-Datenverwaltung, IFC-Mengenberechnung, statische Nachweise oder Änderungen an bestehenden Fachplugins. Solche Funktionen benötigen einen eigenen Auftrag oder eine bewusst definierte Schnittstelle. Bestehende Werkzeuge werden nicht allein wegen ähnlicher Funktionen dupliziert.

Die erste Iteration dieses Auftrags definiert Architektur, Regeln und Arbeitsvorlagen. Die Werkzeug-Roadmap ist ein priorisierter Vorschlag; sie löst noch keinen Entwicklungsauftrag für sämtliche Funktionen aus.

## 3. Anwender und Zielplattform

| Bereich | Festlegung |
| --- | --- |
| Hauptanwender | Ingenieure und Planer; insbesondere Stahl-, Beton- und Anlagenbaumodelle |
| Primäres Prüfziel | SketchUp Desktop 2026, Windows 11 |
| Gewünschtes weiteres Prüfziel | SketchUp Desktop 2025; Freigabe erst nach nachgewiesenem Test |
| Weitere Plattformen | macOS optional; andere Versionen auf Einzelauftrag |
| Sprache | Deutsch; technische Bezeichner im Code dürfen Englisch sein |
| Installation | Über SketchUp Extension Manager aus einer RBZ |
| Lokale Voraussetzungen | Keine zusätzliche Python-/Ruby-Installation, kein Git erforderlich |
| Betrieb | Kernfunktionen offline; externe Dienste nur nach ausdrücklichem Funktionsauftrag |

Eine Kompatibilitätsmatrix enthält je Build SketchUp-Version einschließlich Wartungsstand, Betriebssystem, Ruby-Laufzeit, Prüfer, Datum und Ergebnis. „Vorgesehen“, „automatisch geprüft“ und „in SketchUp geprüft“ sind getrennte Zustände.

## 4. Produktprinzipien

1. Auswahl zuerst: Ein Werkzeug arbeitet auf der erkennbaren Auswahl oder fordert einen klar bezeichneten Zielbereich an.
2. Sofort verständlich: Ein häufiger Vorgang soll mit wenigen eindeutigen Aktionen erreichbar sein.
3. Kontextbewusst: Aktiver Bearbeitungskontext, Sperren, Instanzpfade und Sichtbarkeitsursachen werden berücksichtigt.
4. Reversibel: Dauerhafte Modelländerungen sind sinnvoll rückgängig zu machen; temporäre Zustände sind gezielt wiederherstellbar.
5. Datenbewahrend: Geometrie, Klassifizierung und fremde Attribute werden außerhalb des Auftrags nicht verändert.
6. Messbar: Nutzen und Leistung werden anhand desselben Ausgangsmodells vor und nach der Änderung verglichen.
7. Ehrlich geprüft: Keine Freigabe allein aufgrund fehlerfreier Syntax oder einer erzeugten RBZ.

## 5. Anforderungen

### FUN-01 – Auswahl und Bearbeitungskontext

Gruppen und Komponenten müssen gleichwertig adressierbar sein. Gemischte Auswahl, verschachtelte Objekte, gemeinsame Definitionen, gesperrte und inzwischen gelöschte Objekte sind zu behandeln. Der Einzelauftrag definiert, ob nur der aktive Kontext oder gezielt weitere Hierarchiestufen unterstützt werden.

Auswahlidentität wird kontextbezogen verwaltet; ein Objekt in einer gemeinsamen Definition bezeichnet nicht automatisch eine bestimmte platzierte Instanz. Veraltete UI-Ergebnisse dürfen nicht auf eine neue Auswahl angewendet werden.

### FUN-02 – Sichtbarkeit und Isolation

Werkzeuge für Isolation oder temporäres Ausblenden benötigen einen klaren Zustandsvertrag: Welche Objekte und Werte werden verändert, wann wird restauriert, und wie werden Nutzeränderungen währenddessen behandelt?

Vorher ausgeblendete Objekte dürfen beim Beenden nicht pauschal eingeblendet werden. Tags, Tag-Ordner, Szenen, versteckte Vorfahren und Bearbeitungskontext sind als getrennte Sichtbarkeitsursachen zu berücksichtigen. Die erste Umsetzung darf ihren unterstützten Kontext bewusst begrenzen, muss dies aber in UI und Dokumentation kenntlich machen.

Modellwechsel, neues Dokument, Schließen, Undo/Redo und gelöschte Objekte dürfen keinen fremden Modellzustand wiederherstellen. Temporäre Modelländerungen können den Speicherstatus beeinflussen; das Verhalten beim Speichern während eines aktiven Modus muss festgelegt und geprüft werden.

### FUN-03 – Hervorhebung und Transparenz

Zunächst die verfügbaren nativen Darstellungsoptionen und dokumentierten Zeichen-/Overlay-Möglichkeiten prüfen. Keine frei programmierbare native Auswahlfarbe versprechen, solange die API sie nicht nachweislich unterstützt.

Eine temporäre Hervorhebung soll Materialien möglichst nicht verändern. Falls Transparenz über Materialänderungen umgesetzt wird, sind Vererbung, Vorder-/Rückseitenmaterialien, gemeinsame Definitionen und vollständige Wiederherstellung Teil der Abnahme. Der Einzelauftrag legt die genaue Wirkung und Einschränkungen fest.

### FUN-04 – Referenzmodelle

Externe SKP-Modelle sollen als eindeutig benannte, separat schaltbare Referenzeinheit organisiert werden können. Herkunft, Dateipfad, Ladezeitpunkt und optionaler Aktualisierungsstatus müssen nachvollziehbar sein. Ein Import als Komponente bettet Modelldaten ein; er ist keine Garantie für eine externe Live-Verknüpfung oder geringen Speicherbedarf.

Für Aktualisierung sind Transformation, Benutzerzuordnung, Fehler bei fehlenden Dateien und unverträgliche Dateiversionen zu behandeln. Ein Verweis darf ohne ausdrücklichen Befehl keine Originaldatei überschreiben.

IFC-Exportausschluss ist ein eigener Nachweis: Exportweg, Schema, Optionen und tatsächlich exportierte Objekte dokumentieren. Falls nativ kein verlässlicher Ausschluss erreichbar ist, muss ein sicherer eigener Exportablauf untersucht und als eigene Funktion beauftragt werden. Kein Löschen oder Explodieren des produktiven Modells als unbeaufsichtigter Workaround.

### FUN-05 – Modellierhilfen

Spätere Transformations-, Ausrichtungs- oder Kopierwerkzeuge erhalten eine präzise geometrische Definition: Bezugssystem, Basispunkt, Achse, Distanz, Winkel, Toleranz und Umgang mit mehrfach verwendeten Komponenten. Vorschau und finale Geometrie müssen übereinstimmen.

### DAT-01 – Modell- und BIM-Datenintegrität

Lesevorgänge erzeugen keine persistenten Modelldaten. Insbesondere dürfen Analyse oder Auswahl weder IFC-Dictionaries noch Klassifizierungen anlegen. BASF_General, bestehende GUIDs sowie Instanz- und Definitionsnamen bleiben außerhalb eines ausdrücklichen Datenauftrags unangetastet.

Ein Werkzeug zur Geometrieänderung dokumentiert, welche Identitäten und Attribute erhalten bleiben und ob neue Objekte entstehen. Eine neue Instanz darf keine bestehende fachliche Identität unkontrolliert duplizieren. Für fachliche Datenänderungen ist ein separater Schreibplan mit Vorher-/Nachher-Prüfung nötig.

### UX-01 – Einheitliche Bedienung

- Ein konsistenter Menübereich, vorgesehen „TD Produktivitätswerkzeuge“, und eine optionale gemeinsame Toolbar.
- Kontextmenü für häufige auswahlbezogene Aktionen.
- Ein-/Ausschaltzustände und nicht verfügbare Aktionen sind sichtbar.
- ESC beendet aktive Interaktion; Enter bestätigt, soweit dies zur Werkzeuglogik passt.
- Shortcuts sind über SketchUp zuordenbar; bestehende Belegungen werden nicht automatisch überschrieben.
- Kurze Tooltips erläutern Funktion und Voraussetzung. Komplexere Werkzeuge erhalten eine kompakte Hilfe.
- Dialoge unterstützen Tastatur, Skalierung und relevante Fenstergrößen; keine abgeschnittenen Primäraktionen.
- Keine künstlichen Startdialoge für Ein-Klick-Werkzeuge. Fortschritt nur für tatsächlich längere Verarbeitung.
- Tabellen, falls erforderlich, mit passenden Filtern, Kopiermöglichkeit und nachvollziehbaren Einheiten.

### PERF-01 – Leistung in großen Modellen

Der Einzelauftrag nennt einen repräsentativen Testfall und ein Leistungsbudget. Vorläufige Entwicklungsziele: sichtbare Rückmeldung eines einfachen Auswahlbefehls innerhalb von 200 ms; einfache Verarbeitung von 1.000 ausgewählten Instanzen möglichst innerhalb einer Sekunde auf dokumentierter Testhardware. Diese Werte sind Ziele, keine bereits gemessenen Zusagen und keine Garantie für beliebige Modellkomplexität.

Benchmark-Stufen: 10, 100, 1.000 und 10.000 relevante Instanzen; mindestens ein verschachteltes, ein geometrisch komplexes und ein praxisnahes Modell. Testdaten dürfen synthetisch sein. Wiederholungen, Median, langsamster Lauf, Modellgröße, Gesamtzahl und Auswahlgröße werden dokumentiert.

Observer bündeln häufige Ereignisse. Fachliche Attribute und Geometrie werden nicht bei jedem Mausereignis neu gelesen. Ein großer Datensatz darf weder den Dialog mit unnötigen JSON-Daten überlasten noch unkontrolliert den gesamten Modellbaum rekursiv durchlaufen.

### STAB-01 – Transaktionen und Fehlerbehandlung

Eine dauerhafte Benutzeraktion entspricht grundsätzlich einem sinnvollen Undo-Schritt. Operationen werden nicht verschachtelt; ihre Verantwortung liegt in der Befehlsschicht. Hilfsfunktionen öffnen nicht still eigene Operationen.

Abbruch oder Fehler hinterlassen keinen teilweise angewendeten Auftrag. Vorschau, bereits abgeschlossene Änderungen und rein temporäre Ansichten werden nach jeweils dokumentierter Strategie behandelt. Undo und Redo dürfen weder Observer-Schleifen noch ungewollte erneute Schreibvorgänge auslösen.

## 6. Architektur und Repository-Struktur

Vorgesehene Struktur, noch nicht vollständig implementiert:

- AGENTS.md – verbindlicher Agentenauftrag.
- README.md – Einstieg und aktueller Projektstatus.
- docs/ENTWICKLUNGSAUFTRAG.md – dieses Entwicklungskonzept.
- docs/VORLAGE_WERKZEUGAUFTRAG.md – Einzelauftrag je Werkzeug.
- docs/VORLAGE_PRAXISTEST.md – Abnahme- und Testnachweis.
- docs/ROADMAP.md – Kandidaten, Prioritäten und Abhängigkeiten.
- CHANGELOG.md – nachvollziehbare Dokument- und später Produktänderungen.
- src/td_productivity_tools.rb – späterer Extension-Loader.
- src/td_productivity_tools/ – späterer Supportordner mit Commands, Tools, Services, UI und Ressourcen.
- test/ – automatisierte Logik- und Regressionstests.
- scripts/ – reproduzierbarer Build und Paketprüfung.
- dist/ – erzeugte Pakete; nicht automatisch im Quellrepository versionieren.
- docs/acceptance/ – ausgefüllte Testprotokolle.

Start mit einer modularen Extension und gemeinsamem Bedienrahmen. Werkzeuge bleiben fachlich getrennt und einzeln deaktivierbar. Separate RBZ-Pakete nur bei begründetem Bedarf; sie dürfen keine mehrfach geladenen gemeinsamen Bibliotheken erzeugen. Keine unnötige Plugin-Plattform vor dem ersten funktionierenden Werkzeug aufbauen.

Der Supportordner enthält alle Laufzeitressourcen. Der Loader bleibt schlank. Die spätere RBZ enthält auf oberster Ebene den Loader und den gleichnamigen Supportordner, keine zusätzliche Repository-Verzeichnisebene.

## 7. Entwicklungsablauf und GitHub-Nutzung

1. **Problem aufnehmen:** konkrete Ausgangssituation, native Alternative, gewünschter Nutzen.
2. **Einzelauftrag festlegen:** Funktionsgrenze, Datenwirkung, Bedienung und Abnahmekriterien.
3. **Technisch prüfen:** API-Nachweis; bei Unsicherheit kleiner isolierter Machbarkeitstest.
4. **Implementieren:** kleiner Feature-Branch, konsistente Architektur, verständliche Fehlermeldungen.
5. **Verifizieren:** passende automatische Checks und gezielte SketchUp-Praxistests.
6. **Bereitstellen:** versionierte RBZ, Installationshinweis, Änderungsliste, bekannte Grenzen.
7. **Prüfen lassen:** PR mit tatsächlichem Prüfnachweis; Tom prüft Bedienbarkeit und Praxisnutzen.
8. **Freigeben:** offene Fehler schließen oder ausdrücklich dokumentiert zurückstellen; Merge und Release nach entsprechender Beauftragung.

Wenn kein SketchUp-Testsystem verfügbar ist, endet die technische Lieferung mit dem Status „Entwicklungsbuild – Praxistest offen“. Eine solche Lieferung ist sinnvoll, aber noch keine Produktionsfreigabe.

GitHub Issues bilden Funktionsaufträge und Fehler ab. Feature-/Fix-Branches bleiben klein. Keine direkten Funktionsänderungen an main, kein Force-Push oder automatisches Merge im normalen Entwicklungsablauf. Quellcode, Dokumentation und Paket müssen demselben Commit zugeordnet sein.

## 8. Versionierung und Lieferumfang

Dokumentversion und Pluginversion sind voneinander unabhängig. Dieses Dokument hat Version 1.0.0 und bezeichnet keine fertige Pluginversion.

Vorgesehenes Paketschema für die neue Sammlung: SU_Productivity_Tools_v0.1.0_dev01.rbz. Produktivversionen nutzen beispielsweise SU_Productivity_Tools_v1.0.0.rbz. Ein bestätigter Paketstamm wird danach unverändert beibehalten.

Jeder Entwicklungsbuild erhält eine eindeutige Kennung; bereits veröffentlichte Pakete werden nicht mit anderem Inhalt überschrieben. Quellstand, Erweiterungsmetadaten und Changelog müssen zusammenpassen. Bei Quell-ZIPs sind Loader und Build-Anleitung enthalten; eine ZIP ersetzt die installierbare RBZ nicht.

Zur Lieferung gehören:
- Installierbare RBZ mit Prüfsumme und Commit-Zuordnung.
- Kurzbeschreibung, Installation, Bedienung und Deinstallation.
- Kompatibilitätsstatus und konkrete Testergebnisse.
- Bekannte Grenzen und gegebenenfalls kurze Prüfanleitung.
- Reproduzierbarer Paketbau ohne Entwicklungsdateien, Geheimnisse oder Kundenmodelle.

Eine optionale unversionierte Download-Kopie verweist auf denselben geprüften Paketinhalt. Bestehende Plugin-Dateinamen anderer Projekte werden durch diesen Auftrag nicht geändert.

## 9. Qualitätssicherung und Freigabekriterien

| ID | Kriterium | Nachweis |
| --- | --- | --- |
| QA-01 | Installation und Laden ohne Fehlermeldung, keine doppelten Menüs/Observer | Neustart, erneutes Öffnen, Updateprüfung |
| QA-02 | Richtige Zielobjekte und Bearbeitungskontexte | Gruppen, Komponenten, gemeinsame Definitionen, Verschachtelung |
| QA-03 | Gültiges Verhalten bei Sonderfällen | Leere/Mischselektion, Sperren, gelöschte Objekte |
| QA-04 | Dauerhafte Änderung sinnvoll rückgängig/wiederholbar | Vorher, Ausführung, Undo, Redo |
| QA-05 | Temporäre Zustände sauber restauriert | ESC, erneuter Aufruf, Modellwechsel, Szenenwechsel |
| QA-06 | Keine unbeauftragten Datenänderungen | Vorher-/Nachher-Vergleich von Geometrie, Namen, GUIDs und Attributen |
| QA-07 | Nachvollziehbare Leistung | Benchmark nach PERF-01 und Einzelbudget |
| QA-08 | Verständliche Bedienung und Meldungen | Praxistest, Skalierung und Tastatur |
| QA-09 | Korrektes Paket und aktualisierbare Installation | RBZ-Inhaltsprüfung, Versionsprüfung, Update aus Vorversion |
| QA-10 | Kompatibilität ehrlich ausgewiesen | Ausgefüllte Matrix pro Zielumgebung |
| QA-11 | Exportausschluss tatsächlich wirksam, falls beauftragt | Vergleich des exportierten IFC-Dateiinhalts |
| QA-12 | Zusammenwirken mit vorhandenen Werkzeugen | Gezielter Test mit relevanten installierten Extensions |

Nicht zutreffende Kriterien werden mit Begründung markiert. „Offen“, „bestanden“, „fehlgeschlagen“ und „nicht zutreffend“ sind unterschiedliche Zustände. Automatische Tests prüfen insbesondere Zustandslogik, Transformationen, Einheiten und Regressionen; UI und native SketchUp-Integration benötigen Praxistests.

Keine Freigabe bei Absturz, Datenverlust, falschen Zielobjekten, unkontrollierter Definitionsänderung oder nicht restaurierbaren temporären Zuständen. Sonstige Einschränkungen benötigen eine bewusste, dokumentierte fachliche Entscheidung.

## 10. Datenschutz, Abhängigkeiten und Wartbarkeit

Kundenmodelle, Zugangsdaten und interne Dateipfade gehören nicht in öffentliche Beispiele oder Logs. Diagnoseausgaben enthalten standardmäßig Version, Vorgang, Laufzeit und technische Fehler; Objektinhalte nur gezielt und bewusst.

Keine ungefragte Telemetrie, Hintergrundupdates oder Cloudübertragung. Externe Bibliotheken benötigen nachvollziehbare Herkunft, Lizenz und Version. Die Projektlizenz wird vom Repository-Eigentümer festgelegt; der Agent behauptet keine ungeprüfte Lizenzfreigabe.

## 11. Offizielle technische Referenzen

Geprüft am 15.11.2026; bei Implementierung erneut auf die konkrete Zielversion beziehen:

- Extension Requirements: https://ruby.sketchup.com/file.extension_requirements.html
- Model / Operationen und Kontext: https://ruby.sketchup.com/Sketchup/Model.html
- ModelObserver / Transaktionshinweise: https://ruby.sketchup.com/Sketchup/ModelObserver.html
- HtmlDialog: https://ruby.sketchup.com/UI/HtmlDialog.html
- Gesamtreferenz: https://ruby.sketchup.com/
- API-Releasehinweise: https://ruby.sketchup.com/file.ReleaseNotes.html

Die Quellen begründen technische API-Regeln. Leistungsziele, Produktumfang, Bedienkonzept und Roadmap sind Festlegungen dieses Projekts.

## 12. Änderungen dieses Auftrags

Änderungen erhöhen die Dokumentversion und werden im Changelog beschrieben. Bereits abgenommene Werkzeugaufträge werden nicht still rückwirkend erweitert. Bei Konflikten zwischen Auftrag und realer API wird die Einschränkung dokumentiert und eine konkrete Alternative vorgeschlagen.
