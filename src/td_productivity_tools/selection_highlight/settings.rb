# encoding: UTF-8
require 'json'
require_relative '../prefs_store'
module TD
  module ProductivityTools
    module SelectionHighlight
      PREFS = 'TD.ProductivityTools.SelectionHighlight'.freeze
      PREFS_FILE = 'SelectionHighlight'.freeze
      COLORS = {
        'Orange' => [255, 140, 0], 'Rot' => [230, 30, 30], 'Gelb' => [255, 220, 0],
        'Grün' => [0, 190, 80], 'Cyan' => [0, 200, 230], 'Blau' => [30, 90, 255],
        'Magenta' => [230, 0, 200]
      }.freeze
      DEFAULTS = { 'enabled' => true, 'fill' => true, 'fill_color' => 'Orange', 'opacity' => 40,
                   'edge_color' => 'Rot', 'edge_width' => 3 }.freeze
      module Settings
        def self.normalize(data)
          raise ArgumentError, 'Ungültige Optionen' unless data.is_a?(Hash)
          { 'enabled' => data.fetch('enabled', true) == true,
            'fill' => data.fetch('fill', true) == true,
            'fill_color' => COLORS.key?(data['fill_color']) ? data['fill_color'] : DEFAULTS['fill_color'],
            'opacity' => [[Integer(data.fetch('opacity', 40)), 5].max, 90].min,
            'edge_color' => COLORS.key?(data['edge_color']) ? data['edge_color'] : DEFAULTS['edge_color'],
            'edge_width' => [[Integer(data.fetch('edge_width', 3)), 1].max, 8].min }
        end

        def self.load
          normalize((PrefsStore.read(PREFS_FILE) || DEFAULTS))
        rescue JSON::ParserError, ArgumentError, TypeError, SystemCallError, ScriptError => error
          SelectionHighlight.log(error)
          normalize(DEFAULTS)
        end

        def self.save(data)
          options = normalize(data)
          PrefsStore.write(PREFS_FILE, options)
          options
        end
      end
    end
  end
end
