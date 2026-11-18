# encoding: UTF-8
require 'sketchup.rb'
require 'json'
require 'tmpdir'
require_relative 'cursor_info/settings'
require_relative 'cursor_info/reader'
require_relative 'cursor_info/attribute_scanner'
require_relative 'cursor_info/tool'
require_relative 'selection_highlight/settings'
require_relative 'selection_highlight/collector'
require_relative 'selection_highlight/overlay'
require_relative 'selection_highlight/manager'
module TD
  module ProductivityTools
    module CursorInfo
      def self.log(error)
        message = "#{Time.now.utc} #{VERSION} #{error.class}\n#{Array(error.backtrace).first(8).join("\n")}\n"
        File.open(File.join(Dir.tmpdir, 'TD_CursorInfo.log'), 'a') { |f| f.puts(message) }
        warn(message)
      rescue SystemCallError => log_error
        warn("Objektinfo: Protokoll nicht verfügbar (#{log_error.class})")
      end
      def self.fail_tool(error, model)
        log(error)
        model.select_tool(nil) if Sketchup.active_model == model
        UI.messagebox("Objektinfo wurde wegen eines Fehlers beendet (#{error.class}).\nTechnisches Protokoll: #{File.join(Dir.tmpdir, 'TD_CursorInfo.log')}")
      end
      def self.options
        if @dialog
          @dialog.bring_to_front
          return
        end
        @dialog = UI::HtmlDialog.new(dialog_title: "Objektinfo – Optionen (v#{VERSION})", preferences_key: PREFS + '.dialog',
                                     scrollable: true, resizable: true, width: 500, height: 680,
                                     style: UI::HtmlDialog::STYLE_DIALOG)
        @dialog.set_file(File.join(__dir__, 'cursor_info', 'options.html'))
        @dialog.add_action_callback('ready') do
          options = Settings.load
          scan = AttributeScanner.scan(Sketchup.active_model)
          attributes = (scan.keys + options['attributes']).uniq
          @dialog.execute_script("render(#{JSON.generate({fields: FIELDS, options: options, attributes: attributes, truncated: scan.truncated})})")
        end
        @dialog.add_action_callback('save') do |_ctx, json|
          begin
            Settings.save(JSON.parse(json))
            @dialog.close
            Sketchup.active_model.select_tool(Tool.new)
          rescue JSON::ParserError, ArgumentError, TypeError => error
            log(error)
            UI.messagebox('Bitte gültige Optionen eingeben.')
          end
        end
        @dialog.set_on_closed { @dialog = nil }
        @dialog.show
      end
    end
    unless file_loaded?(__FILE__)
      menu = UI.menu('Extensions').add_submenu('TD Produktivitätswerkzeuge')
      command = UI::Command.new('Objektinfo am Cursor') { Sketchup.active_model.select_tool(CursorInfo::Tool.new) }
      command.tooltip = 'Objektinfo am Cursor'
      command.status_bar_text = 'Objektinformationen beim Überfahren anzeigen; ESC beendet das Werkzeug.'
      command.small_icon = command.large_icon = File.join(__dir__, 'cursor_info', 'info.png')
      options = UI::Command.new('Objektinfo – Optionen') { CursorInfo.options }
      options.tooltip = 'Angezeigte Objektinformationen auswählen'
      menu.add_item(command)
      menu.add_item(options)
      highlight = UI::Command.new('Auswahl hervorheben') { SelectionHighlight.toggle }
      highlight.tooltip = 'Auswahl hervorheben ein/aus'
      highlight.status_bar_text = 'Ausgewählte Objekte mit transparenter Fläche und kräftigen Kanten hervorheben (nur Anzeige).'
      highlight.small_icon = highlight.large_icon = File.join(__dir__, 'selection_highlight', 'highlight.png')
      highlight.set_validation_proc { SelectionHighlight.enabled? ? MF_CHECKED : MF_UNCHECKED }
      highlight_options = UI::Command.new('Auswahl hervorheben – Optionen') { SelectionHighlight.options }
      highlight_options.tooltip = 'Farben, Deckkraft und Randstärke der Hervorhebung einstellen'
      menu.add_separator
      menu.add_item(highlight)
      menu.add_item(highlight_options)
      @toolbar = UI::Toolbar.new('TD Produktivitätswerkzeuge')
      @toolbar.add_item(command)
      @toolbar.add_item(highlight)
      @toolbar.restore
      Sketchup.add_observer(SelectionHighlight::AppObserver.new)
      SelectionHighlight.register(Sketchup.active_model) if Sketchup.active_model
      file_loaded(__FILE__)
    end
  end
end
