require_relative 'dsl'
require_relative 'group'
require_relative 'path_builder'
require_relative 'polyline_builder'

class Sketch
    class Builder
	attr_reader :sketch

	include Sketch::DSL

	# @group Convenience constants
	Point = Geometry::Point
	Rectangle = Geometry::Rectangle
	Size = Geometry::Size
	# @endgroup

	def initialize(sketch=nil, &block)
	    @sketch = sketch || Sketch.new
	    evaluate(&block) if block_given?
	end

	def evaluate(&block)
	    instance_eval &block if block_given?
	    @sketch
	end

# @group Accessors

	# !@attribute [r] elements
	#   @return [Array] The current list of elements
	def elements
	    @sketch.elements
	end

	# !@attribute [r] last
	#   @return [Geometry] The last element added to the {Sketch}
	def last
	    elements.last
	end

# @endgroup

	# Define a named parameter
	# @param [Symbol] name	The name of the parameter
	# @param [Proc] block	A block that evaluates to the value of the parameter
	def let name, &block
	    @sketch.define_parameter name, &block
	end

	# @group Command handlers

	# Create a {Group} with an optional name and transformation
	def group(*args, &block)
	    @sketch.push Sketch::Builder.new(Group.new(*args)).evaluate(&block)
	end

	# Use the given block to build a {Path} and then append it to the {Sketch}
	def path(&block)
	    @sketch.push PathBuilder.new.evaluate(&block)
	end

	# Use the given block to build a {Polyline} and then append it to the {Sketch}
	def polyline(&block)
	    @sketch.push PolylineBuilder.new.evaluate(&block)
	end

	# Append a new object (with optional transformation) to the {Sketch}
	# @return [Sketch]  the {Sketch} that was appended to
	def push(*args)
	    @sketch.push *args
	end

	# Create a {Rectangle} from the given arguments and append it to the {Sketch}
	def rectangle(*args)
	    @sketch.push Rectangle.new(*args)
	    last
	end

	# Create a {Group} using the given translation
	# @param [Point] point	The distance by which to translate the enclosed geometry
	def translate(*args, &block)
	    group(origin:Point[*args], &block)
	end

	# @endgroup

	def method_missing(id, *args, &block)
	    add_symbol = ('add_' + id.to_s).to_sym
	    if @sketch.respond_to? add_symbol
		@sketch.send(add_symbol, *args, &block)
	    elsif @sketch.respond_to? id
		@sketch.send id, *args, &block
	    else
		super if defined?(super)
	    end
	end
    end
end
