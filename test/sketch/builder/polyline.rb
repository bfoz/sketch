require 'minitest/autorun'
require 'sketch/builder/polyline'

describe Sketch::Builder::Polyline do
    Polyline = Sketch::Polyline

    let(:builder) { Sketch::Builder::Polyline.new }

    it "must build a Polyline from a block" do
	builder.evaluate {}.must_be_kind_of Polyline
    end
end
