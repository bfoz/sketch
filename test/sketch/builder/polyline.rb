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
    end
end
