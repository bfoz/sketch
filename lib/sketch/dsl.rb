# Syntactic sugar for building a {Sketch}

class Sketch
    module DSL
    # @group Accessors
	# @attribute [r] first
	#   @return [Geometry] the first Geometry element of the {Sketch}
	def first
	    elements.first
	end

	# @attribute [r] last
	#  @return [Geometry] the last Geometry element of the {Sketch}
	def last
	    elements.last
	end
    # @endgroup

	# Create a {RegularPolygon} with 6 sides
	# @return [RegularPolygon]
	def hexagon(options={})
	    options[:sides] = 6
	    Geometry::RegularPolygon.new(options).tap {|a| push a }
	end
    end
end
