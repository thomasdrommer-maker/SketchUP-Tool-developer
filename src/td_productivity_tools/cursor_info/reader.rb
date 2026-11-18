# encoding: UTF-8
module TD
  module ProductivityTools
    module CursorInfo
      module Reader
        def self.instance?(entity)
          entity.is_a?(Sketchup::Group) || entity.is_a?(Sketchup::ComponentInstance)
        end
        def self.target_index(path, mode)
          indices = path.each_index.select { |i| instance?(path[i]) }
          return path.length - 1 if mode == 'geometry' || indices.empty?
          mode == 'assembly' ? indices.first : indices.last
        end
        def self.determinant(transform)
          transform.xaxis.dot(transform.yaxis.cross(transform.zaxis)).abs
        end
        def self.values(entity, parent_transform, fields)
          instance = instance?(entity)
          result = {}
          fields.each do |key|
            result[key] = case key
            when 'type'
              if entity.is_a?(Sketchup::Group) then 'Gruppe'
              elsif instance then 'Komponente'
              elsif entity.is_a?(Sketchup::Face) then 'Fläche'
              elsif entity.is_a?(Sketchup::Edge) then 'Kante'
              else entity.typename
              end
            when 'name' then entity.name if entity.respond_to?(:name)
            when 'definition' then entity.definition.name if instance
            when 'description' then entity.definition.description if instance
            when 'tag' then entity.layer.name if entity.respond_to?(:layer)
            when 'material' then entity.material&.display_name if entity.respond_to?(:material)
            when 'back_material' then entity.back_material&.display_name if entity.is_a?(Sketchup::Face)
            when 'volume'
              if instance
                volume = entity.volume
                volume && volume > 0 ? format('%.4f m³', volume * determinant(parent_transform) * 0.0254**3) : 'Kein Volumenkörper'
              end
            when 'area'
              format('%.4f m²', entity.area(parent_transform) * 0.0254**2) if entity.is_a?(Sketchup::Face)
            when 'length'
              Sketchup.format_length(entity.length(parent_transform)) if entity.is_a?(Sketchup::Edge)
            when 'locked' then entity.locked? ? 'Ja' : 'Nein' if instance
            when 'hidden' then entity.hidden? ? 'Ja' : 'Nein' if entity.respond_to?(:hidden?)
            when 'casts_shadows' then entity.casts_shadows? ? 'Ja' : 'Nein' if entity.respond_to?(:casts_shadows?)
            when 'receives_shadows' then entity.receives_shadows? ? 'Ja' : 'Nein' if entity.respond_to?(:receives_shadows?)
            when 'ifc_class' then ifc_class(entity)
            end
          end
          result
        end
        def self.definition_of(entity)
          entity.definition if instance?(entity)
        end
        # Rein lesend: attribute_dictionary ohne Anlegen-Flag; Instanz hat Vorrang vor Definition.
        def self.attribute(entity, dictionary, key)
          value = entity.get_attribute(dictionary, key) if entity.respond_to?(:get_attribute)
          return value unless value.nil?
          definition = definition_of(entity)
          definition&.get_attribute(dictionary, key)
        end
        def self.ifc_class(entity)
          [entity, definition_of(entity)].compact.each do |source|
            types = source.attribute_dictionary('AppliedSchemaTypes')
            next unless types
            text = types.map { |schema, type| "#{schema}: #{type}" }.join('; ')
            return text unless text.empty?
          end
          nil
        end
        def self.attribute_rows(entity, options)
          options['attributes'].filter_map do |dictionary, key|
            value = attribute(entity, dictionary, key)
            empty = value.nil? || value.to_s.strip.empty?
            next if empty && options['hide_empty']
            [dictionary == 'BASF_General' ? key : "#{dictionary}: #{key}", empty ? nil : value]
          end
        end
        def self.lines(path, index, options)
          entity = path[index]
          transform = path.take(index).inject(Geom::Transformation.new) { |t, item| instance?(item) ? t * item.transformation : t }
          rows = values(entity, transform, options['fields']).filter_map do |key, value|
            empty = value.nil? || value.to_s.strip.empty?
            next if empty && options['hide_empty']
            clean = empty ? 'Nicht angegeben / nicht zutreffend' : value.to_s.gsub(/[\r\n\t]+/, ' ')
            "#{FIELDS[key]}: #{clean.length > 78 ? clean[0, 75] + '…' : clean}"
          end
          rows += attribute_rows(entity, options).map do |label, value|
            clean = value.nil? ? 'Nicht angegeben / nicht zutreffend' : value.to_s.gsub(/[\r\n\t]+/, ' ')
            "#{label}: #{clean.length > 78 ? clean[0, 75] + '…' : clean}"
          end
          ["OBJEKTINFO v#{VERSION}"] + (rows.empty? ? ['Keine sichtbaren Angaben – Optionen prüfen.'] : rows)
        end
      end
    end
  end
end
