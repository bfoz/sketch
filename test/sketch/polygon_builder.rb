require 'minitest/autorun'
require 'sketch/polygon'

describe Sketch do
    let(:builder)   { Sketch::PolygonBuilder.new }

    it "build a polygon with a block" do
	polygon = builder.evaluate do
	end
	assert_kind_of(Sketch::Polygon, polygon)
    end

    it "have a start command that makes a new point" do
	polygon = builder.evaluate do
	    start_at	[1,1]
	end
	assert_equal(1, builder.elements.length)
	assert_kind_of(Point, builder.elements[0])
    end

    it "have a move_to command that makes a new vertex" do
	polygon = builder.evaluate do
	    start_at	[0,0]
	    move_to	[2,1]
	end
	assert_equal(2, builder.elements.length)
	builder.first.must_equal Point[0,0]
	assert_equal(Point[2,1], builder.elements[1])
    end

    it "have a move_x command that makes a new vertex above the previous one" do
	polygon = builder.evaluate do
	    start_at	[0,0]
	    move_x	2
	end
	assert_equal(2, builder.elements.length)
	assert_kind_of(Point, builder.elements[0])
	assert_kind_of(Point, builder.elements[1])
	assert_equal(Point[2,0], builder.elements[1])
    end

    it "have a move_y command that makes a new vertex above the previous one" do
	polygon = builder.evaluate do
	    start_at	[0,0]
	    move_y	2
	end
	assert_equal(2, builder.elements.length)
	assert_kind_of(Point, builder.elements[0])
	assert_kind_of(Point, builder.elements[1])
	assert_equal(Point[0,2], builder.elements[1])
    end

    it "have a vertical_to command that makes a new vertex above the previous one" do
	polygon = builder.evaluate do
	    start_at		[0,0]
	    vertical_to	2
	end
	assert_equal(2, builder.elements.length)
	assert_kind_of(Point, builder.elements[0])
	assert_kind_of(Point, builder.elements[1])
	assert_equal(Point[0,2], builder.elements[1])
    end

    it "have a horizontal_to command that makes a new vertex with the same y-coordinate as the previous one" do
	polygon = builder.evaluate do
	    start_at		[0,0]
	    horizontal_to	2
	end
	assert_equal(2, builder.elements.length)
	builder.first.must_equal Point[0,0]
	assert_equal(Point[2,0], builder.elements[1])
    end

    describe "relative movement" do
	before do
	    builder.start_at [1,2]
	end

	it "must move over when told to move_x" do
	    builder.move_x 3
	    builder.elements.length.must_equal 2
	    builder.elements.last.must_equal Point[4,2]
	end

	it "must move up when told to move_y" do
	    builder.move_y 4
	    builder.elements.length.must_equal 2
	    builder.elements.last.must_equal Point[1,6]
	end

	it "must move up" do
	    builder.up 3
	    builder.elements.length.must_equal 2
	    builder.elements.last.must_equal Point[1,5]
	end

	it "must move down" do
	    builder.down 3
	    builder.elements.length.must_equal 2
	    builder.elements.last.must_equal Point[1,-1]
	end

	it "must move left" do
	    builder.left 3
	    builder.elements.length.must_equal 2
	    builder.elements.last.must_equal Point[-2,2]
	end

	it "must move right" do
	    builder.right 3
	    builder.elements.length.must_equal 2
	    builder.elements.last.must_equal Point[4,2]
	end
    end

end
