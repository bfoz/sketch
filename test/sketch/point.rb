require 'minitest/autorun'
require 'sketch/point'

describe Sketch::Point do
    it "create a Point object" do
	point = Sketch::Point[2, 1]
	assert_kind_of(Sketch::Point, point)
    end

    it "create a Point object using list syntax" do
	point = Sketch::Point[2,1]
	assert_equal(2, point.size)
	assert_equal(2, point.x)
	assert_equal(1, point.y)
    end

    it "create a Point object from an array" do
	point = Sketch::Point[3,4]
	assert_equal(2, point.size)
	assert_equal(3, point.x)
	assert_equal(4, point.y)
    end

    it "create a Point object from a Vector" do
	point = Sketch::Point[Vector[3,4]]
	assert_equal(2, point.size)
	assert_equal(3, point.x)
	assert_equal(4, point.y)
    end

    it "create a Point object from a Vector using list syntax" do
	point = Sketch::Point[Vector[3,4]]
	assert_equal(2, point.size)
	assert_equal(3, point.x)
	assert_equal(4, point.y)
    end

    it "allow indexed element access" do
	point = Sketch::Point[5,6]
	assert_equal(2, point.size)
	assert_equal(5, point[0])
	assert_equal(6, point[1])
    end
end
