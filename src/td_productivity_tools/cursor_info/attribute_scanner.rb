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

        MAX_DEPTH = 5

        def self.harvest(entity, keys)
          dictionaries = entity.attribute_dictionaries
          return unless dictionaries
          dictionaries.each do |dictionary|
            walk(dictionary, dictionary.name.to_s, keys, 1) if relevant?(dictionary.name)
          end
        end

        # Unterdictionaries (z. B. IFC-PropertySets) werden als Pfad "A/B/C" geführt.
        def self.walk(dictionary, path, keys, depth)
          dictionary.each_key { |key| keys[[path, key.to_s]] = true }
          return if depth >= MAX_DEPTH
          (dictionary.attribute_dictionaries || []).each do |child|
            walk(child, "#{path}/#{child.name}", keys, depth + 1)
          end
        end
      end
    end
  end
end
