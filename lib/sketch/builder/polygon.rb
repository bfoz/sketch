require_relative 'polyline'

class Sketch
    Polygon = Geometry::Polygon

    class Builder
	class Polygon < Builder::Polyline
	    # @return [Polygon] the {Polygon} resulting from evaluating the given block
	    def evaluate(&block)
		super
		Sketch::Polygon.new *@elements
	    end
	end
    end
end
