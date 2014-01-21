require 'geometry'

class Sketch
    Path = Geometry::Path

    class Builder
	class Path
	    attr_reader :elements

	    def initialize(*args)
		@elements = args || []
	    end

	    # Evaluate a block and return a new {Path}
	    # @return [Path]	A new {Path} initialized with the given block
	    def evaluate(&block)
		self.instance_eval &block if block_given?
		Sketch::Path.new(*@elements)
	    end

	    # Push the given object
	    # @param [Geometry] arg A {Geometry} object to apped to the {Path}
	    # @return [Geometry]    The appended object
	    def push(arg)
		@elements.push arg
		arg
	    end

	    # @return [Bool]    True of the {Path} is closed, otherwise False
	    def closed?
		@position == @start_position
	    end

	    # @group DSL

	    # Close the {Path} with a {Line} if it isn't already closed
	    def close
		move_to(@start_position) unless closed?
	    end

	    # Draw a line to the given {Point}
	    # @param [Point]    The {Point} to draw a line to
	    def move_to(point)
		@position = Point[point]
		push @position
	    end

	    # Move the specified distance along the X axis
	    # @param [Number] distance  The distance to move
	    def move_x(distance)
		push @position += Point[distance, 0]
	    end

	    # Move the specified distance along the Y axis
	    # @param [Number] distance  The distance to move
	    def move_y(distance)
		push @position += Point[0, distance]
	    end

	    # Specify a starting point. Can't be specified twice, and only required if no other entities have been added.
	    # #param [Point] point  The starting point
	    def start_at(point)
		raise BuildError, "Can't specify a start point more than once" if @position
		@position = Point[point]
		push @position
		@start_position = @position
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

	    # @endgroup

	    # @endgroup
	end
    end
end
