# encoding: UTF-8
require 'digest'
module TD
  module GFABSVCreator
    module BuildingMetrics
      module Collector
        module_function
        def collect(model)
          raise ArgumentError, 'Bitte zuerst den geöffneten Gruppen-/Komponentenkontext verlassen. Messobjekte werden auf Modellebene erstellt.' if model.active_path
          sources = model.selection.to_a
          raise ArgumentError, 'Bitte Gruppen, Komponenten, Flächen oder Kanten auswählen.' if sources.empty?
          unless sources.all? { |e| e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance) || e.is_a?(Sketchup::Face) || e.is_a?(Sketchup::Edge) }
            raise ArgumentError, 'Auswahl enthält nicht unterstützte Objekte. Nur Gruppen, Komponenten, Flächen und Kanten wählen.'
          end
          state = {points: {}, visits: 0, hidden: 0, started: Process.clock_gettime(Process::CLOCK_MONOTONIC)}
          sources.each { |entity| visit(model, entity, Geom::Transformation.new, [], state) }
          points = state[:points].values.sort
          raise ArgumentError, 'Keine auswertbare sichtbare Geometrie in der Auswahl.' if points.size < 3
          ids = sources.map(&:persistent_id).sort
          {points: points, ids: ids, digest: Digest::SHA256.hexdigest(JSON.generate([ids, points])),
           visits: state[:visits], hidden: state[:hidden], elapsed_ms: ((Process.clock_gettime(Process::CLOCK_MONOTONIC)-state[:started])*1000).round}
        end
        def visit(model, entity, transform, path, state)
          state[:visits] += 1
          if state[:visits] > 150_000 || Process.clock_gettime(Process::CLOCK_MONOTONIC)-state[:started] > 8
            raise ArgumentError, 'Auswahl zu komplex (150.000 Objekte / 8 Sekunden). Bitte Teilbereiche auswählen.'
          end
          raise ArgumentError, 'Auswahl enthält ungültige Objekte.' unless entity.valid?
          full_path = path + [entity]
          unless model.drawing_element_visible?(full_path)
            state[:hidden] += 1
            return
          end
          if entity.get_attribute(DICT, 'measurement_id')
            raise ArgumentError, 'Auswahl enthält bereits ein GFA-/BSV-Messobjekt. Bitte nur Quellobjekte auswählen.'
          end
          case entity
          when Sketchup::Group, Sketchup::ComponentInstance
            child_transform = transform * entity.transformation
            entity.definition.entities.each { |child| visit(model, child, child_transform, full_path, state) if child.is_a?(Sketchup::Drawingelement) }
          when Sketchup::Face, Sketchup::Edge
            entity.vertices.each do |vertex|
              values = vertex.position.transform(transform).to_a.map { |v| v.to_f * 0.0254 }
              key = values.map { |v| (v/Geometry::EPS).round }
              state[:points][key] ||= values
              raise ArgumentError, 'Mehr als 100.000 eindeutige Punkte. Bitte Auswahl vereinfachen.' if state[:points].size > 100_000
            end
          end
        end
      end
    end
  end
end
