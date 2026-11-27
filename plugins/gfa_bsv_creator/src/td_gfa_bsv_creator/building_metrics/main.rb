# encoding: UTF-8
# GFA/BSV | 0.1.0.dev03 | 27.11.2026 | TD für Tom
require 'json'
require 'time'
require 'csv'
require 'tmpdir'
require_relative 'geometry'
module TD
  module GFABSVCreator
    module BuildingMetrics
      VERSION = '0.1.0.dev03'
      DICT = 'TD_GFA_BSV_Creator'
      module_function
      # Sketchup.version returns the internal major (26), not the year 2026.
      def supported_host?(version)
        /\A26(?:\.\d+)*\z/.match?(version.to_s)
      end
      def open
        unless supported_host?(Sketchup.version)
          UI.messagebox("GFA / BSV Creator #{VERSION} unterstützt SketchUp Desktop 2026 (interne Version 26.x).\nErkannte interne Version: #{Sketchup.version}. Andere Hauptversionen sind noch nicht freigegeben.")
          return
        end
        @session.close if @session
        @session = Session.new(Sketchup.active_model)
        @session.show
      end
      def report(error)
        warn("GFA/BSV: #{error.class}: #{error.message}")
        begin
          File.open(File.join(Dir.tmpdir,'TD_GFA_BSV_Creator.log'),'a') do |file|
            file.puts("#{Time.now.utc.iso8601} #{VERSION} #{error.class}: #{error.message}\n#{Array(error.backtrace).first(8).join("\n")}")
          end
        rescue SystemCallError => log_error
          warn("GFA/BSV Protokoll: #{log_error.class}")
        end
        UI.messagebox(error.is_a?(ArgumentError) ? error.message : "GFA / BSV: #{error.class}: #{error.message}\nVorgang abgebrochen. Protokoll: TD_GFA_BSV_Creator.log im temporären Ordner.")
      end
      class Session
        def initialize(model)
          @model = model
        end
        def guard
          raise ArgumentError, 'Das Modell wurde gewechselt. Bitte GFA / BSV erneut öffnen.' unless Sketchup.active_model == @model
          raise ArgumentError, 'Bitte den Gruppen-/Komponentenkontext verlassen.' if @model.active_path
        end
        def send_ui(function, value)
          @dialog.execute_script("#{function}(#{JSON.generate(value)})") if @dialog
        end
        def show
          @dialog = UI::HtmlDialog.new(dialog_title: "GFA / BSV Creator – #{VERSION}",preferences_key: 'TD.GFABSVCreator',scrollable: true,resizable: true,width: 720,height: 850,style: UI::HtmlDialog::STYLE_DIALOG)
          @dialog.set_file(File.join(__dir__,'dialog.html'))
          %w[ready scan preview create list export select].each do |action|
            @dialog.add_action_callback(action) do |_context, payload = nil|
              begin
                guard
                case action
                when 'ready'; list
                when 'scan'; scan
                when 'preview'; preview(JSON.parse(payload))
                when 'create'; create(JSON.parse(payload))
                when 'list'; list
                when 'export'; export
                when 'select'; select(Integer(payload))
                end
              rescue StandardError => error
                clear_preview
                send_ui('status', 'Vorgang abgebrochen: ' + error.message)
                BuildingMetrics.report(error)
              end
            end
          end
          @dialog.set_on_closed { @dialog = nil; clear_preview }
          @dialog.show
        end
        def close; @dialog.close if @dialog; end
        def clear_preview
          if @preview
            @preview = nil
            @model.select_tool(nil) if Sketchup.active_model == @model
          end
          @mesh = nil
          send_ui('preview_valid',false)
        end
        def scan
          clear_preview
          @source = Collector.collect(@model)
          points = @source[:points]
          contour = Geometry.hull2(points)
          low,high = points.map(&:last).minmax
          send_ui('loaded',{contour: contour.size <= 300 ? contour : [],contour_count: contour.size,lower: low,upper: high,points: points.size,objects: @source[:ids].size,
                           hidden: @source[:hidden],elapsed: @source[:elapsed_ms]})
        end
        def number(value)
          value = Float(value.to_s.tr(',','.'))
          raise ArgumentError,'Bitte endliche Zahlen eingeben.' unless value.finite?
          value
        end
        def normalized(form)
          raise ArgumentError,'Unbekannte Messgröße.' unless %w[GFA BSV].include?(form['kind'])
          raise ArgumentError,'Unbekannte Hüllmethode.' unless %w[box prism hull3].include?(form['method'])
          raise ArgumentError,'Konvexe 3D-Hülle ist nur für BSV verfügbar.' if form['kind'] == 'GFA' && form['method'] == 'hull3'
          %w[building level].each { |k| form[k] = form[k].to_s.strip[0,100] }
          %w[lower upper angle].each { |k| form[k] = number(form[k]) }
          form['contour'] = Array(form['contour']).map { |p| [number(p[0]),number(p[1])] }
          form
        end
        def verify_source
          raise ArgumentError,'Bitte zuerst eine Objektauswahl übernehmen.' unless @source
          current = Collector.collect(@model)
          raise ArgumentError,'Auswahl, Sichtbarkeit oder Quellgeometrie wurde geändert. Bitte Auswahl erneut übernehmen.' unless current[:digest] == @source[:digest]
        end
        def preview(raw)
          clear_preview
          verify_source
          form = normalized(raw)
          mesh = if form['method'] == 'hull3'
                   Geometry.hull3(@source[:points])
                 else
                   contour = form['method'] == 'box' ? Geometry.box(@source[:points],form['angle']*Math::PI/180.0) : form['contour']
                   Geometry.prism(contour,form['lower'],form['upper'],form['kind'] == 'GFA')
                 end
          @model.select_tool(nil)
          @mesh, @form = mesh, form
          @preview = Preview.new(@model,mesh) do
            @preview = nil
            @mesh = nil
            send_ui('preview_valid',false)
          end
          @model.select_tool(@preview)
          send_ui('preview_result',{value: form['kind'] == 'BSV' ? mesh[:volume] : mesh[:area],unit: form['kind'] == 'BSV' ? 'm³' : 'm²',faces: mesh[:faces].size})
        end
        def create(raw)
          raise ArgumentError,'Bitte zuerst die aktuelle Vorschau erzeugen.' unless @mesh && @preview
          form = normalized(raw)
          raise ArgumentError,'Eingaben wurden geändert. Bitte Vorschau aktualisieren.' unless form == @form
          verify_source
          mesh = @mesh
          clear_preview
          group = Writer.create(@model,mesh,form,@source)
          list
          send_ui('status',"#{group.name} wurde erstellt. Undo macht die Erstellung rückgängig.")
        end
        def groups
          @model.entities.grep(Sketchup::Group).select { |g| g.get_attribute(DICT,'measurement_id') }
        end
        def rows
          groups.map do |group|
            kind = group.get_attribute(DICT,'kind')
            faces = group.entities.grep(Sketchup::Face)
            nested = group.entities.any? { |e| e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance) }
            # Native group volume is evaluated in the instance context; transformed
            # face area explicitly includes instance scale for GFA.
            value = if nested
                      nil
                    elsif kind == 'BSV'
                      group.manifold? ? group.volume.to_f * 0.0254**3 : nil
                    elsif !faces.empty? && faces.all? { |f| f.vertices.all? { |v| (v.position.transform(group.transformation).z - faces.first.vertices.first.position.transform(group.transformation).z).abs < 0.001 } }
                      Geometry.total(faces) { |face| face.area(group.transformation) } * 0.0254**2
                    end
            {id: group.persistent_id,name: group.name,building: group.get_attribute(DICT,'building'),level: group.get_attribute(DICT,'level'),kind: kind,
             unit: kind == 'BSV' ? 'm³' : 'm²',value: value,method: group.get_attribute(DICT,'method'),
             status: value && value > 0 ? 'Geometrisch gültig / fachlich ungeprüft' : 'Ungültige Messgeometrie'}
          end
        end
        def list; send_ui('render_rows',rows); end
        def select(id)
          clear_preview
          group = groups.find { |g| g.persistent_id == id }
          raise ArgumentError,'Messobjekt wurde gelöscht.' unless group
          @model.selection.clear
          @model.selection.add(group)
          @model.active_view.zoom(group)
        end
        def export
          data = rows
          path = UI.savepanel('GFA / BSV als CSV speichern',nil,'GFA_BSV.csv')
          return unless path
          File.open(path,'wb') do |file|
            file.write("\xEF\xBB\xBF")
            csv = CSV.new(file,col_sep: ';')
            csv << ['Name','Gebäude','Ebene','Messgröße','Wert','Einheit','Methode','Status']
            data.each { |r| csv << [r[:name],r[:building],r[:level],r[:kind],r[:value] ? format('%.2f',r[:value]).tr('.',',') : '',r[:unit],r[:method],r[:status]] }
          end
          send_ui('status','CSV wurde gespeichert. Einzelmessungen werden wegen möglicher Überlappungen nicht pauschal summiert.')
        end
      end
    end
  end
end
require_relative 'collector'
require_relative 'preview'
require_relative 'writer'
