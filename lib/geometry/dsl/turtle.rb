module Geometry
    module DSL
=begin
An implementation of {http://en.wikipedia.org/wiki/Turtle_graphics Logo Turtle-style} commands

This module is meant to be included in a class that provides the following methods:

 distance
 last
 push

== Examples
Draw a square...

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
	module Turtle
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
	    # @param distance [Number]	the distance to move in the curren direction
	    def forward(distance)
		push last + (direction * distance)
	    end

	    def left(distance)
		push last + (Vector[-direction[1], direction[0]] * distance)
	    end

	    def right(distance)
		push last + (Vector[direction[1], -direction[0]] * distance)
	    end
	end
    end
end
