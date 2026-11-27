# SketchUP-Tool-developer

Professionelle SketchUp-Desktop-Werkzeuge für effizienteres Modellieren und bessere Orientierung in großen Modellen. Auftraggeber: Tom.

## GFA / BSV Creator – eigenständiges Plugin

Separate Extension für Geschossflächen und geschlossene Gebäude-/Strukturhüllen aus ausgewählten Modellobjekten. Eigener Loader, Menü, Toolbar und RBZ; keine Abhängigkeit von den Produktivitätswerkzeugen.

- [RBZ v0.1.0.dev02](downloads/SU_GFA_BSV_Creator_v0.1.0_dev02.rbz) · [Prüfsumme](downloads/SU_GFA_BSV_Creator_v0.1.0_dev02.rbz.sha256)
- [Bedienung und Grenzen](docs/GFA_BSV_CREATOR.md) · [Praxistest](docs/acceptance/GFA_BSV_CREATOR_dev02.md)
- [Entwicklungsauftrag v1.1.0](docs/ENTWICKLUNGSAUFTRAG_GFA_BSV.md) · Quellcode: `plugins/gfa_bsv_creator/`
- SketchUp Desktop 2026, Ziel Windows 11. **Entwicklungsbuild – SketchUp-Praxistest offen.**

## Auswahl hervorheben – Entwicklungsbuild 0.2.0.dev01

Auf dem Branch `feature/selection-highlight-dev01`: ausgewählte Objekte werden mit halbtransparenter Fläche und kräftigen Kanten hervorgehoben (SketchUp-Overlay, nur Anzeige).

- [RBZ herunterladen](downloads/SU_Productivity_Tools_v0.2.0_dev01.rbz) · [Prüfsumme](downloads/SU_Productivity_Tools_v0.2.0_dev01.rbz.sha256)
- [Bedienung und Grenzen](docs/AUSWAHL_HERVORHEBEN.md) · [Praxistest](docs/acceptance/AUSWAHL_HERVORHEBEN_dev02.md)
- **Status: SketchUp-Praxistest offen.** Enthält zusätzlich die Objektinfo (siehe unten).

## Objektinfo am Cursor – erster Entwicklungsbuild

Auf dem Feature-Branch implementiert: konfigurierbare Infobox beim Überfahren von Gruppen, Komponenten, Flächen und Kanten. Eigener aktiver Prüfmodus mit Toolbar, deutschen Optionen und dauerhaft gespeicherter Feldauswahl.

- [RBZ herunterladen](downloads/SU_Productivity_Tools_v0.1.0_dev02.rbz) – Datei öffnen und „Download raw file“ wählen.
- [Bedienung, Umfang und Grenzen](docs/OBJEKTINFO.md)
- [Prüfprotokoll und Praxistest](docs/acceptance/OBJEKTINFO_dev01.md)
- [Prüfsumme](downloads/SU_Productivity_Tools_v0.1.0_dev02.rbz.sha256)

**Status: Entwicklungsbuild 0.1.0.dev01; SketchUp-Praxistest offen.** Ziel: SketchUp 2026 unter Windows 11. Keine nachgewiesene SketchUp-Laufzeitkompatibilität in dieser Umgebung. IFC/BASF-Felder sind noch nicht enthalten.

Installation über SketchUp Erweiterungsmanager; anschließend Erweiterungen → TD Produktivitätswerkzeuge → Objektinfo am Cursor. ESC beendet, TAB öffnet Optionen. Lokales Git oder eine Entwicklungsumgebung ist zum Installieren nicht erforderlich.

## Entwicklung

- [Agentenauftrag](AGENTS.md)
- [Entwicklungskonzept](docs/ENTWICKLUNGSAUFTRAG.md)
- [Roadmap](docs/ROADMAP.md) – weitere Kandidaten sind noch nicht umgesetzt.
- [Changelog](CHANGELOG.md)
- Quellcode: `src/`; reproduzierbarer Paketbau: `python scripts/build.py`.

Der neue gemeinsame Rahmen enthält ausschließlich Objektinfo. Frühere eigenständige Isolier-/Auswahlfarbenwerkzeuge aus anderen Branches werden damit nicht ersetzt oder verändert.
