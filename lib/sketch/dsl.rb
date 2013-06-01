require 'geometry'

require_relative 'builder'
require_relative 'layout'

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

	# Create a layout
	# @param direction [Symbol] The layout direction (either :horizontal or :vertical)
	# @return [Group]
	def layout(direction, &block)
	    Builder.new(Layout.new(direction)).evaluate(&block).tap {|a| push a}
	end
    end
end
