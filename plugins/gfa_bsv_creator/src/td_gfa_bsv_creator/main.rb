# encoding: UTF-8
require 'sketchup.rb'
require_relative 'building_metrics/main'
module TD
  module GFABSVCreator
    unless file_loaded?(__FILE__)
      command = UI::Command.new('GFA / BSV Creator öffnen') { BuildingMetrics.open }
      command.tooltip = 'GFA / BSV Creator'
      command.status_bar_text = 'Ausgewählte Modellobjekte als Fläche oder geschlossene Raumhülle auswerten.'
      command.small_icon = command.large_icon = File.join(__dir__, 'building_metrics', 'metrics.png')
      menu = UI.menu('Extensions').add_submenu('GFA / BSV Creator')
      menu.add_item(command)
      @toolbar = UI::Toolbar.new('GFA / BSV Creator')
      @toolbar.add_item(command)
      @toolbar.restore
      UI.add_context_menu_handler do |context|
        selection = Sketchup.active_model.selection
        supported = [Sketchup::Group, Sketchup::ComponentInstance, Sketchup::Face, Sketchup::Edge]
        if !selection.empty? && selection.all? { |e| supported.any? { |type| e.is_a?(type) } }
          context.add_item(command)
        end
      end
      file_loaded(__FILE__)
    end
  end
end
