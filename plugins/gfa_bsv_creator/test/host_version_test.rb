# Isolated startup regression with host/UI doubles, no native SketchUp execution.
module Sketchup
  class << self; attr_accessor :test_version; end
  def self.version; test_version; end
  def self.active_model; :test_model; end
end
module UI
  class << self; attr_accessor :messages; end
  self.messages=[]
  def self.messagebox(message); messages << message; end
end
module TD::GFABSVCreator::BuildingMetrics
  class Session
    class << self; attr_accessor :shown; end
    self.shown=0
    def initialize(model); raise 'Wrong model' unless model == :test_model; end
    def show; self.class.shown += 1; end
    def close; end
  end
end
metrics=TD::GFABSVCreator::BuildingMetrics
['26','26.0','26.0.429','26.1.123','25.0.0','27.0.0','2026','invalid'].each do |version|
  Sketchup.test_version=version
  expected=['26','26.0','26.0.429','26.1.123'].include?(version)
  before=metrics::Session.shown
  UI.messages.clear
  metrics.open
  raise "Startup mismatch #{version}" unless (metrics::Session.shown == before+1) == expected
  raise "Dialog mismatch #{version}" unless UI.messages.empty? == expected
  raise 'Missing diagnostic' unless expected || UI.messages.first.include?(version)
end
puts '8 host startup regression cases passed (doubles, not SketchUp)'
