class Sketch
    class Builder
	attr_reader :sketch

	def initialize(sketch=nil, &block)
	    @sketch = sketch || Sketch.new
	    evaluate(&block) if block_given?
	end

	def evaluate(&block)
	    instance_eval &block
	    @model
	end

	def push(*args)
	    @sketch.push *args
	end

	def method_missing(id, *args, &block)
	    add_symbol = ('add_' + id.to_s).to_sym
	    if @sketch.respond_to? add_symbol
		@sketch.send(add_symbol, *args, &block)
	    else
		super if defined?(super)
	    end
	end
    end
end
