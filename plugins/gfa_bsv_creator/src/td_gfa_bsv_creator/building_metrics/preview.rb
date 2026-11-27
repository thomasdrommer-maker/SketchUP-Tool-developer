# encoding: UTF-8
module TD
  module GFABSVCreator
    module BuildingMetrics
      class Preview
        def initialize(model, mesh, &cancel)
          @model, @mesh, @cancel = model, mesh, cancel
          @vertices = mesh[:vertices].map { |p| Geom::Point3d.new(p.map { |v| v/0.0254 }) }
          @triangles = mesh[:faces].flat_map { |f| f.map { |i| @vertices[i] } }
          @edges = mesh[:faces].flat_map { |f| f.each_index.flat_map { |k| [@vertices[f[k]],@vertices[f[(k+1)%f.size]]] } }
          @bounds = Geom::BoundingBox.new
          @bounds.add(@vertices)
        end
        def activate
          Sketchup.set_status_text('GFA / BSV: Vorschau prüfen; im Fenster „Messobjekt erstellen“ wählen. ESC verwirft die Vorschau.')
          @model.active_view.invalidate
        end
        def draw(view)
          view.drawing_color = Sketchup::Color.new(20,160,180,65)
          view.draw(GL_TRIANGLES,@triangles)
          view.drawing_color = Sketchup::Color.new(0,110,140)
          view.line_width = 2
          view.draw(GL_LINES,@edges)
        end
        def getExtents; @bounds; end
        def onCancel(_reason, _view); @model.select_tool(nil); end
        def deactivate(view)
          view.invalidate
          @cancel.call if @cancel
        end
      end
    end
  end
end
