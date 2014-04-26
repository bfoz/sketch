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

	    # @group Absolute Movement

	    # Draw a line to the given {Point}
	    # @param [Point]    The {Point} to draw a line to
	    def move_to(point)
		push Point[point]
	    end

	    # Draw a vertical line to the given y-coordinate while preserving the
	    # x-coordinate of the previous {Point}
	    # @param y [Number] the y-coordinate to move to
	    def vertical_to(y)
		move_to Point[last.x, y]
	    end
	    alias :down_to :vertical_to
	    alias :up_to :vertical_to

	    # Draw a horizontal line to the given x-coordinate while preserving the
	    # y-coordinate of the previous {Point}
	    # @param x [Number] the x-coordinate to move to
	    def horizontal_to(x)
		move_to [x, last.y]
	    end
	    alias :left_to :horizontal_to
	    alias :right_to :horizontal_to

	    # @endgroup

	    # @group Relative Movement

	    # Move the specified distances along multiple axes simultaneously
	    # @param distance [Vector]	the distance vector to move
	    def move(*distance)
		push Point.zero unless last
		push last + Point[*distance]
	    end

	    # Move the specified distance along the X axis
	    # @param [Number] distance  The distance to move
	    def move_x(distance)
		move Point[distance, 0]
	    end

	    # Move the specified distance along the Y axis
	    # @param [Number] distance  The distance to move
	    def move_y(distance)
		move Point[0, distance]
	    end

	    # Specify a starting point. Can't be specified twice, and only required if no other entities have been added.
	    # #param [Point] point  The starting point
	    def start_at(point)
		raise BuildError, "Can't specify a start point more than once" if first
		push Point[point]
	    end

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

	    # @endgroup

	    # Repeat the given Turtle block until the end is reached
	    # @overload(step, count)
	    #   Repeat the given step size the specified count
	    #   @param step [Array,Vector]  The step for each repeat. Must be a {Vector}, or {Vector}-like substance.
	    #   @param count [Number]	The number of steps to take
	    # @overload(to, count)
	    #   Repeat the block the specified number of times
	    #   @param to	[Point]	    the destination
	    #	@param count	[Number]    the repetition count
	    # @overload(to, step)
	    #   Repeat along the line segment ending at *to* using the given step size
	    #   @param to [Point]   the {Point} to stop at
	    #   @param step [Number]	the step size
	    def repeat(*args, &block)
		raise ArgumentError unless block_given?

		options, args = args.partition {|a| a.is_a? Hash}
		options = options.reduce({}, :merge)

		count = options.delete(:count)
		to = Point[options.delete(:to)]
		step = options.delete(:step)
		if count and step
		    raise TypeError, "When :count and :step are given, step must not be a Numeric" if step.is_a? Numeric
		    to = last + (Point[step] * count)
		elsif to and step
		    raise TypeError, "When :to and :step are given, :step must be Numeric" unless step.is_a? Numeric
		    count = (to - last).magnitude/step
		end

		repeat_to to, count, &block
	    end
	end
    end
end