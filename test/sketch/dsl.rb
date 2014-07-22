require 'minitest/autorun'
require 'sketch/dsl'

class SketchFake
    attr_accessor :elements

    include Sketch::DSL

    def initialize
	@elements = []
    end

    def push(*args)
	elements.push args.first
    end

    def build_group(*args, &block)
	args
    end

    def build_layout(*args, &block)
	Sketch::Layout.new *args, &block
    end

    def build_polygon(*args, &block)
	args
    end
end

describe Sketch::DSL do
    Point = Geometry::Point

    subject { SketchFake.new }

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

    it 'must have an annulus command' do
	subject.annulus center:[1,2], inner_radius:5, radius:10
	subject.last.must_be_kind_of Geometry::Annulus
	subject.last.center.must_equal Point[1,2]
	subject.last.inner_radius.must_equal 5
	subject.last.radius.must_equal 10
    end

    it 'must have a ring command that is an alias of the annulus command' do
	subject.ring center:[1,2], inner_radius:5, radius:10
	subject.last.must_be_kind_of Geometry::Annulus
	subject.last.center.must_equal Point[1,2]
	subject.last.inner_radius.must_equal 5
	subject.last.radius.must_equal 10
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

    describe 'Polygon' do
	it 'must accept a list of points' do
	    polygon = subject.polygon [0,0], [1,0], [1,1], [0,1]
	    polygon.must_be_kind_of Sketch::Polygon
	    subject.last.vertices.size.must_equal 4
	end

	it 'must accept a block' do
	    subject.polygon(){}
	    subject.elements.last.must_equal [{}]
	end

	it 'must accept an origin and a block' do
	    subject.polygon(origin:[1,2]) {}
	    subject.elements.last.must_equal [{origin:[1,2]}]
	end
    end

    it 'must have a square command' do
	subject.square 10
	subject.last.must_be_kind_of Geometry::Square
	subject.last.height.must_equal 10
	subject.last.width.must_equal 10
	subject.last.center.must_equal Point[0,0]
	subject.last.points.must_equal [Point[-5,-5], Point[5,-5], Point[5,5], Point[-5,5]]
    end

    it 'must create a Square from an origin and a size' do
	subject.square origin:[1,2], size:3
	subject.last.must_be_kind_of Geometry::Square
	subject.last.height.must_equal 3
	subject.last.width.must_equal 3
	subject.last.origin.must_equal Point[1,2]
    end

    it 'must have a triangle command' do
	subject.triangle [0,0], [1,0], [0,1]
	subject.last.must_be_kind_of Geometry::Triangle
    end

    describe 'rectangle' do
	it 'must accept a size argument' do
	    subject.rectangle size:[10,20]
	    subject.last.must_be_kind_of Geometry::Rectangle
	    subject.last.points.must_equal [Point[0,0], Point[0,20], Point[10,20], Point[10,0]]
	end

	it 'must require a size argument' do
	    ->{ subject.rectangle }.must_raise ArgumentError
	end

	it 'must accept a center argument' do
	    skip "Rational comparison is broken"
	    subject.rectangle center:[0,0], size:[10,20]
	    subject.last.must_be_kind_of Geometry::Rectangle
	    subject.last.points.must_equal [Point[-5, -10], Point[-5,10], Point[5,10], Point[5,-10]]
	end

	it 'must accept an origin argument' do
	    subject.rectangle origin:[1,2], size:[10,20]
	    subject.last.must_be_kind_of Geometry::Rectangle
	    subject.last.points.must_equal [Point[1,2], Point[1,22], Point[11,22], Point[11,2]]
	end

	it 'must accept an argument named x' do
	    subject.rectangle x:1, size:[10,20]
	    subject.last.must_be_kind_of Geometry::Rectangle
	    subject.last.points.must_equal [Point[1,0], Point[1,20], Point[11,20], Point[11,0]]
	end

	it 'must accept an argument named y' do
	    subject.rectangle y:1, size:[10,20]
	    subject.last.must_be_kind_of Geometry::Rectangle
	    subject.last.points.must_equal [Point[0,1], Point[0,21], Point[10,21], Point[10,1]]
	end

	it 'must accept arguments named x and y' do
	    subject.rectangle x:1, y:2, size:[10,20]
	    subject.last.must_be_kind_of Geometry::Rectangle
	    subject.last.points.must_equal [Point[1,2], Point[1,22], Point[11,22], Point[11,2]]
	end

	it 'must start on the left' do
	    subject.rectangle left:1, size:[10,20]
	    subject.last.must_be_kind_of Geometry::Rectangle
	    subject.last.points.must_equal [Point[1,0], Point[1,20], Point[11,20], Point[11,0]]
	end

	it 'must start at the bottom' do
	    subject.rectangle bottom:1, size:[10,20]
	    subject.last.must_be_kind_of Geometry::Rectangle
	    subject.last.points.must_equal [Point[0,1], Point[0,21], Point[10,21], Point[10,1]]
	end

	it 'must stop on the right' do
	    subject.rectangle right:1, size:[10,20]
	    subject.last.must_be_kind_of Geometry::Rectangle
	    subject.last.points.must_equal [Point[-9,0], Point[-9,20], Point[1,20], Point[1,0]]
	end

	it 'must stop at the top' do
	    subject.rectangle top:1, size:[10,20]
	    subject.last.must_be_kind_of Geometry::Rectangle
	    subject.last.points.must_equal [Point[0,-19], Point[0,1], Point[10,1], Point[10,-19]]
	end
    end

    describe 'when repeating' do
	it 'must ignore spacing when count is 1' do
	    subject.repeat step:5, count:1 do
		square size:1
	    end
	    subject.elements.size.must_equal 1
	    subject.elements.must_equal [[{:origin=>Point[0, 0]}]]
	end

	it 'must repeat along the X axis centered on the origin' do
	    subject.repeat step:5, count:2 do
		square size:1
	    end
	    subject.elements.size.must_equal 2
	    subject.elements.must_equal [[{:origin=>Point[-2.5, 0]}],
					 [{:origin=>Point[2.5, 0]}]]
	end

	it 'must repeat along the Y axis centered on the origin' do
	    subject.repeat step:[0,5], count:2 do
		square size:1
	    end
	    subject.elements.size.must_equal 2
	    subject.elements.must_equal [[{:origin=>Point[0, -2.5]}],
					 [{:origin=>Point[0, 2.5]}]]
	end

	it 'must create a grid centered on the origin when count is a number' do
	    subject.repeat count:2, step:[5,5] do
		square size:1
	    end
	    subject.elements.size.must_equal 4
	    subject.elements.must_equal [[{:origin=>Point[-2.5, -2.5]}],
					 [{:origin=>Point[ 2.5, -2.5]}],
					 [{:origin=>Point[-2.5,  2.5]}],
					 [{:origin=>Point[ 2.5,  2.5]}]]
	end

	it 'must accept a count for each axis' do
	    subject.repeat count:[3,2], step:[5,5] do
		square size:1
	    end
	    subject.elements.size.must_equal 6
	    subject.elements.must_equal [[{:origin=>Point[-5, -2.5]}],
					 [{:origin=>Point[ 0, -2.5]}],
					 [{:origin=>Point[ 5, -2.5]}],
					 [{:origin=>Point[ -5, 2.5]}],
					 [{:origin=>Point[  0, 2.5]}],
					 [{:origin=>Point[  5, 2.5]}]]
	end

	it 'must have an origin' do
	    subject.repeat origin:[1,2], count:2, step:[5,5] do
		square size:1
	    end
	    subject.elements.size.must_equal 4
	    subject.elements.must_equal [[{:origin=>Point[1-2.5, 2-2.5]}],
					 [{:origin=>Point[1+2.5, 2-2.5]}],
					 [{:origin=>Point[1-2.5, 2+2.5]}],
					 [{:origin=>Point[1+2.5, 2+2.5]}]]
	end

	it 'must return an enumerator when no block is given' do
	    subject.repeat(origin:[1,2], count:2, step:[5,5]).must_be_kind_of Enumerator
	    subject.repeat(origin:[1,2], count:2, step:[5,5]).to_a.must_equal [Point[1-2.5, 2-2.5],
									       Point[1+2.5, 2-2.5],
									       Point[1-2.5, 2+2.5],
									       Point[1+2.5, 2+2.5]]
	end
    end

    describe 'when translating a block' do
	it 'must default to no translation if no arguments are given' do
	    subject.translate() {}
	    subject.elements.must_equal [[{:origin=>Point[0,0]}]]
	end

	it 'must accept 2 bare Point components' do
	    subject.translate(1, 2) {}
	    subject.elements.must_equal [[{:origin=>Point[1,2]}]]
	end

	it 'must accept an x-translation value' do
	    subject.translate(1) {}
	    subject.elements.must_equal [[{:origin=>Point[1,0]}]]
	end

	it 'must accept a Point argument' do
	    subject.translate Point[1,2] {}
	    subject.elements.must_equal [[{:origin=>Point[1,2]}]]
	end

	it 'must accept a short Point argument' do
	    subject.translate Point[1] {}
	    subject.elements.must_equal [[{:origin=>Point[1,0]}]]
	end

	it 'must accept x and y keyword arguments' do
	    subject.translate(x:1, y:2) {}
	    subject.elements.must_equal [[{:origin=>Point[1,2]}]]
	end

	it 'must accept an x keyword argument' do
	    subject.translate(x:1) {}
	    subject.elements.must_equal [[{:origin=>Point[1,0]}]]
	end

	it 'must accept a y keyword argument' do
	    subject.translate(y:2) {}
	    subject.elements.must_equal [[{:origin=>Point[0,2]}]]
	end
    end
end
