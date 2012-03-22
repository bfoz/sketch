require 'test/unit'
require_relative '../test_unit_extensions'
require_relative '../../lib/sketch'

class SketchPolygonTest < Test::Unit::TestCase
    must "add a polygon" do
	sketch = Sketch.new
	polygon = sketch.polygon [0,0], [1,0], [1,1], [0,1]
	assert_kind_of(Sketch::Polygon, polygon)
	assert_equal(4, polygon.vertices.size)
    end

    must "add a polygon using a block" do
	sketch = Sketch.new
	polygon = sketch.polygon do
		vertex [0,0]
		point [1,0]
		edge [1,1], [0,1]
	end
	assert_kind_of(Sketch::Polygon, polygon)
	assert_equal(1, sketch.elements.size)
	assert_equal(4, polygon.vertices.size)
    end
end
