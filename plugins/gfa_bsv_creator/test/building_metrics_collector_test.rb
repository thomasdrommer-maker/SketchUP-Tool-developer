# Minimal doubles for source traversal only. Not a SketchUp integration test.
raise 'Run outside SketchUp' if defined?(Sketchup)
module Geom
  class Transformation
    attr_reader :scale, :offset
    def initialize(scale=[1,1,1],offset=[0,0,0]); @scale,@offset=scale,offset; end
    def *(other)
      self.class.new(3.times.map { |i| @scale[i]*other.scale[i] },3.times.map { |i| @scale[i]*other.offset[i]+@offset[i] })
    end
  end
  class TestPoint
    def initialize(values); @values=values; end
    def transform(t); self.class.new(3.times.map { |i| @values[i]*t.scale[i]+t.offset[i] }); end
    def to_a; @values; end
  end
end
module Sketchup
  class Drawingelement
    attr_accessor :visible, :attributes
    attr_reader :persistent_id
    def initialize(id); @persistent_id=id;@visible=true;@attributes={}; end
    def valid?; true; end
    def get_attribute(dict,key); @attributes[[dict,key]]; end
  end
  Vertex=Struct.new(:position)
  class Face < Drawingelement
    attr_reader :vertices
    def initialize(id,coords); super(id); @vertices=coords.map { |p| Vertex.new(Geom::TestPoint.new(p)) }; end
  end
  class Edge < Face; end
  Definition=Struct.new(:entities)
  class ComponentInstance < Drawingelement
    attr_reader :definition, :transformation
    def initialize(id,definition,transform=Geom::Transformation.new); super(id);@definition,@transformation=definition,transform; end
  end
  class Group < ComponentInstance; end
end
module TD::GFABSVCreator::BuildingMetrics
  DICT='TD_GFA_BSV_Creator'
end
module BuildingMetricsCollectorTest
  C=TD::GFABSVCreator::BuildingMetrics::Collector
  Model=Struct.new(:selection,:active_path) do
    def drawing_element_visible?(path); path.all?(&:visible); end
  end
  @count=0
  def self.check(name)
    yield
    @count+=1
    puts "PASS collector #{name}"
  end
  def self.rejects
    begin
      yield
    rescue ArgumentError
      return
    end
    raise 'Expected rejection'
  end
  face=Sketchup::Face.new(1,[[0,0,0],[100,0,0],[0,100,0]])
  shared=Sketchup::Definition.new([face])
  first=Sketchup::ComponentInstance.new(2,shared)
  mirror=Sketchup::ComponentInstance.new(3,shared,Geom::Transformation.new([-2,1,1],[1000,0,0]))
  parent=Sketchup::Group.new(4,Sketchup::Definition.new([first,mirror]),Geom::Transformation.new([1,2,1],[0,100,0]))
  model=Model.new([parent],nil)
  check('nested shared definitions, scaling and mirroring') do
    result=C.collect(model)
    expected=[[0,100,0],[100,100,0],[0,300,0],[1000,100,0],[800,100,0],[1000,300,0]].map { |p| p.map { |v| v*0.0254 } }.sort
    raise 'Unexpected transformed coordinates' unless result[:points]==expected
    raise 'Read changed source' unless face.attributes.empty? && parent.attributes.empty?
  end
  check('hidden subtree excluded and counted') do
    mirror.visible=false
    result=C.collect(model)
    raise 'Visibility mismatch' unless result[:points].size==3 && result[:hidden]==1
    mirror.visible=true
  end
  check('selection identity invalidates digest') do
    a=C.collect(model)[:digest]
    model.selection=[first]
    raise 'Digest unchanged' if C.collect(model)[:digest]==a
    model.selection=[parent]
  end
  check('active edit context rejected') { model.active_path=[parent]; rejects { C.collect(model) }; model.active_path=nil }
  check('empty and mixed selection rejected') do
    model.selection=[];rejects { C.collect(model) }
    model.selection=[Sketchup::Drawingelement.new(10)];rejects { C.collect(model) }
    model.selection=[parent]
  end
  check('existing measurement rejected') do
    parent.attributes[['TD_GFA_BSV_Creator','measurement_id']]='example'
    rejects { C.collect(model) }
  end
  puts "#{@count} collector contract cases passed (doubles, not SketchUp)"
end
