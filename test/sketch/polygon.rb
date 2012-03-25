require 'test/unit'
require_relative '../test_unit_extensions'
require_relative '../../lib/sketch'

class SketchPolygonTest < Test::Unit::TestCase
    Point = Geometry::Point

    def setup
	@sketch = Sketch.new
    end

    must "add a polygon" do
	polygon = @sketch.polygon [0,0], [1,0], [1,1], [0,1]
	assert_kind_of(Sketch::Polygon, polygon)
	assert_equal(4, polygon.vertices.size)
    end

    must "add a polygon using a block" do
	polygon = @sketch.polygon do
	    vertex [0,0]
	    point [1,0]
	    edge [1,1], [0,1]
	end
	assert_kind_of(Sketch::Polygon, polygon)
	assert_equal(1, @sketch.elements.size)
	assert_equal(4, polygon.vertices.size)
    end

    must "make a square polygon using turtle-like commands" do
	polygon = @sketch.polygon do
	    start_at [0,0]
	    move_to [1,0]
	    turn_left 90
	    move 1
	    turn_left 90
	    forward 1
	end
	assert_kind_of(Sketch::Polygon, polygon)
	assert_equal(1, @sketch.elements.size)
	assert_equal(4, polygon.vertices.size)
	assert_equal(Point[0,0], polygon.vertices[0])
	assert_equal(Point[1,0], polygon.vertices[1])
	assert_equal(Point[1,1], polygon.vertices[2])
#	assert_equal(Point[0,1], polygon.vertices[3])
    end

    must "make another square polygon using turtle-like commands" do
    	polygon = @sketch.polygon do
	    start_at [0,0]
	    move [1,0]
	    move [0,1]
	    move [-1,0]
	end
	assert_kind_of(Sketch::Polygon, polygon)
	assert_equal(1, @sketch.elements.size)
	assert_equal(4, polygon.vertices.size)
	assert_equal(Point[0,0], polygon.vertices[0])
	assert_equal(Point[1,0], polygon.vertices[1])
	assert_equal(Point[1,1], polygon.vertices[2])
	assert_equal(Point[0,1], polygon.vertices[3])
    end
end
