# encoding: UTF-8
# GFA / BSV Creator | 0.1.0.dev03 | 27.11.2026 | TD für Tom
require 'sketchup.rb'
require 'extensions.rb'
module TD
  module GFABSVCreator
    unless file_loaded?(__FILE__)
      extension = SketchupExtension.new('GFA / BSV Creator', 'td_gfa_bsv_creator/main')
      extension.description = 'Eigenständige GFA-Flächen und geschlossene BSV-Hüllen aus Modellobjekten. Entwicklungsbuild; SketchUp-Praxistest offen.'
      extension.version = '0.1.0.dev03'
      extension.creator = 'TD – im Auftrag von Tom'
      Sketchup.register_extension(extension, true)
      file_loaded(__FILE__)
    end
  end
end
