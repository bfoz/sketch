require 'geometry'
require_relative 'sketch/point.rb'
require_relative 'sketch/polygon'

=begin
A Sketch is a container for Geometry objects.
=end

class Sketch
    attr_reader :elements

    Line = Geometry::Line

    def initialize
	@elements = []
    end

    # Return all of the Sketch's elements rendered into Geometry objects
    def geometry
	@elements
    end

    # Create a new Circle with the given center and radius
    def circle(*center, radius)
	@elements.push Circle.new(0,0,radius)
	@elements.last
    end

    # Create a Line using any arguments that work for {Geometry::Line}
    def line(*args)
	@elements.push Line[*args]
	@elements.last
    end

    # Create a Point with any arguments that work for {Geometry::Point}
    def point(*args)
	@elements.push Point[*args]
	@elements.last
    end

    # Create a Polygon with the given vertices, or using a block.
    # See {PolygonBuilder}
    def polygon(*args, &block)
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
    s = Sketch.new
    s.instance_eval(&block) if block_given?
    s
end