# encoding: UTF-8
# TD Produktivitätswerkzeuge | 0.1.0.dev01 | 18.11.2026 | Auftraggeber: Tom
require 'sketchup.rb'
require 'extensions.rb'
module TD
  module ProductivityTools
    unless file_loaded?(__FILE__)
      extension = SketchupExtension.new('TD Produktivitätswerkzeuge – Objektinfo', 'td_productivity_tools/main')
      extension.description = 'Konfigurierbare Objektinformationen am Cursor. Entwicklungsbuild; SketchUp-Praxistest offen.'
      extension.version = '0.1.0.dev01'
      extension.creator = 'TD – im Auftrag von Tom'
      Sketchup.register_extension(extension, true)
      file_loaded(__FILE__)
    end
  end
end
