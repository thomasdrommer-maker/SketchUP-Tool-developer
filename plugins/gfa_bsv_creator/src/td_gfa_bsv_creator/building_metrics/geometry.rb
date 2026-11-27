# encoding: UTF-8
# GFA/BSV geometry | 0.1.0.dev03 | 27.11.2026 | TD für Tom
# Pure calculations in metres; no SketchUp dependency.
module TD
  module GFABSVCreator
    module BuildingMetrics
      module Geometry
        EPS = 1.0e-7
        module_function
        def sub(a, b); a.zip(b).map { |x, y| x - y }; end
        # Avoid Array#sum: legacy extensions can replace Ruby's implementation.
        # Keep all arithmetic local; never patch Array or restore removed constants.
        def total(values)
          result = 0.0
          values.each { |value| result += yield(value) }
          result
        end
        def dot(a, b); total(a.zip(b)) { |x, y| x * y }; end
        def cross(a, b)
          [a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0]]
        end
        def norm(a); Math.sqrt(dot(a, a)); end
        def turn(a, b, c)
          (b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])
        end
        def hull2(points)
          p = points.map { |v| v.first(2) }.uniq.sort
          raise ArgumentError, 'Zu wenige Grundrisspunkte.' if p.size < 3
          halves = [p, p.reverse].map do |list|
            list.each_with_object([]) do |v, h|
              h.pop while h.size >= 2 && turn(h[-2], h[-1], v) <= EPS * norm(sub(h[-1], h[-2]))
              h << v
            end
          end
          result = halves[0][0...-1] + halves[1][0...-1]
          raise ArgumentError, 'Grundriss ist flächenlos oder zu klein.' if result.size < 3 || signed_area(result).abs < 1.0e-6
          result
        end
        def signed_area(p)
          o = p.first
          total(p.each_index) { |i| turn(o, p[i], p[(i+1)%p.size]) } / 2.0
        end
        def on_segment(a,b,p)
          turn(a,b,p).abs <= EPS * [norm(sub(b,a)), EPS].max &&
            2.times.all? { |k| p[k] >= [a[k],b[k]].min-EPS && p[k] <= [a[k],b[k]].max+EPS }
        end
        def intersects(a,b,c,d)
          return true if on_segment(a,b,c) || on_segment(a,b,d) || on_segment(c,d,a) || on_segment(c,d,b)
          turn(a,b,c)*turn(a,b,d) < 0 && turn(c,d,a)*turn(c,d,b) < 0
        end
        def polygon(input)
          p = input.map { |v| v.first(2).map { |x| Float(x) } }
          p.pop if p.size > 1 && p.first == p.last
          raise ArgumentError, 'Kontur benötigt 3 bis 300 Punkte.' unless (3..300).cover?(p.size)
          raise ArgumentError, 'Ungültige Koordinaten.' unless p.flatten.all?(&:finite?)
          p.each_index do |i|
            raise ArgumentError, 'Kontur enthält doppelte oder zu kurze Kanten.' if norm(sub(p[i],p[(i+1)%p.size])) < 0.0001
            p.each_index do |j|
              next if j <= i || j == (i+1)%p.size || i == (j+1)%p.size
              raise ArgumentError, 'Kontur überschneidet oder berührt sich selbst.' if intersects(p[i],p[(i+1)%p.size],p[j],p[(j+1)%p.size])
            end
          end
          # Remove collinear intermediate vertices before triangulation.
          loop do
            index = p.each_index.find { |i| on_segment(p[(i-1)%p.size],p[(i+1)%p.size],p[i]) }
            break unless index && p.size > 3
            p.delete_at(index)
          end
          area = signed_area(p)
          raise ArgumentError, 'Grundriss ist flächenlos oder zu klein.' if area.abs < 1.0e-6
          area < 0 ? p.reverse : p
        end
        def triangulate(p)
          ids = (0...p.size).to_a
          triangles = []
          while ids.size > 3
            ear = ids.each_index.find do |i|
              a,b,c = ids[(i-1)%ids.size],ids[i],ids[(i+1)%ids.size]
              next false if turn(p[a],p[b],p[c]) <= EPS*EPS
              ids.none? do |j|
                next false if [a,b,c].include?(j)
                turn(p[a],p[b],p[j]) >= -EPS*EPS && turn(p[b],p[c],p[j]) >= -EPS*EPS && turn(p[c],p[a],p[j]) >= -EPS*EPS
              end
            end
            raise ArgumentError, 'Kontur lässt sich nicht sicher triangulieren.' unless ear
            triangles << [ids[(ear-1)%ids.size],ids[ear],ids[(ear+1)%ids.size]]
            ids.delete_at(ear)
          end
          triangles << ids
        end
        def prism(input, lower, upper, area_only = false)
          p = polygon(input)
          raise ArgumentError, 'Oberkante muss über Unterkante liegen (mindestens 1 mm).' unless area_only || upper-lower >= 0.001
          vertices = p.map { |v| v + [lower] }
          top = triangulate(p)
          return {vertices: vertices, faces: top, area: signed_area(p), volume: nil} if area_only
          n = p.size
          vertices += p.map { |v| v + [upper] }
          faces = top.map(&:reverse) + top.map { |t| t.map { |i| i+n } }
          n.times do |i|
            j = (i+1)%n
            faces << [i,j,j+n] << [i,j+n,i+n]
          end
          {vertices: vertices, faces: faces, area: signed_area(p), volume: signed_area(p)*(upper-lower)}
        end
        def box(points, angle)
          co,si = Math.cos(angle),Math.sin(angle)
          local = points.map { |x,y,_z| [co*x+si*y,-si*x+co*y] }
          x0,x1 = local.map(&:first).minmax
          y0,y1 = local.map(&:last).minmax
          [[x0,y0],[x1,y0],[x1,y1],[x0,y1]].map { |x,y| [co*x-si*y,si*x+co*y] }
        end
        def hull3(points)
          raise ArgumentError, 'Für die 3D-Hülle sind höchstens 6.000 eindeutige Punkte erlaubt. Auswahl verkleinern oder Quader/Grundriss verwenden.' if points.size > 6000
          p = points.uniq
          raise ArgumentError, 'Zu wenige Punkte für ein Volumen.' if p.size < 4
          origin = p.first
          p = p.map { |v| sub(v,origin) }
          a = 0
          b = p.each_index.max_by { |i| norm(sub(p[i],p[a])) }
          c = p.each_index.max_by { |i| norm(cross(sub(p[b],p[a]),sub(p[i],p[a]))) }
          normal = cross(sub(p[b],p[a]),sub(p[c],p[a]))
          raise ArgumentError, 'Auswahl ist linienförmig.' if norm(normal) < EPS*EPS
          d = p.each_index.max_by { |i| dot(normal,sub(p[i],p[a])).abs }
          raise ArgumentError, 'Auswahl ist eben; kein geschlossenes 3D-Volumen möglich.' if dot(normal,sub(p[d],p[a])).abs / norm(normal) < 0.0001
          inside = 3.times.map { |k| total([a,b,c,d]) { |i| p[i][k] }/4.0 }
          orient = lambda do |f|
            n = cross(sub(p[f[1]],p[f[0]]),sub(p[f[2]],p[f[0]]))
            dot(n,sub(inside,p[f[0]])) > 0 ? f.reverse : f
          end
          faces = [[a,b,c],[a,d,b],[a,c,d],[b,d,c]].map(&orient)
          started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          p.each_index do |i|
            raise ArgumentError, '3D-Hülle überschreitet das Zeitbudget von 8 Sekunden. Auswahl vereinfachen.' if Process.clock_gettime(Process::CLOCK_MONOTONIC)-started > 8
            visible = faces.select do |f|
              n = cross(sub(p[f[1]],p[f[0]]),sub(p[f[2]],p[f[0]]))
              dot(n,sub(p[i],p[f[0]])) > EPS * norm(n)
            end
            next if visible.empty?
            edges = {}
            visible.each do |f|
              3.times do |k|
                edge = [f[k],f[(k+1)%3]]
                key = edge.sort
                edges.key?(key) ? edges.delete(key) : edges[key] = edge
              end
            end
            faces -= visible
            edges.each_value { |u,v| faces << orient.call([u,v,i]) }
          end
          counts = Hash.new(0)
          faces.each do |f|
            raise ArgumentError, '3D-Hüllenprüfung überschreitet 8 Sekunden. Auswahl vereinfachen.' if Process.clock_gettime(Process::CLOCK_MONOTONIC)-started > 8
            n = cross(sub(p[f[1]],p[f[0]]),sub(p[f[2]],p[f[0]]))
            raise ArgumentError, 'Degenerierte Hüllfläche.' if norm(n) < EPS*EPS
            raise ArgumentError, 'Hülle umschließt nicht alle Punkte sicher.' if p.any? { |v| dot(n,sub(v,p[f[0]])) > EPS*norm(n)*10 }
            3.times { |k| counts[[f[k],f[(k+1)%3]].sort] += 1 }
          end
          raise ArgumentError, 'Hülle ist nicht geschlossen.' unless counts.values.all? { |n| n == 2 }
          volume = total(faces) { |i,j,k| dot(p[i],cross(p[j],p[k])) }/6.0
          raise ArgumentError, 'Hüllvolumen ist zu klein.' unless volume > 1.0e-9
          {vertices: points.uniq, faces: faces, area: nil, volume: volume}
        end
      end
    end
  end
end
