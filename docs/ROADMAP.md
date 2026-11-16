# Roadmap – Werkzeugkandidaten

Version: 1.0.0 | Stand: 15.11.2026 | Status: Vorschlag

Diese Liste priorisiert mögliche Werkzeuge. Alle Kandidaten sind in diesem Repository noch nicht implementiert. Priorität ist keine Beauftragung der gesamten Liste. Externe Vorversionen werden bei Bedarf gesondert geprüft.

| Reihenfolge | Werkzeug | Angestrebter Nutzen | Vor erster Umsetzung zu klären |
| --- | --- | --- | --- |
| 0 | Minimaler Extension-Rahmen | Saubere Installation, konsistente Befehle, reproduzierbares Paket | Eine gemeinsame RBZ, Zielversion und Prüfumgebung bestätigen |
| 1 | Auswahl isolieren / wiederherstellen | Ausgewählte Objekte in engen Modellen schnell bearbeiten | Vorhandene Lösung prüfen; Kontext, Tags, Szenen, Undo und Wiederherstellung definieren |
| 2 | Auswahl deutlicher hervorheben | Gewählte Bauteile auch in großen Modellen erkennen | Native Möglichkeiten, Overlay, Tiefenwirkung und Performance vergleichen |
| 3 | Auswahl temporär transparent | Hinter Bauteile sehen und Anschlussdetails bearbeiten | Materialfreie Lösung prüfen; sonst Instanz-/Definitionswirkung und Wiederherstellung nachweisen |
| 4 | SKP-Referenzmodell verwalten | Fremdmodelle gesammelt schalten und gezielt aktualisieren | Einbettung, Dateiquelle, Transformation, Aktualisierung und Dateifehler |
| 4a | Referenzen beim IFC-Export ausschließen | Eigenmodell ohne Referenzgeometrie exportieren | Eigener API-/Exportnachweis; nicht allein aus Sichtbarkeit ableiten |
| 5 | Kontextbezogene Auswahlhilfen | Bauteile mit wenigen Aktionen sammeln oder einschränken | Kriterien wie Typ, Material oder Tag je Einzelauftrag definieren |
| 6 | Ausrichten / Verschieben / Kopieren | Wiederkehrende Modellierschritte verkürzen | Bezugssystem, Fangpunkte, Einheiten, Vorschau und gemeinsame Definitionen |

Empfohlener erster vertikaler Durchstich: Minimaler Rahmen plus genau ein Werkzeug „Auswahl isolieren“. Zuerst Herkunft und Stand einer vorhandenen Lösung prüfen; dann eine kleine vollständige Bedienung mit Wiederherstellung und Praxistest liefern. Erst nach Bewährung weitere Module ergänzen.

## Entscheidung pro Werkzeug

Ein Werkzeug erhält nur dann einen eigenen Entwicklungsauftrag, wenn eine konkrete native Bedienlücke oder messbare Verbesserung vorliegt. Dokumentiert werden Ausgangsablauf, neuer Ablauf, Klickzahl, Zeitaufwand, Risiko und Testfall. Die weitere Reihenfolge wird anhand des Praxisnutzens angepasst.
