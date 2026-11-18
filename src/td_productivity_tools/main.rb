# encoding: UTF-8
require 'sketchup.rb'
require 'json'
require 'tmpdir'
require_relative 'cursor_info/settings'
require_relative 'cursor_info/reader'
require_relative 'cursor_info/tool'
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
        @dialog = UI::HtmlDialog.new(dialog_title: 'Objektinfo – Optionen', preferences_key: PREFS + '.dialog',
                                     scrollable: true, resizable: true, width: 500, height: 680,
                                     style: UI::HtmlDialog::STYLE_DIALOG)
        @dialog.set_file(File.join(__dir__, 'cursor_info', 'options.html'))
        @dialog.add_action_callback('ready') do
          @dialog.execute_script("render(#{JSON.generate({fields: FIELDS, options: Settings.load})})")
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
      @toolbar = UI::Toolbar.new('TD Produktivitätswerkzeuge')
      @toolbar.add_item(command)
      @toolbar.restore
      file_loaded(__FILE__)
    end
  end
end
