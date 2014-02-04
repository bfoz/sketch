require_relative '../sketch'

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
    class Group < Sketch
	attr_reader :transformation

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
