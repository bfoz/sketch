require 'minitest/autorun'
require 'sketch/builder/polyline'

describe Sketch::Builder::Polyline do
    Polyline = Sketch::Polyline

    let(:builder) { Sketch::Builder::Polyline.new }

    it "must build a Polyline from a block" do
	builder.evaluate {}.must_be_kind_of Polyline
    end

    describe 'when initialized with an origin' do
	subject { Sketch::Builder::Polyline.new(origin:[1,2]) }

	it 'must evaluate a block argument' do
	    polygon = subject.evaluate do
		start_at    [2,3]
		up	    1
		right	    1
		down	    1
	    end
	    polygon.must_equal Geometry::Polygon.new [3,5], [3,6], [4,6], [4,5]
	end

	it 'must evaluate a block argument with orthagonal-destination moves' do
	    polygon = subject.evaluate do
		up_to	    1
		right_to    1
		down_to	    0
	    end
	    polygon.must_equal Geometry::Polygon.new [1,2], [1,3], [2,3], [2,2]
	end
    end

    it 'must have a default starting point' do
	polyline = builder.evaluate do
	    up	    1
	    right	    1
	    down	    1
	end
	polyline.must_equal Geometry::Polyline.new [0,0], [0,1], [1,1], [1,0]
    end
end
