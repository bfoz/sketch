# Syntactic sugar for building a {Sketch}

class Sketch
    module DSL
	# Create a {RegularPolygon} with 6 sides
	# @return [RegularPolygon]
	def hexagon(options={})
	    options[:sides] = 6
	    Geometry::RegularPolygon.new(options).tap {|a| push a }
	end
    end
end
