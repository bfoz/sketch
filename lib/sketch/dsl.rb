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

    # @group Geometry generation

	# Create and append a new {Arc} object
	# @param (see Arc#initialize)
	# @return [Arc]
	def arc(*args)
	    push Arc.new(*args)
	end

	# Create and append a new {Circle} object given a center point and radius
	# @param	[Point]	    center  The circle's center point
	# @param	[Number]    radius  The circle's radius
	# @return	[Circle]    A new {Circle}
	def circle(*args)
	    push Circle.new(*args)
	end

	# Create a {RegularPolygon} with 6 sides
	# @return [RegularPolygon]
	def hexagon(options={})
	    options[:sides] = 6
	    Geometry::RegularPolygon.new(options).tap {|a| push a }
	end

	# Create a Line using any arguments that work for {Geometry::Line}
	def line(*args)
	    push Geometry::Line[*args]
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
		push build_polygon(&block)
	    else
		push Sketch::Polygon.new(*args)
	    end
	    last
	end

	# Create a {Polyline}
	def polyline(&block)
	    push build_polyline(&block)
	end

	# Create a {Rectangle} from the given arguments and append it to the {Sketch}
	def rectangle(*args)
	    push Rectangle.new(*args)
	end

	# Create a Square with sides of the given length
	# @param [Numeric] length	The length of the sides of the square
	def square(length)
	    push Geometry::CenteredSquare.new [0,0], length
	end

	# Create and add a {Triangle}
	# @param (see Triangle::new)
	def triangle(*args)
	    push Geometry::Triangle.new *args
	end

    # @endgroup

	# Create a {Group} with an optional transformation
	def group(*args, &block)
	    push build_group(*args, &block)
	end

	# Create a layout
	# @param direction [Symbol] The layout direction (either :horizontal or :vertical)
	# @option options [Symbol] align    :top, :bottom, :left, or :right
	# @option options [Number] spacing  The spacing between each element
	# @return [Group]
	def layout(direction, *args, &block)
	    raise ArgumentError, "direction must be either :horizontal or :vertical, not #{direction}" unless [:horizontal, :vertical].include?(direction)

	    options, _ = args.partition {|a| a.is_a? Hash}
	    options = options.reduce({}, :merge)

	    alignment = options.delete(:align) || options.delete(:alignment)
	    spacing = options.delete(:spacing) || 0

	    if alignment
		case direction
		    when :horizontal then raise ArgumentError, "When direction is :horizontal, alignment must be either :top or :bottom, not #{alignment}" unless [:bottom, :top].include?(alignment)
		    when :vertical then raise ArgumentError, "When direction is :vertical, alignment must be either :left or :right, not #{alignment}" unless [:left, :right].include?(alignment)
		end
	    end

	    push build_layout(direction, alignment, spacing, *args, &block)
	end

	# Create a {Group} using the given translation
	# @param [Point] point	The distance by which to translate the enclosed geometry
	def translate(*args, &block)
	    point = Point[*args]
	    raise ArgumentError, 'Translation is limited to 2 dimensions' if point.size > 2
	    group(origin:point, &block)
	end

    end
end
