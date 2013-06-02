require_relative 'group'

=begin
{Layout} is a container that arranges its child elements in the specified
direction and, optionally, with the specified spacing.

For example, to create two adjacent squares along the X-axis, use:

    Layout.new :horizontal do
        square size:5
        square size:6
    end

=end
class Sketch
    class Layout < Group
	# @return [Symbol] direction    the layout direction (either :horizontal or :vertical)
	attr_reader :direction

	# @return [Number] spacing  spacing to add between each element
	attr_reader :spacing

	def initialize(direction=:horizontal, *args)
	    super

	    options, args = args.partition {|a| a.is_a? Hash}
	    options = options.reduce({}, :merge)

	    @spacing = options.delete(:spacing) || 0

	    @direction = direction
	end

	# @param element [Geometry] the geometry element to append
	# @return [Layout]
	def push(element, *args)
	    if last
		max = last.max

		if element.respond_to?(:transformation=)
		    super element, *args

		    last.transformation = Geometry::Transformation.new(origin:make_offset(last.min, max)) + last.transformation
		else
		    group = Group.new
		    group.push element, *args
		    super group

		    last.transformation = Geometry::Transformation.new(origin:make_offset(last.min, max)) + last.transformation
		end
	    else
		super element, *args
	    end

	    self
	end

	private

	def make_offset(min, max)
	    case direction
		when :horizontal    then Point[max.x - last.min.x + spacing, 0]
		when :vertical	    then Point[0, max.y - last.min.y + spacing]
	    end
	end
    end
end