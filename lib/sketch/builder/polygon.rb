require_relative 'polyline'

class Sketch
    Polygon = Geometry::Polygon

    class PolygonBuilder < PolylineBuilder
	# @return [Polygon] the {Polygon} resulting from evaluating the given block
	def evaluate(&block)
	    super
	    Polygon.new *@elements
	end
    end
end
