# encoding: UTF-8
require 'tmpdir'
module TD
  module ProductivityTools
    module SelectionHighlight
      def self.log(error)
        message = "#{Time.now.utc} #{CursorInfo::VERSION} #{error.class}\n#{Array(error.backtrace).first(8).join("\n")}\n"
        File.open(File.join(Dir.tmpdir, 'TD_SelectionHighlight.log'), 'a') { |f| f.puts(message) }
        warn(message)
      rescue SystemCallError => log_error
        warn("Auswahl hervorheben: Protokoll nicht verfügbar (#{log_error.class})")
      end

      def self.settings
        @settings ||= Settings.load
      end

      def self.settings_version
        @settings_version ||= 0
      end

      def self.update_settings(data)
        @settings = Settings.save(data)
        @settings_version = settings_version + 1
      end

      def self.overlay_for(model)
        model.overlays.each { |overlay| return overlay if overlay.overlay_id == HighlightOverlay::ID }
        nil
      end

      def self.register(model)
        return if overlay_for(model)
        overlay = HighlightOverlay.new(model)
        model.overlays.add(overlay)
        overlay.enabled = settings['enabled']
      rescue StandardError => error
        log(error)
      end

      def self.toggle
        overlay = overlay_for(Sketchup.active_model)
        return UI.messagebox('Die Hervorhebung ist für dieses Modell nicht verfügbar.') unless overlay
        overlay.enabled = !overlay.enabled?
        update_settings(settings.merge('enabled' => overlay.enabled?))
        Sketchup.active_model.active_view.invalidate
      end

      def self.enabled?
        overlay = overlay_for(Sketchup.active_model)
        overlay ? overlay.enabled? : false
      end

      def self.options
        current = settings
        yes_no = %w[Ja Nein]
        names = COLORS.keys
        prompts = ['Flächen füllen', 'Füllfarbe', 'Deckkraft der Füllung (%, 5–90)', 'Randfarbe', 'Randstärke (Pixel, 1–8)']
        defaults = [current['fill'] ? 'Ja' : 'Nein', current['fill_color'], current['opacity'],
                    current['edge_color'], current['edge_width']]
        lists = [yes_no.join('|'), names.join('|'), '', names.join('|'), '']
        result = UI.inputbox(prompts, defaults, lists, 'Auswahl hervorheben – Optionen')
        return unless result
        update_settings('enabled' => current['enabled'], 'fill' => result[0] == 'Ja', 'fill_color' => result[1],
                        'opacity' => result[2], 'edge_color' => result[3], 'edge_width' => result[4])
        Sketchup.active_model.active_view.invalidate
      rescue ArgumentError, TypeError => error
        log(error)
        UI.messagebox('Bitte gültige Optionen eingeben.')
      end

      class AppObserver < Sketchup::AppObserver
        def expectsStartupModelNotifications
          true
        end

        def onNewModel(model)
          SelectionHighlight.register(model)
        end
        alias onOpenModel onNewModel
      end
    end
  end
end
