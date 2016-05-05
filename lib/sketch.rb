require 'geometry'
require_relative 'sketch/builder'
require_relative 'sketch/point.rb'
require_relative 'sketch/sketch_mixin'

=begin
A Sketch is a container for Geometry objects.
=end

class Sketch
    include SketchMixin

    attr_reader :elements
    attr_accessor :transformation

    Arc = Geometry::Arc
    Circle = Geometry::Circle
    Line = Geometry::Line
    Rectangle = Geometry::Rectangle
    Square = Geometry::Square

    def initialize(*args, &block)
	@elements = []

	options, args = args.partition {|a| a.is_a? Hash}
	options = options.reduce({}, :merge)

	transformation_options = options.select {|k,v| [:angle, :move, :origin, :rotate, :scale, :x, :y, :z].include? k }
	@transformation = options.delete(:transformation) || Geometry::Transformation.new(transformation_options)

	options = options.reject {|k,v| [:angle, :move, :origin, :rotate, :scale, :x, :y, :z].include? k }
	options.each { |k,v| send("#{k}=", v); options.delete(k) }

	instance_eval(&block) if block_given?
    end

    # Define a class parameter
    # @param [Symbol] name  The name of the parameter
    # @param [Proc] block   A block that evaluates to the desired value of the parameter
    def self.define_parameter name, &block
	define_method name do
	    @parameters ||= {}
	    @parameters.fetch(name) { |k| @parameters[k] = instance_eval(&block) }
	end
    end

    # Define an instance parameter
    # @param [Symbol] name	The name of the parameter
    # @param [Proc] block	A block that evaluates to the desired value of the parameter
    def define_parameter name, &block
	singleton_class.send :define_method, name do
	    @parameters ||= {}
	    @parameters.fetch(name) { |k| @parameters[k] = instance_eval(&block) }
	end
    end
end

def Sketch(&block)
    Sketch::Builder.new(&block)
end
