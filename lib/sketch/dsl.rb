require 'geometry'

require_relative 'builder/polygon'
require_relative 'layout'

class Sketch
    # Syntactic sugar for building a {Sketch}
    module DSL
	# Define a new read-write attribute. An optional default value can be supplied as either an argument, or as a block. The block will be evaluated the first time the attribute is accessed.
	# @param name [String,Symbol]	The new attribute's name
	# @param value A default value for the new attribute
	def attr_accessor(name, value=nil, &block)
	    define_attribute_reader name, value, &block
	    define_attribute_writer name
	end
	alias :attribute :attr_accessor

	# Define a new read-only attribute.  An optional default value can be supplied as either an argument, or as a block. The block will be evaluated the first time the attribute is accessed.
	# @param name [String,Symbol]	The new attribute's name
	# @param value A default value for the new attribute
	def attr_reader(name, value=nil, &block)
	    define_attribute_reader(name, value, &block)
	end

	# Define a new write-only {Model} attribute
	# @param name [String,Symbol]	The new attribute's name
	def attr_writer(name)
	    define_attribute_writer(name)
	end

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
	    Builder::Path.new(*args).evaluate(&block).tap {|a| push a }
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
