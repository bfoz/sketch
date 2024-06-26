require 'minitest/autorun'
require 'sketch'

describe Sketch do
    Size = Geometry::Size

    let(:sketch)    { Sketch.new }

    it "should create a Sketch object" do
	sketch.must_be_kind_of Sketch
    end

    it 'must be empty' do
	sketch.must_be_empty
    end

    it "should have a read only elements accessor" do
	sketch.must_respond_to :elements
	sketch.wont_respond_to :elements=
    end

    it "must have a push method that pushes an element" do
	sketch.push Rectangle.new size:[5, 5]
	sketch.elements.last.must_be_kind_of Rectangle
    end

    it "must push a sketch with a transformation" do
	sketch.push Sketch.new(), origin:[1,2]
	sketch.elements.last.must_be_kind_of Sketch
	sketch.elements.last.transformation.must_equal Geometry::Transformation.new(origin:[1,2])
    end

    describe "parameters" do
	it "must define custom parameters" do
	    Sketch.define_parameter(:a_parameter) { 42 }
	    Sketch.new.a_parameter.must_equal 42
	end

	it "must bequeath custom parameters to subclasses" do
	    Sketch.define_parameter(:a_parameter) { 42 }
	    Class.new(Sketch).new.must_respond_to(:a_parameter)
	end

	it "must not allow access to parameters defined on a subclass" do
	    Sketch.define_parameter(:a_parameter) { 42 }
	    Class.new(Sketch).define_parameter(:b_parameter) { 24 }
	    Sketch.new.wont_respond_to :b_parameter
	end
    end

    describe "when constructed with a block" do
	before do
	    @sketch = Sketch.new do
		push Geometry::Circle.new [1,2], 3
	    end
	end

	it "should execute the block" do
	    circle = @sketch.elements.last
	    circle.must_be_kind_of Geometry::Circle
	    circle.center.must_equal Point[1,2]
	    circle.radius.must_equal 3
	end
    end

    describe "object creation" do
    end

    describe "properties" do
	subject { Sketch.new { push Geometry::Circle.new [1,-2], 3; push Geometry::Circle.new([-1,2], 3) } }

	it "must have a bounds rectangle" do
	    subject.bounds.must_equal Rectangle.new(from:[-4,-5], to:[4,5])
	end

	it "must have an accessor for the first element" do
	    subject.first.must_be_instance_of(Geometry::Circle)
	end

	it "must have an accessor for the last element" do
	    subject.last.must_be_instance_of(Geometry::Circle)
	end

	it "must have a max property that returns the upper right point of the bounding rectangle" do
	    subject.max.must_equal Point[4,5]
	end

	it "must have a min property that returns the lower left point of the bounding rectangle" do
	    subject.min.must_equal Point[-4,-5]
	end

	it "must have a minmax property that returns the corners of the bounding rectangle" do
	    subject.minmax.must_equal [Point[-4,-5], Point[4,5]]
	end

	it "must have a size" do
	    subject.size.must_equal Size[8,10]
	    subject.size.must_be_instance_of(Size)
	end

	it 'must not be empty' do
	    subject.wont_be_empty
	end

	describe "when the Sketch is empty" do
	    subject { Sketch.new }

	    it "max must return nil" do
		subject.max.must_be_nil
	    end

	    it "min must return nil" do
		subject.min.must_be_nil
	    end

	    it "minmax must return an array of nils" do
		subject.minmax.each {|a| a.must_be_nil }
	    end
	end

	describe "when the Sketch is rotated" do
	    subject do
		s = Sketch.new { push Geometry::Rectangle.new center:[0, -1.5], size:[6.5, 50.5] }
		s.transformation = Geometry::Transformation.new(angle:Math::PI/2)
		s
	    end

	    it "must have a min property that returns the lower left point of the bounding rectangle" do
		subject.min.x.must_be_close_to(-23.75)
		subject.min.y.must_be_close_to(-3.25)
	    end
	end
    end

    describe "when the Sketch contains a group" do
	subject do
	    Sketch::Builder.new(Sketch.new).evaluate do
		translate [1,2] do
		    circle [1,-2], 3
		    circle([-1,2], 3)
		end
	    end
	end

	it "must have a max property" do
	    subject.max.must_equal Point[5,7]
	end

	it "must have a min property" do
	    subject.min.must_equal Point[-3,-3]
	end

	it "must have a minmax property" do
	    subject.minmax.must_equal [Point[-3,-3], Point[5,7]]
	end
    end

    it 'must move itself to the first quadrant' do
	sketch = Sketch.new
	sketch.push Geometry::Circle.new([0, 0], 3)

	sketch.minmax.must_equal [Point[-3, -3], Point[3, 3]]	# Sanity check
	sketch.first_quadrant!.minmax.must_equal [Point[0,0], Point[6,6]]
    end

    it 'must know if it is in the first quadrant' do
	sketch = Sketch.new
	sketch.push Geometry::Circle.new([0, 0], 3)
	sketch.first_quadrant?.must_equal false

	sketch = Sketch.new
	sketch.push Geometry::Circle.new([3, 3], 3)
	sketch.first_quadrant?.must_equal true
    end
end
