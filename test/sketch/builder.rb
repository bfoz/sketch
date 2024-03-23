require 'minitest/autorun'
require 'geometry'
require 'sketch/builder'

describe Sketch::Builder do
    Builder = Sketch::Builder
    Rectangle = Geometry::Rectangle

    subject { Builder.new }

    it 'must implement the Sketch DSL' do
	subject.must_be_kind_of Sketch::DSL
    end

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
	    builder.push Rectangle.new size:[5, 5]
	    builder.sketch.elements.last.must_be_kind_of Rectangle
	end

	describe 'when defining an attribute' do
	    let(:sketch) { builder.evaluate { attribute :attribute0 } }

	    it 'must define the attribute' do
		sketch.must_be :respond_to?, :attribute0
		sketch.must_be :respond_to?, :attribute0=
	    end

	    it 'must have working accessors' do
		sketch.attribute0 = 42
		sketch.attribute0.must_equal 42
	    end

	    it 'must make the attribute available while evaluating a block' do
		builder.evaluate do
		    attribute :attribute1, 5
		    attribute1.must_equal 5
		    attribute1 = 7
		    attribute1.must_equal 7
		end
	    end
	end

	describe 'when defining an attribute with a default value' do
	    let(:sketch) { builder.evaluate { attribute :attribute0, 42 } }

	    it 'must have the default value' do
		sketch.attribute0.must_equal 42
	    end

	    it 'must not have the default value after setting to nil' do
		sketch.attribute0 = nil
		sketch.attribute0.wont_equal 42
	    end
	end

	describe 'when defining a read only attribute with a default value' do
	    let(:sketch) { builder.evaluate { attr_reader attribute0:42 } }

	    it 'must have the default value' do
		sketch.attribute0.must_equal 42
	    end
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

    describe "when adding a group" do
	describe "without a block" do
	    before do
		subject.group origin:[1,2,3]
	    end

	    it "must have a group element" do
		subject.sketch.elements.first.must_be_kind_of Sketch::Group
		subject.sketch.elements.first.translation.must_equal Point[1,2,3]
	    end
	end

	describe "with a block" do
	    before do
		subject.group origin:[1,2,3] do circle diameter:1 end
	    end

	    it "must have a group element" do
		subject.sketch.elements.first.must_be_kind_of Sketch::Group
	    end

	    it "must have the correct property values" do
		subject.sketch.elements.first.translation.must_equal Point[1,2,3]
	    end
	end
    end

    describe 'when adding a layout' do
	describe 'when spacing is not given' do
	    it 'must do a horizontal layout' do
		subject.layout direction: :horizontal do
		    rectangle from:[0,0], to:[5,5]
		    rectangle from:[0,0], to:[6,6]
		end

		layout = subject.first
		layout.must_be_instance_of Sketch::Layout

		layout.first.must_be_kind_of Geometry::Rectangle
		layout.last.must_be_kind_of Sketch::Group
		layout.last.translation.must_equal Point[5,0]
	    end

	    it 'must do a vertical layout' do
		subject.layout direction: :vertical do
		    rectangle from:[0,0], to:[5,5]
		    rectangle from:[0,0], to:[6,6]
		end

		layout = subject.first
		layout.must_be_instance_of Sketch::Layout

		layout.first.must_be_kind_of Geometry::Rectangle
		layout.last.must_be_kind_of Sketch::Group
		layout.last.translation.must_equal Point[0,5]
	    end
	end

	describe 'when spacing is non-zero' do
	    it 'must do a horizontal layout' do
		subject.layout direction: :horizontal, spacing:1 do
		    rectangle from:[0,0], to:[5,5]
		    rectangle from:[0,0], to:[6,6]
		end

		layout = subject.first
		layout.must_be_instance_of Sketch::Layout

		layout.first.must_be_kind_of Geometry::Rectangle
		layout.last.must_be_kind_of Sketch::Group
		layout.last.translation.must_equal Point[6,0]
	    end

	    it 'must do a vertical layout' do
		subject.layout direction: :vertical, spacing:1 do
		    rectangle from:[0,0], to:[5,5]
		    rectangle from:[0,0], to:[6,6]
		end

		layout = subject.first
		layout.must_be_instance_of Sketch::Layout

		layout.first.must_be_kind_of Geometry::Rectangle
		layout.last.must_be_kind_of Sketch::Group
		layout.last.translation.must_equal Point[0,6]
	    end
	end
    end

    describe "when adding a translation" do
	before do
	    subject.translate [1,2] do circle diameter:1 end
	end

	it "must have a group element" do
	    subject.sketch.elements.first.must_be_kind_of Sketch::Group
	end

	it "must have the correct property values" do
	    subject.sketch.elements.first.translation.must_equal Point[1,2]
	end

	it 'must reject higher dimensions' do
	    -> { subject.translate [1,2,3] }.must_raise ArgumentError
	end
    end

    describe "when adding a nested translation" do
	before do
	    subject.translate [1,2] do
		translate [3,4] do circle diameter:2 end
	    end
	end

	it "must have a group element" do
	    subject.sketch.elements.first.must_be_kind_of Sketch::Group
	end

	it "must have the correct property values" do
	    subject.sketch.elements.first.translation.must_equal Point[1,2]
	end

	it "must have a sub-group element" do
	    outer_group = subject.sketch.elements.first
	    outer_group.elements.first.must_be_kind_of Sketch::Group
	end

	it "must set the sub-group properties" do
	    outer_group = subject.sketch.elements.first
	    outer_group.elements.first.translation.must_equal Point[3,4]
	end
    end

    describe 'build_polygon' do
	before do
	    subject.singleton_class.send(:public, :build_polygon)
	end

	it 'must build a polygon from a block' do
	    subject.build_polygon(){}.must_be_kind_of Geometry::Polygon
	end

	it 'must accept an origin argument' do
	    polygon = subject.build_polygon(origin:[1,2]) do
		start_at    [2,3]
		up	    1
		right	    1
		down	    1
	    end
	    polygon.must_equal Geometry::Polygon.new [3,5], [3,6], [4,6], [4,5]
	end
    end

    describe 'build_polyline' do
	before do
	    subject.singleton_class.send(:public, :build_polyline)
	end

	it 'must build a polygon from a block' do
	    subject.build_polyline(){}.must_be_kind_of Geometry::Polyline
	end

	it 'must accept an origin argument' do
	    polyline = subject.build_polyline(origin:[1,2]) do
		start_at    [2,3]
		up	    1
		right	    1
		down	    1
	    end
	    polyline.must_equal Geometry::Polyline.new [3,5], [3,6], [4,6], [4,5]
	end
    end
end
