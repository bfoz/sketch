require 'geometry'
require_relative 'point'

class Sketch
    Polygon = Geometry::Polygon

=begin
Builds a vertex list from a set of commands and returns a {Polygon}

== Examples
Draw a square using {http://en.wikipedia.org/wiki/Turtle_graphics Logo Turtle-style} commands

   PolygonBuilder.new.evaluate do
       start_at [0,0]	# Every journey begins with a single point...
       move_to [1,0]	# Draw a line to a new point
       turn_left 90
       move 1		# Same as forward 1
       turn_left 90
       forward 1
    end

The same thing, but more succint:

   PolygonBuilder.new.evaluate do
        start_at [0,0]
        move [1,0]	# Move and draw using a vector distance
        move [0,1]
        move [-1,0]
    end

=end
    class PolygonBuilder
	attr_reader :elements
	
	Edge = Geometry::Edge

	def initialize
	    @elements = []
	end

	# Evaluates a block of commands and returns a new {Polygon}
	def evaluate(&block)
	    @self_before_instance_eval = eval "self", block.binding
	    self.instance_eval &block
	    Polygon.new(*@elements)
	end
	def method_missing(method, *args, &block)
	    p "missing #{method.to_s}"
	    @self_before_instance_eval.send method, *args, &block
	end

	# @group Primitive creation

	# Create and append a new Edge object
	def edge(*args)
	    @elements.push Edge.new(*args)
	end

	# Create and append a new vertex
	def point(*args)
	    self.vertex(*args)
	end

	# Create and append a new vertex
	def vertex(*args)
	    @elements.push Point[*args]
	end

	# @endgroup

	# @group Turtle-style commands:

	# Specify a starting point. Only required if no other entities have been added yet
	def start_at(point)
	    vertex(point)
	end

	# Draw a line to the given point
	def move_to(point)
	    vertex(point)
	end

	# Turn left by the given number of degrees
	def turn_left(angle)
	    @direction += angle if @direction
	    @direction ||= angle
	end

	# Turn right by the given number of degrees
	def turn_right(angle)
	    turn_left -angle
	end

	# Draw a line by moving a given distance
	# @overload move(Numeric)
	#  Same as forward(Numeric)
	# @overload move(Array)
	# @overload move(x,y)
	def move(*distance)
	    return forward(*distance) if (1 == distance.size) && distance[0].is_a?(Numeric)

	    if distance[0].is_a?(Vector)
		distance = distance[0]
	    elsif distance[0].is_a?(Array)
		distance = Vector[*(distance[0])]
	    end

	    vertex(last_point + distance)
	end

	# Move the specified distance in the current direction
	def forward(distance)
	    @direction ||= 0	# direction defaults to 0
	    radians = @direction * Math::PI / 180
	    vertex(last_point + Vector[distance*Math.cos(radians),distance*Math.sin(radians)])
	end

	# @endgroup
    private

	def last_point
	    @elements.last.is_a?(Edge) ? @elements.last.last : @elements.last
	end
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