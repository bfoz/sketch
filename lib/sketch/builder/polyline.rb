require 'geometry/dsl/polyline'

class Sketch
    Polyline = Geometry::Polyline

    class Builder
	class Polyline
	    include Geometry::DSL::Polyline

	    def initialize(*args)
		@elements = args || []
	    end

	    # Evaluate a block and return a new {Path}
	    #  Use the trick found here http://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation
	    #  to allow the DSL block to call methods in the enclosing *lexical* scope
	    # @return [Polyline]	A new {Polyline} initialized with the given block
	    def evaluate(&block)
		if block_given?
		    @self_before_instance_eval = eval "self", block.binding
		    self.instance_eval &block
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

	    # Push the given object
	    # @param [Geometry] arg A {Geometry} object to apped to the {Path}
	    # @return [Geometry]    The appended object
	    def push(arg)
		@elements.push arg
		arg
	    end
	end
    end
end
