require 'test/unit'
require_relative 'test_unit_extensions'
require_relative '../lib/point'

class PointTest < Test::Unit::TestCase
    must "create a Point object" do
	point = Sketch::Point.new 2, 1
	assert_equal(2, point.size)
	assert_equal(2, point.x)
	assert_equal(1, point.y)
    end
    must "create a Point object from an array" do
	point = Sketch::Point.new [3,4]
	assert_equal(2, point.size)
	assert_equal(3, point.x)
	assert_equal(4, point.y)
    end
    must "allow indexed element access" do
	point = Sketch::Point.new [5,6]
	assert_equal(2, point.size)
	assert_equal(5, point[0])
	assert_equal(6, point[1])
    end
end
