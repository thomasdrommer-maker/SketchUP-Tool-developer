# encoding: UTF-8
require 'securerandom'
module TD
  module GFABSVCreator
    module BuildingMetrics
      module Writer
        module_function
        def create(model, mesh, form, source)
          operation = false
          model.start_operation('GFA / BSV Messobjekt erstellen',true)
          operation = true
          group = model.entities.add_group
          origin = mesh[:vertices].first
          vertices = mesh[:vertices].map { |v| Geom::Point3d.new(Geometry.sub(v,origin).map { |x| x/0.0254 }) }
          mesh[:faces].each do |indices|
            a,b,c = indices.map { |i| vertices[i] }
            face = group.entities.add_face(a,b,c)
            raise ArgumentError, 'SketchUp konnte eine Hüllfläche nicht erstellen (zu kleine oder ungültige Geometrie).' unless face
            expected = (b-a).cross(c-a)
            face.reverse! if face.normal.dot(expected) < 0
          end
          kind = form.fetch('kind')
          actual = kind == 'BSV' ? group.volume.to_f * 0.0254**3 : Geometry.total(group.entities.grep(Sketchup::Face)) { |face| face.area } * 0.0254**2
          if kind == 'BSV'
            raise ArgumentError, 'SketchUp bestätigt die Hülle nicht als geschlossenen Volumenkörper.' unless group.manifold? && actual > 0
          end
          expected = kind == 'BSV' ? mesh[:volume] : mesh[:area]
          raise ArgumentError, 'SketchUp-Geometrie weicht vom berechneten Messwert ab. Erstellung abgebrochen.' if (actual-expected).abs > [expected.abs*1.0e-5,1.0e-7].max
          group.transformation = Geom::Transformation.translation(origin.map { |x| x/0.0254 })
          label = [kind,form['building'],form['level']].reject { |v| v.to_s.strip.empty? }.join('_')
          names = model.entities.grep(Sketchup::Group).map(&:name)
          counter = 1
          counter += 1 while names.include?(format('%s_%03d',label,counter))
          group.name = format('%s_%03d',label,counter)
          group.layer = model.layers.add("TD_GFA_BSV_#{kind}")
          material = model.materials.add("TD_GFA_BSV_#{kind}_Messung")
          material.color = kind == 'BSV' ? Sketchup::Color.new(20,160,180) : Sketchup::Color.new(240,170,40)
          material.alpha = 0.30
          group.material = material
          data = {measurement_id: SecureRandom.uuid, kind: kind, unit: kind == 'BSV' ? 'm3' : 'm2',
                  value_at_creation: actual, building: form['building'], level: form['level'],
                  method: form['method'], rule: 'Geometrische Projekthülle; keine DIN-277-Freigabe',
                  source_ids: JSON.generate(source[:ids]), source_digest: source[:digest],
                  parameters: JSON.generate(form), version: VERSION, created_at: Time.now.utc.iso8601}
          data.each { |key,value| group.set_attribute(DICT,key.to_s,value) }
          model.commit_operation
          operation = false
          group
        rescue StandardError
          model.abort_operation if operation
          raise
        end
      end
    end
  end
end
