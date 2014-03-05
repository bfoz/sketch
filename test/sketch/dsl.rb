require 'minitest/autorun'
require 'sketch/dsl'

class Fake
    attr_accessor :elements

    include Sketch::DSL

    def initialize
	@elements = []
    end

    def push(*args)
	elements.push args.first
    end

    def build_layout(*args, &block)
	Sketch::Layout.new *args, &block
    end

    def build_polygon(&block)
    end
end

describe Sketch::DSL do
    Point = Geometry::Point

    subject { Fake.new }

    it "must have a first command that returns the first element" do
	point = Geometry::Point[1,2]
	subject.elements.push point
	subject.first.must_be_same_as point
    end

    it "must have a last command that returns the last element" do
	point = Point[1,2]
	subject.elements.push Point[3,4]
	subject.elements.push point
	subject.last.must_be_same_as point
    end

    it 'must have an arc command' do
	subject.arc center:[1,2], radius:3, start:0, end:90
	subject.last.must_be_kind_of Geometry::Arc
	subject.last.center.must_equal Point[1,2]
	subject.last.radius.must_equal 3
	subject.last.start_angle.must_equal 0
	subject.last.end_angle.must_equal 90
    end

    it 'must have a circle command' do
	subject.circle center:[1,2], diameter:5
	subject.last.must_be_kind_of Geometry::Circle
	subject.last.center.must_equal Point[1,2]
	subject.last.diameter.must_equal 5
    end

    it "must have a hexagon command" do
	subject.hexagon center:[1,2], radius:5
	subject.last.must_be_instance_of Geometry::RegularPolygon
	subject.last.center.must_equal Point[1,2]
	subject.last.edge_count.must_equal 6
	subject.last.radius.must_equal 5
    end

    it 'must have a layout command' do
	subject.layout :horizontal do; end
    end

    it 'must have a layout command that checks the alignment argument' do
	-> { subject.layout :horizontal, alignment: :left do; end }.must_raise ArgumentError
    end

    it 'must have a shortcut for horizontal layouts' do
	subject.horizontal do; end
	subject.last.must_be_kind_of Sketch::Layout
	subject.last.direction.must_equal :horizontal
    end

    it 'must have a shortcut for vertical layouts' do
	subject.vertical do; end
	subject.last.must_be_kind_of Sketch::Layout
	subject.last.direction.must_equal :vertical
    end

    it 'must have a line command' do
	subject.line [5,6], [7,8]
	subject.last.must_be_kind_of Geometry::Line
    end

    it 'must have a path command that takes a list of points' do
	subject.path [1,2], [2,3]
	subject.last.must_be_kind_of Geometry::Path
	subject.last.elements.count.must_equal 1
    end

    it 'must have a path command that takes a block' do
	subject.path do
	    start_at    [0,0]
	    move_to	[1,1]
	end
	subject.last.must_be_kind_of Geometry::Path
	subject.last.elements.count.must_equal 1
    end

    it 'must have a polygon command that takes a list of points' do
	polygon = subject.polygon [0,0], [1,0], [1,1], [0,1]
	polygon.must_be_kind_of Sketch::Polygon
	subject.last.vertices.size.must_equal 4
    end

    it 'must have a polygon command that takes a block' do
	subject.polygon do
	    start_at    [0,0]
	    move_to	    [1,0]
	    move_to	    [1,1]
	    move_to	    [0,1]
	end
    end

    it 'must have a rectangle command' do
	subject.rectangle size:[10,20]
	subject.last.must_be_kind_of Geometry::Rectangle
	subject.last.points.must_equal [Point[0,0], Point[0,20], Point[10,20], Point[10,0]]
    end

    it 'must have a square command' do
	subject.square 10
	subject.last.must_be_kind_of Geometry::Square
	subject.last.height.must_equal 10
	subject.last.width.must_equal 10
	subject.last.center.must_equal Point[0,0]
	subject.last.points.must_equal [Point[-5,-5], Point[5,-5], Point[5,5], Point[-5,5]]
    end

    it 'must have a triangle command' do
	subject.triangle [0,0], [1,0], [0,1]
	subject.last.must_be_kind_of Geometry::Triangle
    end
end
