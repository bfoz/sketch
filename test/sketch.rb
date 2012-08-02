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
	square.points.must_equal [Point[-5,-5], Point[-5,5], Point[5,5], Point[5,-5]]
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
end
