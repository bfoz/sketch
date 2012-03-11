require 'test/unit'
require_relative 'test_unit_extensions'
require_relative '../lib/point'

class PointTest < Test::Unit::TestCase
    must "create a Point object" do
	point = Sketch::Point[2, 1]
	assert_kind_of(Sketch::Point, point)
    end
    must "create a Point object using list syntax" do
	point = Sketch::Point[2,1]
	assert_equal(2, point.size)
	assert_equal(2, point.x)
	assert_equal(1, point.y)
    end
    must "create a Point object from an array" do
	point = Sketch::Point[3,4]
	assert_equal(2, point.size)
	assert_equal(3, point.x)
	assert_equal(4, point.y)
    end
    must "create a Point object from a Vector" do
	point = Sketch::Point[Vector[3,4]]
	assert_equal(2, point.size)
	assert_equal(3, point.x)
	assert_equal(4, point.y)
    end
    must "create a Point object from a Vector using list syntax" do
	point = Sketch::Point[Vector[3,4]]
	assert_equal(2, point.size)
	assert_equal(3, point.x)
	assert_equal(4, point.y)
    end
    must "allow indexed element access" do
	point = Sketch::Point[5,6]
	assert_equal(2, point.size)
	assert_equal(5, point[0])
	assert_equal(6, point[1])
    end
end
