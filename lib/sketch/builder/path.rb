require_relative 'polyline'

class Sketch
    Path = Geometry::Path

    class Builder
	class Path < Builder::Polyline
	    # Evaluate a block and return a new {Path}
	    # @return [Path]	A new {Path} initialized with the given block
	    def evaluate(&block)
		super
		Sketch::Path.new(*@elements)
	    end
	end
    end
end
