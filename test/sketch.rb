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

    it "should have a circle command that makes a new circle from a center point and radius" do
	circle = sketch.circle [1,2], 3
	circle.must_be_kind_of Geometry::Circle
	circle.center.must_equal Point[1,2]
	circle.radius.must_equal 3
    end

    it "should have a point creation method" do
	point = sketch.point(5,6)
	point.must_be_kind_of Sketch::Point
	point.x.must_equal 5
	point.y.must_equal 6
    end

    it "have a line creation method" do
	line = sketch.line([5,6], [7,8])
	line.must_be_kind_of Sketch::Line
    end

    it "have a rectangle creation method" do
	rectangle = sketch.rectangle 10, 20
	rectangle.must_be_kind_of Geometry::Rectangle
    end
end
