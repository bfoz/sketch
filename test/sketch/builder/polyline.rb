require 'minitest/autorun'
require 'sketch/builder/polyline'

describe Sketch::PolylineBuilder do
    Polyline = Sketch::Polyline

    let(:builder) { Sketch::PolylineBuilder.new }

    it "must build a Polyline from a block" do
	builder.evaluate {}.must_be_kind_of Polyline
    end

    describe "when starting at a Point" do
	before do
	    builder.start_at [1,2]
	end

	it "must add a Point" do
	    builder.elements.length.must_equal 1
	    builder.elements.last.must_be_kind_of Point
	end

	it "must refuse to start again" do
	    -> { builder.start_at [2,3] }.must_raise Geometry::DSL::Polyline::BuildError
	end

	it "must move when told to move_to" do
	    builder.move_to [3,4]
	    builder.elements.length.must_equal 2
	    builder.elements.last.must_equal Point[3,4]
	end

	it "must close with a Line" do
	    builder.move_to [3,4]
	    builder.close
	    builder.elements.first.must_equal builder.elements.last
	    builder.closed?.must_equal true
	end

	describe "relative movement" do
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
end
