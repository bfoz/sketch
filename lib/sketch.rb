require 'geometry'
require_relative 'sketch/builder'
require_relative 'sketch/point.rb'

=begin
A Sketch is a container for Geometry objects.
=end

class Sketch
    attr_reader :elements
    attr_accessor :transformation

    Arc = Geometry::Arc
    Circle = Geometry::Circle
    Line = Geometry::Line
    Rectangle = Geometry::Rectangle
    Square = Geometry::Square

    def initialize(&block)
	@elements = []
	instance_eval(&block) if block_given?
    end

    # Define a class parameter
    # @param [Symbol] name  The name of the parameter
    # @param [Proc] block   A block that evaluates to the desired value of the parameter
    def self.define_parameter name, &block
	define_method name do
	    @parameters ||= {}
	    @parameters.fetch(name) { |k| @parameters[k] = instance_eval(&block) }
	end
    end

    # Define an instance parameter
    # @param [Symbol] name	The name of the parameter
    # @param [Proc] block	A block that evaluates to the desired value of the parameter
    def define_parameter name, &block
	singleton_class.send :define_method, name do
	    @parameters ||= {}
	    @parameters.fetch(name) { |k| @parameters[k] = instance_eval(&block) }
	end
    end

# @group Accessors
    # @attribute [r] bounds
    #   @return [Rectangle] The smallest axis-aligned {Rectangle} that encloses all of the elements
    def bounds
	Rectangle.new(*minmax)
    end

    # @!attribute [r] empty?
    #   @return [Bool]  true is the {Sketch} contains no elements
    def empty?
	elements.empty?
    end

    # @attribute [r] first
    #   @return [Geometry] first the first Geometry element of the {Sketch}
    def first
	elements.first
    end

    # @attribute [r] geometry
    #   @return [Array] All elements rendered into Geometry objects
    def geometry
	@elements
    end

    # @attribute [r] last
    #  @return [Geometry] the last Geometry element of the {Sketch}
    def last
	elements.last
    end

    # @attribute [r] max
    # @return [Point]
    def max
	minmax.last
    end

    # @attribute [r] min
    # @return [Point]
    def min
	minmax.first
    end

    # @attribute [r] minmax
    # @return [Array<Point>]
    def minmax
	return [nil, nil] unless @elements.size != 0

	memo = @elements.map {|e| e.minmax }.reduce {|memo, e| [Point[[memo.first.x, e.first.x].min, [memo.first.y, e.first.y].min], Point[[memo.last.x, e.last.x].max, [memo.last.y, e.last.y].max]] }
	if self.transformation
	    if self.transformation.has_rotation?
		# If the transformation has a rotation, convert the minmax into a bounding rectangle, rotate it, then find the new minmax
		point1, point3 = Point[memo.last.x, memo.first.y], Point[memo.first.x, memo.last.y]
		points = [memo.first, point1, memo.last, point3].map {|point| self.transformation.transform(point) }
		points.reduce([points[0], points[2]]) {|memo, e| [Point[[memo.first.x, e.x].min, [memo.first.y, e.y].min], Point[[memo.last.x, e.x].max, [memo.last.y, e.y].max]] }
	    else
		memo.map {|point| self.transformation.transform(point) }
	    end
	else
	    memo
	end
    end

    # @attribute [r] size
    # @return [Size]	The size of the {Rectangle} that bounds all of the {Sketch}'s elements
    def size
	Size[self.minmax.reverse.reduce(:-).to_a]
    end

# @endgroup

    # Append the given {Geometry} element and return the {Sketch}
    # @param element	[Geometry]	the {Geometry} element to append
    # @param args	[Array]		optional transformation parameters
    # @return [Sketch]
    def push(element, *args)
	options, args = args.partition {|a| a.is_a? Hash}
	options = options.reduce({}, :merge)

	if options and (options.size != 0) and (element.respond_to? :transformation)
	    element.transformation = Geometry::Transformation.new options
	end

	@elements.push(element)
	self
    end

    # Return a new {Sketch} that's been translated into the first quadrant
    def first_quadrant
	self.clone.first_quadrant!
    end

    # Translate the {Sketch} so that it lies entirely in the first quadrant
    # @return [Sketch]	the translated {Sketch}
    def first_quadrant!
	self.transformation = Geometry::Transformation.new(origin:-self.min) unless first_quadrant?
	self
    end

    # @return [Bool]	true if the {Sketch} lies entirely in the first quadrant
    def first_quadrant?
	self.min.all? {|a| a >= 0}
    end

# @group Geometry creation

    # Create and append a new {Arc} object
    # @param (see Arc#initialize)
    # @return [Arc]
    def add_arc(*args)
	@elements.push(Arc.new(*args)).last
    end

    # Create and append a new {Circle} object given a center point and radius
    # @param	[Point]	    center  The circle's center point
    # @param	[Number]    radius  The circle's radius
    # @return	[Circle]    A new {Circle}
    def add_circle(*args)
	@elements.push Circle.new(*args)
	@elements.last
    end

    # Create a Line using any arguments that work for {Geometry::Line}
    def add_line(*args)
	@elements.push Line[*args]
	@elements.last
    end

    # Create a Point with any arguments that work for {Geometry::Point}
    def add_point(*args)
	@elements.push Point[*args]
	@elements.last
    end

    # Create a {Rectangle}
    def add_rectangle(*args)
	@elements.push Rectangle.new(*args)
	@elements.last
    end

    # Create a Square with sides of the given length
    # @param [Numeric] length	The length of the sides of the square
    def add_square(length)
	push Geometry::CenteredSquare.new [0,0], length
	@elements.last
    end

    # Create and add a {Triangle}
    # @param (see Triangle::new)
    def add_triangle(*args)
	push Geometry::Triangle.new *args
    end

# @endgroup

end

def Sketch(&block)
    Sketch::Builder.new &block
end
