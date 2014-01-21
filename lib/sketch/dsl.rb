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
	# @option options [Symbol] align    :top, :bottom, :left, or :right
	# @option options [Number] spacing  The spacing between each element
	# @return [Group]
	def layout(direction, *args, &block)
	    Builder.new(Layout.new(direction, *args)).evaluate(&block).tap {|a| push a}
	end

	# Create a {Path}
	# @return [Path]
	def path(*args, &block)
	    PathBuilder.new(*args).evaluate(&block).tap {|a| push a }
	end

	# Create a Polygon with the given vertices, or using a block.
	# See {PolygonBuilder}
	def polygon(*args, &block)
	    if block_given?
		push Builder::Polygon.new.evaluate(&block)
	    else
		push Sketch::Polygon.new(*args)
	    end
	    last
	end
    end
end
