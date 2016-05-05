require 'geometry'

module SketchMixin
# @group Accessors
    # @attribute [r] bounds
    #   @return [Rectangle] The smallest axis-aligned {Rectangle} that encloses all of the elements
    def bounds
	Geometry::Rectangle.new(*minmax)
    end

    # @!attribute [r] empty?
    #   @return [Bool]  true is the {Sketch} contains no elements
    def empty?
	elements.empty?
    end

    # @attribute [r] first
    #   @return [Geometry] first the first Geometry element of the {Sketch}
    def first
	elements.first
    end

    # @attribute [r] geometry
    #   @return [Array] All elements rendered into Geometry objects
    def geometry
	@elements
    end

    # @attribute [r] last
    #  @return [Geometry] the last Geometry element of the {Sketch}
    def last
	elements.last
    end

    # @attribute [r] max
    # @return [Point]
    def max
	minmax.last
    end

    # @attribute [r] min
    # @return [Point]
    def min
	minmax.first
    end

    # @attribute [r] minmax
    # @return [Array<Point>]
    def minmax
	return [nil, nil] unless @elements.size != 0

	memo = @elements.map(&:minmax).reduce {|m, e| [m.first.min(e.first), m.last.max(e.last)] }
	if self.transformation
	    if self.transformation.has_rotation?
		# If the transformation has a rotation, convert the minmax into a bounding rectangle, rotate it, then find the new minmax
		point1, point3 = Point[memo.last.x, memo.first.y], Point[memo.first.x, memo.last.y]
		points = [memo.first, point1, memo.last, point3].map {|point| self.transformation.transform(point) }
		points.reduce([points[0], points[2]]) {|m, e| [m.first.min(e), m.last.max(e)] }
	    else
		memo.map {|point| self.transformation.transform(point) }
	    end
	else
	    memo
	end
    end

    # @attribute [r] size
    # @return [Size]	The size of the {Rectangle} that bounds all of the {Sketch}'s elements
    def size
	Geometry::Size[self.minmax.reverse.reduce(:-).to_a]
    end

# @endgroup

    # Append the given {Geometry} element and return the {Sketch}
    # @param element	[Geometry]	the {Geometry} element to append
    # @param args	[Array]		optional transformation parameters
    # @return [Sketch]
    def push(element, *args)
	options, args = args.partition {|a| a.is_a? Hash}
	options = options.reduce({}, :merge)

	if options and (options.size != 0) and (element.respond_to? :transformation)
	    element.transformation = Geometry::Transformation.new options
	end

	@elements.push(element)
	self
    end

    # Return a new {Sketch} that's been translated into the first quadrant
    def first_quadrant
	self.clone.first_quadrant!
    end

    # Translate the {Sketch} so that it lies entirely in the first quadrant
    # @return [Sketch]	the translated {Sketch}
    def first_quadrant!
	self.transformation = Geometry::Transformation.new(origin:-self.min) unless first_quadrant?
	self
    end

    # @return [Bool]	true if the {Sketch} lies entirely in the first quadrant
    def first_quadrant?
	self.min.all? {|a| a >= 0}
    end
end
