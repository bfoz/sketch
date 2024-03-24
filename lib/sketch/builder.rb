require_relative 'dsl'
require_relative 'group'
require_relative 'builder/polyline'

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
	    @attribute_defaults = {}
	    @attribute_getters = {}
	    @attribute_setters = {}
	    @sketch = sketch || Sketch.new
	    evaluate(&block) if block_given?
	end

	# Evaluate a block and return a new {Path}
	#  Use the trick found here http://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation
	#  to allow the DSL block to call methods in the enclosing *lexical* scope
	# @return [Sketch]	A new {Sketch} initialized with the given block
	def evaluate(&block)
	    if block_given?
		@self_before_instance_eval = eval "self", block.binding
		self.instance_eval(&block)
	    end
	    @sketch
	end

	# The second half of the instance_eval delegation trick mentioned at
	#   http://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation
	def method_missing(method, *args, &block)
	    add_symbol = ('add_' + method.to_s).to_sym
	    if @sketch.respond_to? add_symbol
		@sketch.send(add_symbol, *args, &block)
	    elsif @sketch.respond_to? method
		@sketch.send method, *args, &block
	    elsif @self_before_instance_eval.respond_to? method
		@self_before_instance_eval.send method, *args, &block
	    else
		super if defined?(super)
	    end
	end

	# Define an attribute with the given name and optional default value (or block)
	# @param name [String]	The attribute's name
	# @param value An optional default value
	def define_attribute_reader(name, value=nil, &block)
	    klass = @sketch.respond_to?(:define_method, true) ? @sketch : @sketch.class
	    name, value = name.flatten if name.is_a?(Hash)
	    if value || block_given?
		@attribute_defaults[name] = value || block
		@sketch.instance_variable_set('@' + name.to_s, value || instance_eval(&block))
	    end
	    klass.send :define_method, name do
		instance_variable_get('@' + name.to_s)
	    end
	    @attribute_getters[name] = klass.instance_method(name)
	end

	def define_attribute_writer(name)
	    klass = @sketch.respond_to?(:define_method, true) ? @sketch : @sketch.class
	    method_name = name.to_s + '='
	    klass.send :define_method, method_name do |value|
		instance_variable_set '@' + name.to_s, value
	    end
	    @attribute_setters[method_name] = klass.instance_method(method_name)
	end

# @group Accessors

	# !@attribute [r] elements
	#   @return [Array] The current list of elements
	def elements
	    @sketch.elements
	end

# @endgroup

# @group DSL support methods

private

	# Define a named parameter
	# @param [Symbol] name	The name of the parameter
	# @param [Proc] block	A block that evaluates to the value of the parameter
	def let name, &block
	    @sketch.define_parameter name, &block
	end

	# Create a {Group} with an optional transformation
	def build_group(*args, **options, &block)
	    self.class.new(Group.new(*args, **options)).evaluate(&block)
	end

	# Create a {Layout}
	# @param direction [Symbol] The layout direction (either :horizontal or :vertical)
	# @option options [Symbol] alignment    :top, :bottom, :left, or :right
	# @option options [Number] spacing  The spacing between each element
	# @return [Group]
	def build_layout(direction, alignment, spacing, *args, **options, &block)
	    options = options.reduce({direction:direction, alignment:alignment, spacing:spacing}, :merge)
	    self.class.new(Layout.new(*args, **options)).evaluate(&block)
	end

	# Use the given block to build a {Polyline}
	def build_polyline(**options, &block)
	    Builder::Polyline.new(**options).evaluate(&block)
	end

	# Build a {Polygon} from a block
	# @return [Polygon]
	def build_polygon(*args, **options, &block)
	    Builder::Polygon.new(*args, **options).evaluate(&block)
	end

	# Append a new object (with optional transformation) to the {Sketch}
	# @return [Sketch]  the {Sketch} that was appended to
	def push(...)
	    @sketch.push(...)
	end

# @endgroup
    end
end
