# encoding: UTF-8
require 'json'
module TD
  module ProductivityTools
    module CursorInfo
      VERSION = '0.2.0.dev01'.freeze
      PREFS = 'TD.ProductivityTools.CursorInfo'.freeze
      FIELDS = {
        'type' => 'Objekttyp', 'name' => 'Instanzname', 'definition' => 'Definitionsname',
        'description' => 'Komponentenbeschreibung', 'tag' => 'Tag', 'material' => 'Material (Zuweisung)',
        'back_material' => 'Rückseitenmaterial', 'volume' => 'Volumen', 'area' => 'Fläche',
        'length' => 'Länge', 'locked' => 'Gesperrt', 'hidden' => 'Ausgeblendet (Objekt)',
        'casts_shadows' => 'Schatten werfen', 'receives_shadows' => 'Schatten empfangen'
      }.freeze
      DEFAULTS = { 'fields' => %w[type name definition tag material volume], 'delay' => 400,
                   'font' => 13, 'hide_empty' => true, 'target' => 'part', 'position' => 'cursor' }.freeze
      module Settings
        def self.normalize(data)
          raise ArgumentError, 'Ungültige Optionen' unless data.is_a?(Hash)
          { 'fields' => Array(data.fetch('fields', DEFAULTS['fields'])).select { |key| FIELDS.key?(key) }.uniq,
            'delay' => [[Integer(data.fetch('delay', 400)), 0].max, 2000].min,
            'font' => [[Integer(data.fetch('font', 13)), 10].max, 24].min,
            'hide_empty' => data.fetch('hide_empty', true) == true,
            'target' => %w[part assembly geometry].include?(data['target']) ? data['target'] : 'part',
            'position' => data['position'] == 'corner' ? 'corner' : 'cursor' }
        end
        def self.load
          normalize(JSON.parse(Sketchup.read_default(PREFS, 'options', JSON.generate(DEFAULTS))))
        rescue JSON::ParserError, ArgumentError, TypeError => error
          CursorInfo.log(error)
          normalize(DEFAULTS)
        end
        def self.save(data)
          options = normalize(data)
          Sketchup.write_default(PREFS, 'options', JSON.generate(options))
          options
        end
      end
    end
  end
end
