require 'minitest/autorun'
require 'sketch/builder/polygon'

describe Sketch do
    let(:builder)   { Sketch::Builder::Polygon.new }

    it "build a polygon with a block" do
	polygon = builder.evaluate do
	end
	assert_kind_of(Sketch::Polygon, polygon)
    end
end
