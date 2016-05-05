require_relative 'sketch_mixin'

=begin
{Group} is a container for grouping elements of a {Sketch} with an optional
{Geometry::Transformation Transformation} property.

    sketch :ExampleModel do
	group origin:[4,2] do
	    circle diameter:5.meters
	end
    end
=end
class Sketch
    class Group
	include SketchMixin

	attr_reader :elements
	attr_accessor :transformation

	def initialize(*args, **options, &block)
	    @elements = []

	    transformation_options = options.select {|k,v| [:angle, :move, :origin, :rotate, :scale, :x, :y, :z].include? k }
	    @transformation = options.delete(:transformation) || Geometry::Transformation.new(transformation_options)

	    options = options.reject {|k,v| [:angle, :move, :origin, :rotate, :scale, :x, :y, :z].include? k }
	    options.each { |k,v| send("#{k}=", v); options.delete(k) }

	    instance_eval(&block) if block_given?
	end

	def rotation
	    @transformation.rotation
	end

	def scale
	    @transformation.scale
	end

	def translation
	    @transformation.translation
	end
    end
end
