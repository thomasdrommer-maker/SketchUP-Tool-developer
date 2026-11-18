# encoding: UTF-8
# Auswahl isolieren | Version 1.0.0 | 15.11.2026
# Autor: OpenAI Codex für Tom | Changelog: Erstveröffentlichung
require 'sketchup.rb'
require 'extensions.rb'

module TomTools
  module SelectionIsolator
    unless file_loaded?(__FILE__)
      extension = SketchupExtension.new('Tom – Auswahl isolieren', 'tom_selection_isolator/main')
      extension.description = 'Mehrere Gruppen/Komponenten isolieren und vorherige Sichtbarkeit wiederherstellen.'
      extension.version = '1.0.0'
      extension.creator = 'OpenAI Codex für Tom'
      Sketchup.register_extension(extension, true)
      file_loaded(__FILE__)
    end
  end
end
