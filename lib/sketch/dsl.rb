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
	# @param (see Geometry::Square)
	def square(*args)
	    options, args = args.partition {|a| a.is_a? Hash}
	    options = options.reduce({}, :merge)

	    if args.length == 1
		options[:size] = args.shift
	    end

	    push Geometry::Square.new *args, options
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

	# Create a {Group} using the given translation
	# @overload translate(x, y, &block)
	#   @param x [Number]	the x-component of the desired translation
	#   @param y [Number]	the y-component of the desired translation
	# @overload translate(point, &block)
	#   @param point [Point]	The distance by which to translate the enclosed geometry
	# @overload translate(options, &block)
	#   @option options :x [Number]	the x-component of the desired translation
	#   @option options :y [Number]	the y-component of the desired translation
	def translate(x=nil, y=nil, **options, &block)
	    point = Point[x || options[:x] || 0, y || options[:y] || 0]
	    point = Point[point.first, 0] if point.size < 2

	    raise ArgumentError, 'Translation is limited to 2 dimensions' if point.size > 2
	    group(origin:point, &block)
	end

	# Repeat the given block of geometry a given number of times with the specified spacing
	# @param count [Number,Array]	the number of repetitions along each repetition axis
	def repeat(options={}, &block)
	    count = options.delete(:count) || 2
	    step = Point[options.delete(:spacing) || options.delete(:step)]

	    # Force step to be two-dimensional
	    step = Point[step.first, 0] if step.size < 2


	    start_point = -step*(count-1)/2
	    if step.all? {|a| a != 0}
		count.times do |y|
		    count.times do |x|
			translate(start_point + Point[step.x * x, step.y * y], &block)
		    end
		end
	    else
		count.times do |i|
		    translate(start_point + step*i, &block)
		end
	    end
	end

    # @group Simple Layouts

	# Create a layout
	# @param direction [Symbol] The layout direction (either :horizontal or :vertical)
	# @option options [Symbol] align    :top, :bottom, :left, or :right
	# @option options [Number] spacing  The spacing between each element
	# @return [Group]
	def layout(*args, &block)
	    options, _ = args.partition {|a| a.is_a? Hash}
	    options = options.reduce({}, :merge)

	    alignment = options.delete(:align) || options.delete(:alignment)
	    direction = options.delete(:direction) || :horizontal
	    spacing = options.delete(:spacing) || 0

	    raise ArgumentError, "direction must be either :horizontal or :vertical, not #{direction}" unless [:horizontal, :vertical].include?(direction)

	    if alignment
		case direction
		    when :horizontal then raise ArgumentError, "When direction is :horizontal, alignment must be either :top or :bottom, not #{alignment}" unless [:bottom, :top].include?(alignment)
		    when :vertical then raise ArgumentError, "When direction is :vertical, alignment must be either :left or :right, not #{alignment}" unless [:left, :right].include?(alignment)
		end
	    end

	    push build_layout(direction, alignment, spacing, *args, &block)
	end

	def horizontal(*args, &block)
	    options, _ = args.partition {|a| a.is_a? Hash}
	    options = options.reduce({}, :merge)
	    options[:direction] = :horizontal

	    layout options, &block
	end

	def vertical(*args, &block)
	    options, _ = args.partition {|a| a.is_a? Hash}
	    options = options.reduce({}, :merge)
	    options[:direction] = :vertical

	    layout options, &block
	end
    # @endgroup
    end
end
