# encoding: UTF-8
module TD
  module ProductivityTools
    module CursorInfo
      class Tool
        def activate
          @model = Sketchup.active_model
          @running = true
          @options = Settings.load
          clear
          Sketchup.status_text = 'Objektinfo: Cursor über Objekt halten. TAB: Optionen · ESC: Beenden'
        end
        def context
          [Sketchup.active_model, @model.active_path.to_a]
        end
        def clear
          @generation = (@generation || 0) + 1
          UI.stop_timer(@timer) if @timer
          @timer = nil
          @lines = @path = nil
          @model.active_view.invalidate if @model
        end
        def deactivate(view)
          @running = false
          clear
          Sketchup.status_text = ''
          view.invalidate
        end
        def suspend(view)
          @running = false
          clear
          view.invalidate
        end
        def resume(view)
          @running = true
          @options = Settings.load
          clear
          view.invalidate
        end
        def onCancel(_reason, _view)
          @model.select_tool(nil)
        end
        def onMouseLeave(_view)
          clear
        end
        def onKeyDown(key, repeat, _flags, _view)
          CursorInfo.options if key == 9 && repeat == 1
        end
        def onMouseMove(_flags, x, y, view)
          clear
          return unless @running && Sketchup.active_model == @model
          @x, @y = x, y
          token = @generation
          captured = context
          @timer = UI.start_timer(@options['delay'] / 1000.0, false) do
            @timer = nil
            next unless @running && token == @generation && context == captured
            begin
              ph = view.pick_helper
              ph.do_pick(x, y)
              best = ph.best_picked
              next unless best
              picked = (0...ph.count).map { |i| ph.path_at(i) }.find { |p| p.first == best }
              next unless picked
              local_index = Reader.target_index(picked, @options['target'])
              prefix = @model.active_path.to_a
              @path = prefix + picked.take(local_index + 1)
              next unless @path.all?(&:valid?)
              @captured_context = captured
              @lines = Reader.lines(@path, @path.length - 1, @options)
              view.invalidate
            rescue StandardError => error
              CursorInfo.fail_tool(error, @model)
            end
          end
        rescue StandardError => error
          CursorInfo.fail_tool(error, @model)
        end
        def draw(view)
          return unless @running && @lines && @path.all?(&:valid?) && context == @captured_context
          font = { font: 'Arial', pixel_size: @options['font'], color: 'white', vertical_align: TextVerticalAlignBoundsTop }
          # Keep the panel within the viewport, including small windows and high DPI.
          max_chars = [(view.vpwidth - 40) / (@options['font'] * 0.65), 8].max.to_i
          rows = @lines.take([(view.vpheight - 40) / (@options['font'] * 1.6), 1].max.to_i)
          text = rows.map { |line| line.length > max_chars ? line[0, max_chars - 1] + '…' : line }.join("\n")
          bounds = view.text_bounds(Geom::Point3d.new(0, 0, 0), text, font)
          width, height = bounds.width + 20, bounds.height + 16
          x = @options['position'] == 'corner' ? 12 : @x + 20
          y = @options['position'] == 'corner' ? 12 : @y + 24
          x = [[x, view.vpwidth - width - 8].min, 4].max
          y = [[y, view.vpheight - height - 8].min, 4].max
          points = [[x,y,0],[x+width,y,0],[x+width,y+height,0],[x,y+height,0]]
          view.drawing_color = Sketchup::Color.new(30, 41, 59, 240)
          view.draw2d(GL_QUADS, points)
          view.drawing_color = Sketchup::Color.new(96, 165, 250)
          view.line_width = 1
          view.draw2d(GL_LINE_LOOP, points)
          view.draw_text(Geom::Point3d.new(x + 10, y + 8, 0), text, font)
        rescue StandardError => error
          @lines = nil
          CursorInfo.fail_tool(error, @model)
        end
      end
    end
  end
end
