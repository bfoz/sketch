require 'geometry'
require_relative 'sketch/builder'
require_relative 'sketch/point.rb'
require_relative 'sketch/polygon'

=begin
A Sketch is a container for Geometry objects.
=end

class Sketch
    attr_reader :elements

    Circle = Geometry::Circle
    Line = Geometry::Line
    Rectangle = Geometry::Rectangle

    def initialize(&block)
	@elements = []
	instance_eval(&block) if block_given?
    end

    # Return all of the Sketch's elements rendered into Geometry objects
    def geometry
	@elements
    end

    # Adds all of the given {Geometry} objects to the {Sketch}
    # @param [Array<Geometry>]   args The {Geometry} elements to add to the {Sketch}
    # @return [Geometry]    The last element added to the {Sketch}
    def push(*args)
	@elements.push *args
	@elements.last
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
	add_rectangle length, length
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
end

def Sketch(&block)
    Sketch::Builder.new &block
end
