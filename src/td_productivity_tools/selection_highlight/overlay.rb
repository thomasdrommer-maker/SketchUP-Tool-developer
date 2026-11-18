# encoding: UTF-8
module TD
  module ProductivityTools
    module SelectionHighlight
      # Meldet Änderungen nur per Flag; keine Modellzugriffe und keine Berechnung im Callback.
      class ChangeObserver
        def initialize(overlay)
          @overlay = overlay
        end

        def onSelectionBulkChange(_selection)
          @overlay.mark_dirty
        end
        alias onSelectionCleared onSelectionBulkChange

        def onSelectionAdded(_selection, _entity)
          @overlay.mark_dirty
        end
        alias onSelectionRemoved onSelectionAdded

        def onTransactionCommit(_model)
          @overlay.mark_dirty
        end
        alias onTransactionUndo onTransactionCommit
        alias onTransactionRedo onTransactionCommit
        alias onActivePathChanged onTransactionCommit
      end

      class HighlightOverlay < Sketchup::Overlay
        ID = 'td.productivity_tools.selection_highlight'.freeze
        SIGNATURE_LIMIT = 200

        def initialize(model)
          super(ID, 'TD Auswahl hervorheben',
                description: 'Hebt ausgewählte Objekte mit transparenter Fläche und kräftigen Kanten hervor.')
          @model = model
          @observer = ChangeObserver.new(self)
          @cache = nil
          @dirty = true
          @failed = false
          @settings_version = -1
        end

        def start
          @model.selection.add_observer(@observer)
          @model.add_observer(@observer)
          mark_dirty
        end

        def stop
          @model.selection.remove_observer(@observer)
          @model.remove_observer(@observer)
          @cache = nil
        rescue StandardError => error
          SelectionHighlight.log(error)
        end

        def mark_dirty
          @dirty = true
          @failed = false
          @model.active_view.invalidate
        end

        def draw(view)
          return if @failed
          refresh
          return unless @cache
          if @settings['fill'] && !@cache.triangles.empty?
            view.drawing_color = @fill_color
            view.draw(GL_TRIANGLES, @cache.triangles)
          end
          unless @cache.edges.empty?
            view.line_stipple = ''
            view.line_width = @settings['edge_width']
            view.drawing_color = @edge_color
            view.draw(GL_LINES, @cache.edges)
          end
          return unless @cache.truncated
          view.draw_text(Geom::Point3d.new(12, 12, 0), 'Hervorhebung gekürzt: Auswahl zu umfangreich',
                         size: 12, color: 'red')
        rescue StandardError => error
          fail_with(error)
        end

        def getExtents
          bounds = Geom::BoundingBox.new
          bounds.add(@model.bounds)
          refresh unless @failed
          bounds.add(@cache.bounds) if @cache && @cache.bounds.valid?
          bounds
        rescue StandardError => error
          fail_with(error)
          @model.bounds
        end

        private

        def refresh
          reload_settings if @settings_version != SelectionHighlight.settings_version
          signature = selection_signature
          return unless @dirty || signature != @signature
          @cache = Collector.collect(@model)
          @signature = signature
          @dirty = false
        end

        def reload_settings
          @settings = SelectionHighlight.settings
          @settings_version = SelectionHighlight.settings_version
          alpha = (@settings['opacity'] * 255 / 100.0).round
          @fill_color = Sketchup::Color.new(*COLORS[@settings['fill_color']], alpha)
          @edge_color = Sketchup::Color.new(*COLORS[@settings['edge_color']], 255)
        end

        # Erkennt Verschiebungen während eines laufenden Werkzeugs, ohne die Geometrie neu zu lesen.
        def selection_signature
          selection = @model.selection
          return nil if selection.length > SIGNATURE_LIMIT
          selection.map { |entity| entity.respond_to?(:transformation) ? entity.transformation.to_a : nil }
        end

        def fail_with(error)
          @failed = true
          SelectionHighlight.log(error)
          UI.start_timer(0, false) do
            UI.messagebox("Auswahl hervorheben wurde wegen eines Fehlers angehalten (#{error.class}).\nProtokoll: #{File.join(Dir.tmpdir, 'TD_SelectionHighlight.log')}")
          end
        end
      end
    end
  end
end
