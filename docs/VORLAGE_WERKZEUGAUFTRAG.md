# Werkzeugauftrag: <Name>

ID: TOOL-___  
Version / Datum: ___  
Status: Entwurf / beauftragt / in Entwicklung / Praxistest / abgenommen  
Verantwortlich / Abnahme: ___  
Issue / Branch / Zielbuild: ___

## Anwenderproblem und Ergebnis

Konkrete Ausgangssituation: ___  
Bisheriger nativer Ablauf und dessen Grenze: ___  
Gewünschter Ablauf mit Beispielauswahl: ___  
Messbarer Nutzen: ___  
Bewusste Funktionsgrenze: ___

## Zielumgebung und Modellfall

SketchUp-Version / Betriebssystem: ___  
Testmodell, Objektzahl, Verschachtelung, Auswahlgröße: ___  
Gruppen / Komponenten / gemeinsame Definitionen / Sperren: ___  
Aktiver Kontext und zulässige Hierarchieebenen: ___

## Bedienvertrag

Einstieg über Menü / Kontextmenü / Toolbar: ___  
Eingaben und Standardwerte: ___  
Vorschau, Status und Rückmeldungen: ___  
Bestätigen / ESC / erneuter Aufruf: ___  
Leere Auswahl und Fehlerfälle: ___  
Änderungen der Auswahl während aktiver Funktion: ___

## Modell- und Zustandsvertrag

Gelesene Daten: ___  
Dauerhaft geschriebene Daten: ___  
Temporär veränderte Zustände: ___  
Instanz- gegenüber Definitionswirkung: ___  
Undo-/Redo-Strategie: ___  
Wiederherstellung bei Abbruch, Fehler, Modell- und Szenenwechsel: ___  
Verhalten beim Speichern im aktiven Modus: ___  
Umgang mit zwischenzeitlichen Nutzeränderungen und gelöschten Objekten: ___  
BIM-/IFC-Auswirkung: ___

## Technischer Nachweis

Benötigte API, Mindestversion, offizielle Quelle und Prüfdatum: ___  
Offene Machbarkeitsfragen / kurzer Versuch: ___  
Abhängigkeiten und Lizenzen: ___  
Leistungsbudget und Messmethode: ___

## Abnahmekriterien

| ID | Testhandlung | Erwartetes Ergebnis | Nachweis |
| --- | --- | --- | --- |
| AC-01 | ___ | ___ | ___ |
| AC-02 | Abbrechen | Definierter Ausgangszustand ist wiederhergestellt | ___ |
| AC-03 | Undo und Redo, falls Modelländerung | Nur vorgesehene Aktion wird rückgängig/wiederholt | ___ |
| AC-04 | Sonderfälle und Kontext | Keine unbeauftragte Änderung anderer Instanzen | ___ |
| AC-05 | Leistung am Zielmodell | Budget eingehalten oder Abweichung dokumentiert | ___ |

## Lieferung

RBZ-Dateiname / Pluginversion / Commit: ___  
Automatische Prüfungen: ___  
SketchUp-Praxistests: ___  
Bekannte Grenzen / offene Punkte: ___  
Anwenderhinweise und Installation: ___
