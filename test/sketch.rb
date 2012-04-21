require 'test/unit'
require_relative 'test_unit_extensions'
require_relative '../lib/sketch'

class SketchTest < Test::Unit::TestCase
    must "create a Sketch object" do
	sketch = Sketch.new
	assert_kind_of(Sketch, sketch);
    end

    must "have an elements accessor" do
	sketch = Sketch.new
	assert(sketch.public_methods.include?(:elements))
    end

    must "have a circle command that makes a new circle from a center point and radius" do
	sketch = Sketch.new
	circle = sketch.circle [1,2], 3
	assert_kind_of(Geometry::Circle, circle)
	assert_equal(circle.center, [1,2])
	assert_equal(3, circle.radius)
    end

    must "have a point creation method" do
	sketch = Sketch.new
	point = sketch.point(5,6)
	assert_kind_of(Sketch::Point, point)
	assert_equal(5, point.x)
	assert_equal(6, point.y)
    end

    must "have a line creation method" do
	sketch = Sketch.new
	line = sketch.line([5,6], [7,8])
	assert_kind_of(Sketch::Line, line)
    end
end
