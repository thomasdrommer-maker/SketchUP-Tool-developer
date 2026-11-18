# encoding: UTF-8
require 'json'
require 'fileutils'
module TD
  module ProductivityTools
    # Einstellungen als JSON-Datei, damit Sketchup.read_default keinen Text auswertet.
    module PrefsStore
      def self.path(name)
        base = ENV['APPDATA'] || Dir.home
        File.join(base, 'TD_ProductivityTools', "#{name}.json")
      end

      def self.read(name)
        file = path(name)
        File.exist?(file) ? JSON.parse(File.read(file, encoding: 'UTF-8')) : nil
      end

      def self.write(name, data)
        file = path(name)
        FileUtils.mkdir_p(File.dirname(file))
        File.write(file, JSON.generate(data), encoding: 'UTF-8')
      end
    end
  end
end