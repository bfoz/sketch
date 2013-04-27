require 'geometry'
require_relative 'sketch/builder'
require_relative 'sketch/point.rb'
require_relative 'sketch/polygon'

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
	return nil unless @elements.count
	max = nil
	min = nil
	@elements.each do |e|
	    emin, emax = e.minmax
	    max = max ? Point[[max.x, emax.x].max, [max.y, emax.y].max] : emax
	    min = min ? Point[[min.x, emin.x].min, [min.y, emin.y].min] : emin
	end
	Rectangle.new(min, max)
    end

    # @attribute [r] geometry
    #   @return [Array] All elements rendered into Geometry objects
    def geometry
	@elements
    end

    # @attribute [r] max
    # @return [Point]
    def max
	@elements.map {|e| e.max }.reduce {|memo, e| Point[[memo.x, e.x].max, [memo.y, e.y].max] }
    end

    # @attribute [r] min
    # @return [Point]
    def min
	@elements.map {|e| e.min }.reduce {|memo, e| Point[[memo.x, e.x].min, [memo.y, e.y].min] }
    end

    # @attribute [r] minmax
    # @return [Array<Point>]
    def minmax
	@elements.map {|e| e.minmax }.reduce {|memo, e| [Point[[memo.first.x, e.first.x].min, [memo.first.y, e.first.y].min], Point[[memo.last.x, e.last.x].max, [memo.last.y, e.last.y].max]] }
    end

    # @attribute [r] size
    # @return [Size]	The size of the {Rectangle} that bounds all of the {Sketch}'s elements
    def size
	self.minmax.reverse.reduce(:-)
    end

# @endgroup

    # Adds the given {Geometry} elements to the {Sketch}
    # @param [Array<Geometry>]   args The {Geometry} elements to add to the {Sketch}
    # @return [Geometry]    The last element added to the {Sketch}
    def push(element, *args)
	options, args = args.partition {|a| a.is_a? Hash}
	options = options.reduce({}, :merge)

	if options and (options.size != 0) and (element.respond_to? :transformation)
	    element.transformation = Geometry::Transformation.new options
	end

	@elements.push(element).last
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
    end

    # Create a Polygon with the given vertices, or using a block.
    # See {PolygonBuilder}
    def add_polygon(*args, &block)
	if block_given?
	    @elements.push PolygonBuilder.new.evaluate(&block)
	    @elements.last
	else
	    @elements.push Polygon.new(*args)
	    @elements.last
	end
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
