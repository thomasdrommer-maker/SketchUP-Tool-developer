# encoding: UTF-8
module TD
  module ProductivityTools
    module SelectionHighlight
      # Liest die Auswahl rein lesend und liefert Dreiecke und Kantenlinien in Modellkoordinaten.
      module Collector
        MAX_TRIANGLES = 60_000
        MAX_EDGES = 120_000
        OFFSET = 1.mm
        Result = Struct.new(:triangles, :edges, :truncated, :bounds)

        def self.collect(model)
          state = { tris: [], edges: [], truncated: false }
          base = model.edit_transform
          model.selection.each do |entity|
            next unless entity.valid?
            visit(entity, base, state, true)
            break if state[:truncated]
          end
          bounds = Geom::BoundingBox.new
          bounds.add(state[:tris]) unless state[:tris].empty?
          bounds.add(state[:edges]) unless state[:edges].empty?
          Result.new(state[:tris], state[:edges], state[:truncated], bounds)
        end

        def self.visit(entity, transformation, state, selected)
          return if state[:truncated]
          return unless !entity.respond_to?(:visible?) || entity.visible?
          case entity
          when Sketchup::Face
            add_face(entity, transformation, state)
            entity.edges.each { |edge| add_edge(edge, transformation, state) } if selected
          when Sketchup::Edge
            add_edge(entity, transformation, state)
          when Sketchup::Group
            descend(entity.entities, transformation * entity.transformation, state)
          when Sketchup::ComponentInstance
            descend(entity.definition.entities, transformation * entity.transformation, state)
          end
        end

        def self.descend(entities, transformation, state)
          entities.each do |child|
            visit(child, transformation, state, false)
            return if state[:truncated]
          end
        end

        def self.add_edge(edge, transformation, state)
          return if edge.hidden? || edge.soft?
          if state[:edges].length >= MAX_EDGES
            state[:truncated] = true
            return
          end
          state[:edges] << edge.start.position.transform(transformation)
          state[:edges] << edge.end.position.transform(transformation)
        end

        def self.add_face(face, transformation, state)
          mesh = face.mesh(0)
          normal = face.normal.transform(transformation)
          return unless normal.valid?
          shift = normal.normalize
          shift.length = OFFSET
          back = shift.reverse
          points = mesh.points.map { |point| point.transform(transformation) }
          mesh.polygons.each do |polygon|
            if state[:tris].length >= MAX_TRIANGLES * 6
              state[:truncated] = true
              return
            end
            corners = polygon.map { |index| points[index.abs - 1] }
            # Beide Seiten leicht versetzt; die verdeckte Seite wird von der Fläche selbst abgeschirmt.
            corners.each { |point| state[:tris] << (point + shift) }
            corners.each { |point| state[:tris] << (point + back) }
          end
        end
      end
    end
  end
end
