module Geometry
    module DSL
=begin rdoc
When you want to draw things that are made of lots and lots of lines, this is how you do it.

== Requirements
This module is intended to be included into a Class, and that Class must provide
some infrastructure. It must provide a push method for pushing new elements, a
first method that returns the first vertex in the {Polyline}, and a last method
that returns the last vertex.

== Usage
    begin
	start_at    [0,0]
	move_y	    1	    # Go up 1 unit
	right	    1
	down	    1
	left	    1	    # Close the box
	close		    # Unnecessary in this case
    end
=end
	module Polyline
	    BuildError = Class.new(StandardError)

	    # Close the {Polyline} with a {Line}, if it isn't already closed
	    def close
		move_to(first) unless closed?
	    end

	    # @return [Bool]    True if the {Polyline} is closed, otherwise false
	    def closed?
		first == last
	    end

	    # Draw a line to the given {Point}
	    # @param [Point]    The {Point} to draw a line to
	    def move_to(point)
		push Point[point]
	    end

	    # Move the specified distances along multiple axes simultaneously
	    # @param distance [Vector]	the distance vector to move
	    def move(*distance)
		push (last + Point[*distance])
	    end

	    # Move the specified distance along the X axis
	    # @param [Number] distance  The distance to move
	    def move_x(distance)
		push (last || PointZero) + Point[distance, 0]
	    end

	    # Move the specified distance along the Y axis
	    # @param [Number] distance  The distance to move
	    def move_y(distance)
		push (last || PointZero) + Point[0, distance]
	    end

	    # Specify a starting point. Can't be specified twice, and only required if no other entities have been added.
	    # #param [Point] point  The starting point
	    def start_at(point)
		raise BuildError, "Can't specify a start point more than once" if first
		push Point[point]
	    end

	    # @group Relative Movement

	    # Move the specified distance along the +Y axis
	    # @param [Number] distance  The distance to move in the +Y direction
	    def up(distance)
		move_y distance
	    end

	    # Move the specified distance along the -Y axis
	    # @param [Number] distance  The distance to move in the -Y direction
	    def down(distance)
		move_y -distance
	    end

	    # Move the specified distance along the -X axis
	    # @param [Number] distance  The distance to move in the -X direction
	    def left(distance)
		move_x -distance
	    end

	    # Move the specified distance along the +X axis
	    # @param [Number] distance  The distance to move in the +X direction
	    def right(distance)
		move_x distance
	    end

	    # Draw a vertical line to the given y-coordinate while preserving the
	    # x-coordinate of the previous {Point}
	    # @param y [Number] the y-coordinate to move to
	    def vertical_to(y)
		push Point[last.x, y]
	    end
	    alias :down_to :vertical_to
	    alias :up_to :vertical_to

	    # Draw a horizontal line to the given x-coordinate while preserving the
	    # y-coordinate of the previous {Point}
	    # @param x [Number] the x-coordinate to move to
	    def horizontal_to(x)
		push [x, last.y]
	    end
	    alias :left_to :horizontal_to
	    alias :right_to :horizontal_to

	    # @endgroup
	end
    end
end