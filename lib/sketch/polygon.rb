require_relative 'polyline_builder'

class Sketch
    Polygon = Geometry::Polygon

    class PolygonBuilder < PolylineBuilder
	Edge = Geometry::Edge

	# @return [Polygon] the {Polygon} resulting from evaluating the given block
	def evaluate(&block)
	    super
	    Polygon.new *@elements
	end

	# @group Primitive creation

	# Create and append a new Edge object
	def edge(*args)
	    @elements.push Edge.new(*args)
	end

	# @endgroup
    end
end
