# Praxistest und Abnahme: <Werkzeug / Build>

Datum / Prüfer: ___  
Auftrag / PR: ___  
Pluginversion / RBZ / SHA-256 / Commit: ___  
SketchUp-Version einschließlich Wartungsstand: ___  
Betriebssystem / Ruby / relevante andere Extensions: ___  
Hardware / Modellgröße / Objektzahl / Auswahl / Verschachtelung: ___

Kopie oder synthetisches Testmodell verwenden. Keine vertraulichen Modellinhalte in das Protokoll übernehmen.

Zulässige Ergebnisse: bestanden / fehlgeschlagen / offen / nicht zutreffend mit Begründung.

| Test | Erwartung | Ergebnis und Beobachtung |
| --- | --- | --- |
| Installation und Neustart | Extension lädt; Menü und Toolbar einmal vorhanden | offen |
| Update von Vorversion | Neuer Stand aktiv; keine doppelten Commands | offen |
| Standardablauf | Ergebnis entspricht Einzelauftrag | offen |
| Leere und gemischte Auswahl | Verständliche Reaktion ohne unerwünschte Änderung | offen |
| Gruppen und Komponenten | Dokumentierte gleichwertige Unterstützung | offen |
| Gemeinsame Definitionen | Keine unbeabsichtigte Wirkung auf andere Instanzen | offen |
| Verschachtelung / offener Kontext | Richtige Zielobjekte und Transformationen | offen |
| Sperren / gelöschte Objekte | Sicheres Verhalten mit verständlicher Rückmeldung | offen |
| Skalierung / Spiegelung / Z ungleich 0 | Geometrie und Vorschau stimmen, falls relevant | offen |
| Undo / Redo | Genau die dokumentierte Änderung | offen |
| ESC / erneuter Aufruf | Temporärer Zustand korrekt beendet | offen |
| Bereits versteckte Objekte / Tags / Szenen | Ursprüngliche und bewusste neue Zustände bleiben korrekt | offen |
| Modellwechsel / Schließen | Kein fremder Zustand, keine zurückbleibenden Observer | offen |
| Speichern während Aktivierung | Verhalten entspricht Zustandsvertrag | offen |
| Attribute / IFC / GUID / Geometrie | Keine unbeauftragten Änderungen | offen |
| Leistung | Einzelbudget am dokumentierten Modell erfüllt | offen |
| UI / Tastatur / Skalierung | Bedienelemente erreichbar und verständlich | offen |
| Referenzexport, falls enthalten | Exportierter Dateiinhalt enthält keine ausgeschlossenen Referenzen | offen |

## Messungen

| Lauf / Fall | Anzahl insgesamt / Auswahl | Zeit | Übertragungsgröße, falls relevant | Beobachtung |
| --- | --- | --- | --- | --- |
| ___ | ___ | ___ | ___ | ___ |

Anzahl Wiederholungen / Median / langsamster Lauf / Vergleich zum Ausgangsablauf: ___

## Automatische Prüfungen

Befehl / Umgebung / Ergebnis: ___  
Welche SketchUp-Laufzeiteigenschaften dadurch nicht geprüft wurden: ___

## Fachliche Entscheidung

Gesamtstatus: offen  
Blockierende Fehler: ___  
Bekannte Grenzen: ___  
Nächste konkrete Prüfung: ___  
Abnahme durch Tom / Datum: ___
