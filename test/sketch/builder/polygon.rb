require 'minitest/autorun'
require 'sketch/builder/polygon'

describe Sketch do
    subject { Sketch::Builder::Polygon.new }

    it "build a polygon with a block" do
	polygon = subject.evaluate do
	end
	assert_kind_of(Sketch::Polygon, polygon)
    end


    it 'must have a default starting point' do
	polygon = subject.evaluate do
	    up	    1
	    right	    1
	    down	    1
	end
	polygon.must_equal Geometry::Polygon.new [0,0], [0,1], [1,1], [1,0]
    end

    it 'must handle multiple repeats' do
	skip
	subject.evaluate do
	    start_at	[0,0]
	    size = Size[10, 10]
	    tooth_size = Size[size.x/5, size.y/5]
	    (0...size.y).step(tooth_size.y) do |y|
		move_y  tooth_size.y/2 - (y <= 0 ? 1 : 0)
		move_x  1
		move_y  tooth_size.y/2
		move_x(-1)
	    end
	    repeat step:[2, 0], count:5 do |step|
		forward step/2
		right   1
		forward step/2
	    end
	    repeat step:[0, -2], count:5 do |step|
		forward step/2
		right   1
		forward step/2
	    end
	end.must_equal []
    end
end
