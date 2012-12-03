require 'minitest/autorun'
require 'geometry'
require 'sketch/builder'

describe Sketch::Builder do
    Builder = Sketch::Builder
    Rectangle = Geometry::Rectangle

    describe "when initialized without a block" do
	let(:builder) { Builder.new }

	it "should create a new Sketch when initialized without a Sketch" do
	    builder.sketch.must_be_instance_of(Sketch)
	end

	it "should use the given sketch when initialized with an existing Sketch" do
	    sketch = Sketch.new
	    Builder.new(sketch).sketch.must_be_same_as(sketch)
 	end

	it "must have a push method that pushes elements" do
	    builder.push Rectangle.new 5, 5
	    builder.sketch.elements.last.must_be_kind_of Rectangle
	end

	describe "when evaluating a block" do
	    describe "with simple geometry" do
		before do
		    builder.evaluate do
			square 5
		    end
		end

		it "should create the commanded elements" do
		    builder.sketch.elements.last.must_be_kind_of Geometry::Square
		end

		it "triangle" do
		    builder.evaluate { triangle [0,0], [1,0], [0,1] }
		end
	    end

	    describe "that defines a parameter" do
		before do
		    builder.evaluate do
			let(:parameterA) { 42 }
			circle [1,2], parameterA
		    end
		end

		it "must define the parameter" do
		    builder.sketch.parameterA.must_equal 42
		end

		it "must use the parameter" do
		    builder.sketch.elements.last.must_be_instance_of Geometry::Circle
		    builder.sketch.elements.last.radius.must_equal 42
		end
	    end

	    describe "with a path block" do
		before do
		    builder.evaluate do
			path do
			end
		    end
		end

		it "must add a Path object to the Sketch" do
		    builder.sketch.elements.last.must_be_instance_of Geometry::Path
		end
	    end

	end
    end

    describe "when initialized with a block " do
	let(:builder) {
	    Builder.new do
		square 5
	    end
	}

	it "must evaluate the block" do
	    builder.sketch.elements.last.must_be_kind_of Geometry::Square
 	end
    end
end