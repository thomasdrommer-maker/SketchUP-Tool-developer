# Pure geometry regression tests; run after loading geometry.rb.
module BuildingMetricsGeometryTest
  G = TD::GFABSVCreator::BuildingMetrics::Geometry
  @count = 0
  def self.check(name)
    yield
    @count += 1
    puts "PASS #{name}"
  end
  def self.near(actual, expected)
    raise "#{actual} != #{expected}" if (actual-expected).abs > [expected.abs*1e-8,1e-8].max
  end
  def self.rejects
    begin
      yield
    rescue ArgumentError
      return
    end
    raise 'Expected ArgumentError'
  end
  cube = [0.0,10.0].product([0.0,5.0],[0.0,3.0])
  check('cube hull 150 m3') { near(G.hull3(cube)[:volume],150.0) }
  check('tetrahedron 1/6 m3') { near(G.hull3([[0,0,0],[1,0,0],[0,1,0],[0,0,1]])[:volume],1.0/6) }
  check('translated, rotated, mirrored and scaled cube') do
    points = cube.map { |x,y,z| [-2*x*Math.cos(0.7)-y*Math.sin(0.7)+600000, -2*x*Math.sin(0.7)+y*Math.cos(0.7)+5500000,z*3+200] }
    near(G.hull3(points)[:volume],900)
  end
  check('duplicates and interior points do not add volume') { near(G.hull3(cube+cube+[[2,2,2],[5,2,1]])[:volume],150) }
  check('planar hull rejected') { rejects { G.hull3([[0,0,0],[1,0,0],[0,1,0],[1,1,0]]) } }
  check('collinear hull rejected') { rejects { G.hull3([[0,0,0],[1,0,0],[2,0,0],[3,0,0]]) } }
  check('L contour area 7 and prism volume 21') do
    p = [[0,0],[4,0],[4,1],[1,1],[1,4],[0,4]]
    mesh=G.prism(p,2,5)
    near(mesh[:area],7);near(mesh[:volume],21)
    signed=G.total(mesh[:faces]) { |a,b,c| G.dot(mesh[:vertices][a],G.cross(mesh[:vertices][b],mesh[:vertices][c])) }/6.0
    near(signed,21)
    near(G.prism(p.reverse,2,5)[:volume],21)
  end
  check('concave GFA triangulation area') do
    p=G.polygon([[0,0],[5,0],[5,5],[3,5],[3,2],[2,2],[2,5],[0,5]])
    near(G.total(G.triangulate(p)) { |a,b,c| G.turn(p[a],p[b],p[c])/2.0 },22)
  end
  check('self-intersection rejected') { rejects { G.polygon([[0,0],[3,3],[0,3],[3,0]]) } }
  check('self-touch rejected') { rejects { G.polygon([[0,0],[4,0],[2,0],[2,3],[0,3]]) } }
  check('collinear intermediate vertices removed') { near(G.prism([[0,0],[1,0],[2,0],[2,2],[0,2]],0,1)[:volume],4) }
  check('reversed heights rejected') { rejects { G.prism([[0,0],[1,0],[0,1]],5,2) } }
  check('GFA at a single height allowed') { near(G.prism([[0,0],[2,0],[0,2]],5,5,true)[:area],2) }
  check('box rotation follows specified angle') do
    angle=0.7
    points=cube.map { |x,y,z| [x*Math.cos(angle)-y*Math.sin(angle),x*Math.sin(angle)+y*Math.cos(angle),z] }
    near(G.prism(G.box(points,angle),0,3)[:volume],150)
  end
  check('3D maximum count enforced') { rejects { G.hull3(Array.new(6001) { |i| [i,0,0] }) } }
  puts "#{@count} geometry regression cases passed"
end
