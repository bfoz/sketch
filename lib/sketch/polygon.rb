require_relative 'polyline_builder'

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
    class PolygonBuilder < PolylineBuilder
	Edge = Geometry::Edge

	# @return [Polygon] the {Polygon} resulting from evaluating the given block
	def evaluate(&block)
	    super
	    Polygon.new *@elements
	end

	# @group Primitive creation

	# Create and append a new Edge object
	def edge(*args)
	    @elements.push Edge.new(*args)
	end

	# @endgroup

	# @group Turtle-style commands:

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

	    push(last + distance)
	end

	# Move the specified distance in the current direction
	def forward(distance)
	    @direction ||= 0	# direction defaults to 0
	    radians = @direction * Math::PI / 180
	    push(last + Vector[distance*Math.cos(radians),distance*Math.sin(radians)])
	end

	# @endgroup
    end
end
