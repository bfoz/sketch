require 'test/unit'
require_relative '../test_unit_extensions'
require_relative '../../lib/sketch/polygon'

class SketchPolygonBuilderTest < Test::Unit::TestCase
    Point = Geometry::Point

    def setup
	@builder = Sketch::PolygonBuilder.new
    end

    must "build a polygon with a block" do
	polygon = @builder.evaluate do
	end
	assert_kind_of(Sketch::Polygon, polygon)
    end

    must "have a start command that makes a new point" do
	polygon = @builder.evaluate do
	    start_at	[1,1]
	end
	assert_equal(1, @builder.elements.length)
	assert_kind_of(Sketch::Point, @builder.elements[0])
    end

    must "have a vertex command that makes a new point" do
	polygon = @builder.evaluate do
	    vertex	[0,0]
	end
	assert_equal(1, @builder.elements.length)
	assert_kind_of(Sketch::Point, @builder.elements[0])
    end

    must "have a move command that makes a new vertex" do
	polygon = @builder.evaluate do
	    start_at	[0,0]
	    move	[1,1]
	end
	assert_equal(2, @builder.elements.length)
	assert_kind_of(Sketch::Point, @builder.elements[0])
	assert_kind_of(Sketch::Point, @builder.elements[1])
	assert_equal(Point[1,1], @builder.elements[1])
    end

    must "have a move_to command that makes a new vertex" do
	polygon = @builder.evaluate do
	    start_at	[0,0]
	    move_to	[2,1]
	end
	assert_equal(2, @builder.elements.length)
	assert_kind_of(Sketch::Point, @builder.elements[0])
	assert_kind_of(Sketch::Point, @builder.elements[1])
	assert_equal(Point[2,1], @builder.elements[1])
    end

    must "have a move_x command that makes a new vertex above the previous one" do
	polygon = @builder.evaluate do
	    start_at	[0,0]
	    move_x	2
	end
	assert_equal(2, @builder.elements.length)
	assert_kind_of(Sketch::Point, @builder.elements[0])
	assert_kind_of(Sketch::Point, @builder.elements[1])
	assert_equal(Point[2,0], @builder.elements[1])
    end

    must "have a move_y command that makes a new vertex above the previous one" do
	polygon = @builder.evaluate do
	    start_at	[0,0]
	    move_y	2
	end
	assert_equal(2, @builder.elements.length)
	assert_kind_of(Sketch::Point, @builder.elements[0])
	assert_kind_of(Sketch::Point, @builder.elements[1])
	assert_equal(Point[0,2], @builder.elements[1])
    end

    must "have a move_vertical_to command that makes a new vertex above the previous one" do
	polygon = @builder.evaluate do
	    start_at		[0,0]
	    move_vertical_to	2
	end
	assert_equal(2, @builder.elements.length)
	assert_kind_of(Sketch::Point, @builder.elements[0])
	assert_kind_of(Sketch::Point, @builder.elements[1])
	assert_equal(Point[0,2], @builder.elements[1])
    end

    must "have a move_horizontal_to command that makes a new vertex with the same y-coordinate as the previous one" do
	polygon = @builder.evaluate do
	    start_at		[0,0]
	    move_horizontal_to	2
	end
	assert_equal(2, @builder.elements.length)
	assert_kind_of(Sketch::Point, @builder.elements[0])
	assert_kind_of(Sketch::Point, @builder.elements[1])
	assert_equal(Point[2,0], @builder.elements[1])
    end
end
