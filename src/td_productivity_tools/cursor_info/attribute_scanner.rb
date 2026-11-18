# encoding: UTF-8
module TD
  module ProductivityTools
    module CursorInfo
      # Liest vorhandene Attributschlüssel für die Optionsauswahl; legt nichts an.
      module AttributeScanner
        MAX_INSTANCES = 50_000
        Result = Struct.new(:keys, :truncated)

        def self.relevant?(name)
          name == 'BASF_General' || name.to_s.match?(/\AIFC/i)
        end

        def self.scan(model)
          keys = {}
          seen = 0
          truncated = false
          model.definitions.each do |definition|
            next if definition.image?
            harvest(definition, keys)
            definition.instances.each do |instance|
              if (seen += 1) > MAX_INSTANCES
                truncated = true
                break
              end
              harvest(instance, keys)
            end
            break if truncated
          end
          Result.new(keys.keys.sort_by { |dictionary, key| [dictionary.downcase, key.downcase] }, truncated)
        end

        def self.harvest(entity, keys)
          dictionaries = entity.attribute_dictionaries
          return unless dictionaries
          dictionaries.each do |dictionary|
            next unless relevant?(dictionary.name)
            dictionary.each_key { |key| keys[[dictionary.name, key.to_s]] = true }
          end
        end
      end
    end
  end
end
