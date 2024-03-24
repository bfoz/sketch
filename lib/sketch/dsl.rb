require 'geometry'

require_relative 'builder/polygon'
require_relative 'layout'

class Sketch
=begin rdoc
Syntactic sugar for building a {Sketch}

== Requirements
This module is intended to be included into a builder class that provides some
infrastructure. The builder class must provide an elements getter as well as
the following methods.
    - push(element)
    - define_attribute_reader(name, value, &block)
    - define_attribute_writer(name)
    - build_polygon(origin:nil, &block)
    - build_polyline
=end
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

	# Create and append a new {Annulus}
	# @return [Annulus]
	def annulus(*args, **options)
	    push Geometry::Annulus.new(*args, **options)
	end
	alias :ring :annulus

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
	def hexagon(**options)
	    options[:sides] = 6
	    Geometry::RegularPolygon.new(**options).tap {|a| push a }
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
	# @option origin [Point]    everything inside the block argument is relative to this {Point}
	def polygon(...)
	    if block_given?
		push build_polygon(...)
	    else
		push Sketch::Polygon.new(...)
	    end
	    last
	end

	# Create a {Polyline}
	def polyline(&block)
	    push build_polyline(&block)
	end

	# Create a {Rectangle} from the given arguments and append it to the {Sketch}
	#   @param [Number]	    corner_radius  the radius to use for corner rounds. 0 and nil both disable rounding.
	# @overload rectangle(:origin, :size)
	#   @param :origin  [Point] the lower left corner of the {Rectangle}
	#   @param :size    [Size]  the width and height of the {Rectangle}
	# @overload rectangle(:center, :size)
	#   @param :center  [Point] the center of the {Rectangle}
	#   @param :size    [Size]  the width and height of the {Rectangle}
	# @overload rectangle(:x, :y, :size)
	#   @param :x	    [Point] the left side of the {Rectangle}
	#   @param :y	    [Point] the bottom side of the {Rectangle}
	#   @param :size    [Size]  the width and height of the {Rectangle}
	# @overload rectangle(:top, :left, :bottom, :right, :size)
	#   @note Don't pass all of the arguments at the same time, or the {Rectangle} will be over-constrained
	#   @param :top	    [Point] the top side of the {Rectangle}
	#   @param :left    [Point] the left side of the {Rectangle}
	#   @param :bottom  [Point] the bottom side of the {Rectangle}
	#   @param :right   [Point] the right side of the {Rectangle}
	#   @param :size    [Size]  the width and height of the {Rectangle}
	def rectangle(corner_radius:nil, **options)
	    options[:origin] ||= Point[options.delete(:x) || options.delete(:left) || 0, options.delete(:y) || options.delete(:bottom) || 0]
	    options[:origin] = Point[options.key?(:right) ? (options.delete(:right) - options[:size][0]) : options[:origin][0],
				     options.key?(:top) ? (options.delete(:top) - options[:size][1]) : options[:origin][1]]

	    if corner_radius and corner_radius.nonzero?
		arc_radius = corner_radius
		rectangle = Geometry::Rectangle.new(**options)

		# Clip the arc radius to fit the rectangle
		arc_radius = rectangle.width/2 if 2*arc_radius > rectangle.width
		arc_radius = rectangle.height/2 if 2*arc_radius > rectangle.height

		multipliers = [[1,1], [1,-1], [-1,-1], [-1,1]]
		arc_centers = rectangle.points.zip(multipliers).map {|point, (a, b)| point + Point[a*arc_radius, b*arc_radius] }

		# Normally we do things in clockwise order around here. That's why
		#  self.points returns the points in clockwise order. This method
		#  goes counterclockwise because Arc is always counterclockwise.
		#  That makes it hard to create a clockwise Path that auto-joins
		#  the segments properly.
		point0, point3, point2, point1 = rectangle.points
		arc_centers[1], arc_centers[3] = arc_centers[3], arc_centers[1]
		components = []
		# The bottom edge, shortened by 2*corner_radius
		bottom_left = Point[arc_centers.first.x, point0.y]
		bottom_right = Point[arc_centers[1].x, point1.y]
		components.push bottom_left
		# Bottom-right arc
		right_bottom = Point[point1.x, arc_centers[1].y]
		components.push Geometry::Arc.new(center:arc_centers[1], start:bottom_right, end:right_bottom)
		# Upper-right arc
		right_top = Point[point2.x, arc_centers[2].y]
		top_right = Point[arc_centers[2].x, point2.y]
		components.push Geometry::Arc.new(center:arc_centers[2], start:right_top, end:top_right)
		# Upper-left arc
		top_left = Point[arc_centers.last.x, point3.y]
		left_top = Point[point3.x, arc_centers.last.y]
		components.push Geometry::Arc.new(center:arc_centers.last, start:top_left, end:left_top)
		# Bottom-left arc
		left_bottom = Point[point0.x, arc_centers.first.y]
		components.push Geometry::Arc.new(center:arc_centers.first, start:left_bottom, end:bottom_left)
		# Left side
		components.push bottom_left
		push Geometry::Path.new(*components)
	    else
		push Geometry::Rectangle.new(**options)
	    end
	end

	# @overload new(size, :corner_radius)
	#  Create a Square with sides of the given length
	#  @param [Number]  size	    Bigness
	#  @param [Number]  corner_radius   the radius to use for corner rounds. 0 and nil both disable rounding.
	# @overload new(:origin, :size, :corner_radius)
	#  Creates a {Square} with the given origin and size
	#  @param [Point]   origin	    The lower-left corner
	#  @param [Number]  size	    Bigness
	#  @param [Number]  corner_radius   the radius to use for corner rounds. 0 and nil both disable rounding.
	#  @return [CenteredSquare]
	def square(size=nil, corner_radius:nil, **options)
	    options[:size] = size if size
	    raise ArgumentError, "A size argument is required" unless options[:size]

	    if corner_radius and corner_radius.nonzero?
		arc_radius = corner_radius
		square = Geometry::Square.new(**options)

		# Clip the arc radius to fit the square
		arc_radius = self.size/2 if 2*arc_radius > square.size

		multipliers = [[1,1], [1,-1], [-1,-1], [-1,1]]
		arc_centers = square.points.zip(multipliers).map {|point, (a, b)| point + Point[a*arc_radius, b*arc_radius] }

		# Normally we do things in clockwise order around here. That's why
		#  self.points returns the points in clockwise order. This method
		#  goes counterclockwise because Arc is always counterclockwise.
		#  That makes it hard to create a clockwise Path that auto-joins
		#  the segments properly.
		point0, point3, point2, point1 = square.points
		arc_centers[1], arc_centers[3] = arc_centers[3], arc_centers[1]
		components = []
		# The bottom edge, shortened by 2*corner_radius
		bottom_left = Point[arc_centers.first.x, point0.y]
		bottom_right = Point[arc_centers[1].x, point1.y]
		components.push bottom_left
		# Bottom-right arc
		right_bottom = Point[point1.x, arc_centers[1].y]
		components.push Geometry::Arc.new(center:arc_centers[1], start:bottom_right, end:right_bottom)
		# Upper-right arc
		right_top = Point[point2.x, arc_centers[2].y]
		top_right = Point[arc_centers[2].x, point2.y]
		components.push Geometry::Arc.new(center:arc_centers[2], start:right_top, end:top_right)
		# Upper-left arc
		top_left = Point[arc_centers.last.x, point3.y]
		left_top = Point[point3.x, arc_centers.last.y]
		components.push Geometry::Arc.new(center:arc_centers.last, start:top_left, end:left_top)
		# Bottom-left arc
		left_bottom = Point[point0.x, arc_centers.first.y]
		components.push Geometry::Arc.new(center:arc_centers.first, start:left_bottom, end:bottom_left)
		
		push Geometry::Path.new(*components)
	    else
		push Geometry::Square.new(**options)
	    end
	end

	# Create and add a {Triangle}
	# @param (see Triangle::new)
	def triangle(*args)
	    push Geometry::Triangle.new(*args)
	end

    # @endgroup

	# Create a {Group} with an optional transformation
	def group(...)
	    push build_group(...)
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
	# @param center [Point]		the center of the repetition
	# @param count [Number,Array]	the number of repetitions along each repetition axis
	# @param step	[Number,Array]	the step size between repetitions
	def repeat(center:Geometry::Point.zero, **options, &block)
	    center = Point[center] unless center.is_a?(Point)
	    count = options.delete(:count) || 2
	    step = options.delete(:spacing) || options.delete(:step)

	    raise ArgumentError, 'Must provide a step argument' unless step

	    step = if step.is_a?(Numeric) || !step.respond_to?(:[])
		if count.is_a?(Numeric)
		    Point[step, 0]
		else
		    Point[step, step]
		end
	    else
		Point[Array.new(2) {|i| step[i]}]	# Force step to be two-dimensional
	    end

	    # Don't count along any axis that doesn't have a step value
	    if count.is_a?(Numeric)
		count = step.map {|s| s.zero? ? 1 : count}.to_a
	    end

	    start_point = center + Point[-step.x * (count.first-1)/2, -step.y * (count.last-1)/2]

	    if block_given?
		count.last.times do |y|
		    count.first.times do |x|
			translate(start_point + Point[step.x * x, step.y * y], &block)
		    end
		end
	    else
		Enumerator.new do |yielder|
		    count.last.times do |y|
			count.first.times do |x|
			    yielder.yield start_point + [step.x * x, step.y * y]
			end
		    end
		end
	    end
	end

    # @group Simple Layouts

	# Create a layout
	# @param direction [Symbol] The layout direction (either :horizontal or :vertical)
	# @option options [Symbol] align    :top, :bottom, :left, or :right
	# @option options [Number] spacing  The spacing between each element
	# @return [Group]
	def layout(*args, **options, &block)
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

	    push build_layout(direction, alignment, spacing, *args, **options, &block)
	end

	def horizontal(*args, &block)
	    options, _ = args.partition {|a| a.is_a? Hash}
	    options = options.reduce({}, :merge)
	    options[:direction] = :horizontal

	    layout options, &block
	end

	def vertical(*args, **options, &block)
	    options[:direction] = :vertical
	    layout(*args, **options, &block)
	end
    # @endgroup
    end
end
