require 'geometry'
require 'geometry/dsl/polyline'
require_relative 'repeat'

class Sketch
    Polyline = Geometry::Polyline

    class Builder
	class Polyline
	    include Geometry::DSL::Polyline

	    # @option origin [Point]    all {Points} are relative to this {Point}
	    def initialize(*args, **options)
		@elements = args || []
		@origin = options.delete(:origin) || Point.zero
	    end

	    # Evaluate a block and return a new {Path}
	    #  Use the trick found here http://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation
	    #  to allow the DSL block to call methods in the enclosing *lexical* scope
	    # @return [Polyline]	A new {Polyline} initialized with the given block
	    def evaluate(&block)
		if block_given?
		    @self_before_instance_eval = eval "self", block.binding
		    self.instance_eval &block
		    @elements.map! {|point| point + @origin }
		end
		Sketch::Polyline.new(*@elements)
	    end

	    # The second half of the instance_eval delegation trick mentioned at
	    #   http://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation
	    def method_missing(method, *args, &block)
		@self_before_instance_eval.send method, *args, &block
	    end

	    # @return [Point]   the first vertex of the {Polyline}
	    def first
		@elements.first
	    end

	    # @return [Point]   the last, or most recently added, vertex of the {Polyline}
	    def last
		@elements.last
	    end

	    # Append a vertex
	    # @param point [Point]	the {Point} to append
	    # @return [Polyline]
	    def push(point)
		@elements.push point
		self
	    end

	    # Repeat the geometry generated by the given block until the destination is reached
	    # @param to [Point]	the destination
	    # @param step [Vector]  the step size for each iteration
	    def repeat_to(to, step, &block)
		Builder::Repeat.build(last, to, step, &block).each {|point| push point }
	    end
	end
    end
end
