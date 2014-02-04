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
	# @return [Symbol] alignment	the layout alignment
	attr_reader :alignment

	# @return [Symbol] direction    the layout direction (either :horizontal or :vertical)
	attr_reader :direction

	# @return [Number] spacing  spacing to add between each element
	attr_reader :spacing

	# @param direction  [Symbol]	the layout direction
	# @param alignment  [Symbol]	the alignment to use in the direction perpendicular to the layout direction
	# @param spacing    [Number]	the space to leave between each element
	def initialize(*args)
	    options, args = args.partition {|a| a.is_a? Hash}
	    options = options.reduce({}, :merge)

	    @direction = options.delete(:direction) || :horizontal
	    @alignment = options.delete(:align) || options.delete(:alignment) || ((@direction == :horizontal) ? :bottom : :left)
	    @spacing = options.delete(:spacing) || 0

	    args += [options] if options and not options.empty?
	    super *args
	end

	# Any pushed element that doesn't have a transformation property will be wrapped in a {Group}.
	# @param element [Geometry] the geometry element to append
	# @return [Layout]
	def push(element, *args)
	    max = last ? last.max : Point.zero

	    offset = make_offset(element, element.min, max)

	    if offset == Point.zero
		super element, *args
	    else
		if element.respond_to?(:transformation=)
		    super element, *args
		else
		    super Group.new.push element, *args
		end

		last.transformation = Geometry::Transformation.new(origin:offset) + last.transformation
	    end
	    self
	end

	private

	def make_offset(element, min, max)
	    case direction
		when :horizontal
		    y_offset = case alignment
			when :bottom
			    -min.y
			when :top
			    height = element.size.y
			    if height > max.y
				# Translate everything up by reparenting into a new group
				if elements.size != 0
				    alignment_group = Group.new
				    alignment_group.transformation = Geometry::Transformation.new(origin: [0, height - max.y])
				    elements.each {|a| alignment_group.push a }
				    elements.replace [alignment_group]
				end

				-min.y	# Translate the new element to the x-axis
			    else
				# Translate the new element to align with the previous element
				max.y - height
			    end
			else
			    0
		    end

		    Point[max.x - min.x + ((elements.size != 0) ? spacing : 0), y_offset]
		when :vertical
		    x_offset = case alignment
			when :left
			    -min.x
			when :right
			    width = element.size.x
			    if width > max.x
				# Translate everything right by reparenting into a new group
				if elements.size != 0
				    alignment_group = Group.new
				    alignment_group.transformation = Geometry::Transformation.new(origin: [width - max.x, 0])
				    elements.each {|a| alignment_group.push a }
				    elements.replace [alignment_group]
				end

				-min.x	# Translate the new element to the y-axis
			    else
				# Translate the new element to align with the previous element
				max.x - width
			    end
			else
			    0
		    end

		    Point[x_offset, max.y - min.y + ((elements.size != 0) ? spacing : 0)]
	    end
	end
    end
end