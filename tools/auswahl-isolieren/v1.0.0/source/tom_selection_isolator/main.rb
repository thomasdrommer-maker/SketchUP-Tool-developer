# encoding: UTF-8
# Auswahl isolieren | Version 1.0.0 | 15.11.2026
# Autor: OpenAI Codex für Tom
# Changelog: 1.0.0 – Kontextmenü, weitere Eingrenzung, persistente Wiederherstellung.
require 'sketchup.rb'
require 'json'

module TomTools
  module SelectionIsolator
    DICTIONARY = 'TomTools_SelectionIsolator'.freeze
    STATE_KEY = 'state_v1'.freeze
    RENDER_KEYS = %w[DrawHidden ROPDrawHiddenGeometry ROPDrawHiddenObjects].freeze

    def self.active?(model = Sketchup.active_model)
      !model.get_attribute(DICTIONARY, STATE_KEY).nil?
    end

    def self.object?(entity)
      entity.is_a?(Sketchup::Group) || entity.is_a?(Sketchup::ComponentInstance)
    end

    def self.selected_objects(model)
      model.selection.to_a.select { |entity| entity.valid? && object?(entity) && !entity.hidden? }
    end

    def self.read_state(model)
      raw = model.get_attribute(DICTIONARY, STATE_KEY)
      raw ? JSON.parse(raw) : { 'hidden_ids' => [], 'rendering' => {} }
    end

    # At each enclosing level keep the open instance visible. Never recurse
    # through unrelated definitions: cost scales with siblings, not model depth.
    def self.candidates(model, selection)
      result = []
      entities = model.entities
      (model.active_path || []).each do |instance|
        entities.each { |entity| result << entity unless entity == instance }
        entities = instance.definition.entities
      end
      keep = selection.each_with_object({}) { |entity, hash| hash[entity] = true }
      model.active_entities.each { |entity| result << entity unless keep[entity] }
      result.uniq.select do |entity|
        entity.valid? && entity.is_a?(Sketchup::Drawingelement) &&
          !entity.is_a?(Sketchup::SectionPlane) && !entity.hidden?
      end
    end

    def self.isolate
      model = Sketchup.active_model
      selection = model.selection.to_a
      objects = selected_objects(model)
      if objects.empty? || objects.length != selection.length
        UI.messagebox('Bitte nur eine oder mehrere sichtbare Gruppen/Komponenten in der aktuellen Bearbeitungsebene auswählen.')
        return
      end
      state = read_state(model)
      hide = candidates(model, objects)
      model.start_operation('Auswahl isolieren', true)
      started = true
      options = model.rendering_options
      available = options.map { |key, _value| key }
      RENDER_KEYS.each do |key|
        next unless available.include?(key)
        state['rendering'][key] = options[key] unless state['rendering'].key?(key)
        options[key] = false
      end
      hide.each do |entity|
        state['hidden_ids'] << entity.persistent_id
        entity.hidden = true
      end
      state['hidden_ids'].uniq!
      model.set_attribute(DICTIONARY, STATE_KEY, JSON.generate(state))
      model.commit_operation
      started = false
      model.active_view.invalidate
      Sketchup.status_text = "Isolation aktiv: #{objects.length} Objekt(e). Rechtsklick → Isolation aufheben."
    rescue StandardError => error
      model.abort_operation if started
      warn("[Tom Auswahl isolieren] #{error.class}: #{error.message}\n#{error.backtrace.join("\n")}")
      UI.messagebox("Die Isolation konnte nicht ausgeführt werden.\n#{error.message}")
    end

    def self.restore
      model = Sketchup.active_model
      return unless active?(model)
      state = read_state(model)
      model.start_operation('Isolation aufheben', true)
      started = true
      state['hidden_ids'].each do |pid|
        entity = model.find_entity_by_persistent_id(pid)
        entity.hidden = false if entity && entity.valid?
      end
      options = model.rendering_options
      available = options.map { |key, _value| key }
      state['rendering'].each { |key, value| options[key] = value if available.include?(key) }
      model.delete_attribute(DICTIONARY, STATE_KEY)
      model.commit_operation
      started = false
      model.active_view.invalidate
      Sketchup.status_text = 'Isolation aufgehoben. Vorherige Sichtbarkeit wiederhergestellt.'
    rescue StandardError => error
      model.abort_operation if started
      warn("[Tom Auswahl isolieren] #{error.class}: #{error.message}\n#{error.backtrace.join("\n")}")
      UI.messagebox("Die Isolation konnte nicht aufgehoben werden.\n#{error.message}")
    end

    def self.toggle
      active? ? restore : isolate
    end

    unless file_loaded?(__FILE__)
      isolate_command = UI::Command.new('Auswahl isolieren') { isolate }
      isolate_command.tooltip = 'Ausgewählte Gruppen/Komponenten isolieren; erneut ausführen zum weiteren Eingrenzen.'
      isolate_command.set_validation_proc do
        model = Sketchup.active_model
        selection = model.selection.to_a
        !selection.empty? && selected_objects(model).length == selection.length ? MF_ENABLED : MF_GRAYED
      end
      restore_command = UI::Command.new('Isolation aufheben') { restore }
      restore_command.set_validation_proc { active? ? MF_ENABLED : MF_GRAYED }
      toggle_command = UI::Command.new('Isolation umschalten') { toggle }
      toggle_command.tooltip = 'Ein Tastenkürzel: Auswahl isolieren / Isolation aufheben.'
      menu = UI.menu('Plugins').add_submenu('Tom – Auswahl isolieren')
      menu.add_item(isolate_command)
      menu.add_item(restore_command)
      menu.add_item(toggle_command)
      UI.add_context_menu_handler do |context|
        model = Sketchup.active_model
        selection = model.selection.to_a
        eligible = !selection.empty? && selected_objects(model).length == selection.length
        if eligible || active?(model)
          context.add_separator
          context.add_item(isolate_command) if eligible
          context.add_item(restore_command) if active?(model)
        end
      end
      file_loaded(__FILE__)
    end
  end
end
