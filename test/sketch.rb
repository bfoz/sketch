require 'minitest/autorun'
require 'sketch'

describe Sketch do
    let(:sketch)    { Sketch.new }

    it "should create a Sketch object" do
	sketch.must_be_kind_of Sketch
    end

    it "should have a read only elements accessor" do
	sketch.must_respond_to :elements
	sketch.wont_respond_to :elements=
    end

    it "must have a push method that pushes elements" do
	sketch.push Rectangle.new 5, 5
	sketch.elements.last.must_be_kind_of Rectangle
    end

    describe "parameters" do
	it "must define custom parameters" do
	    Sketch.define_parameter(:a_parameter) { 42 }
	    Sketch.new.a_parameter.must_equal 42
	end

	it "must bequeath custom parameters to subclasses" do
	    Sketch.define_parameter(:a_parameter) { 42 }
	    Class.new(Sketch).new.must_respond_to(:a_parameter)
	end

	it "must not allow access to parameters defined on a subclass" do
	    Sketch.define_parameter(:a_parameter) { 42 }
	    Class.new(Sketch).define_parameter(:b_parameter) { 24 }
	    Sketch.new.wont_respond_to :b_parameter
	end
    end

    it "should have a circle command that makes a new circle from a center point and radius" do
	circle = sketch.add_circle [1,2], 3
	circle.must_be_kind_of Geometry::Circle
	circle.center.must_equal Point[1,2]
	circle.radius.must_equal 3
    end

    it "should have a point creation method" do
	point = sketch.add_point(5,6)
	point.must_be_kind_of Sketch::Point
	point.x.must_equal 5
	point.y.must_equal 6
    end

    it "have a line creation method" do
	line = sketch.add_line([5,6], [7,8])
	line.must_be_kind_of Sketch::Line
    end

    it "have a rectangle creation method" do
	rectangle = sketch.add_rectangle 10, 20
	rectangle.must_be_kind_of Geometry::Rectangle
	rectangle.points.must_equal [Point[-5,-10], Point[-5,10], Point[5,10], Point[5,-10]]
    end

    it "should have a method for adding a square" do
	square = sketch.add_square 10
	square.must_be_kind_of Geometry::Square
	square.width.must_equal 10
	square.height.must_equal 10
	square.center.must_equal Point[0,0]
	square.points.must_equal [Point[-5,-5], Point[5,-5], Point[5,5], Point[-5,5]]
    end

    describe "when constructed with a block" do
	before do
	    @sketch = Sketch.new do
		add_circle [1,2], 3
	    end
	end

	it "should execute the block" do
	    circle = @sketch.elements.last
	    circle.must_be_kind_of Geometry::Circle
	    circle.center.must_equal Point[1,2]
	    circle.radius.must_equal 3
	end
    end

    describe "object creation" do
	it "must create an Arc" do
	    arc = sketch.add_arc [1,2], 3, 0, 90
	    sketch.elements.last.must_be_kind_of Geometry::Arc
	    arc.center.must_equal Point[1,2]
	    arc.radius.must_equal 3
	    arc.start_angle.must_equal 0
	    arc.end_angle.must_equal 90
	end

	it "triangle" do
	    triangle = sketch.add_triangle [0,0], [1,0], [0,1]
	    sketch.elements.last.must_be_kind_of Geometry::Triangle
	end
    end
end
