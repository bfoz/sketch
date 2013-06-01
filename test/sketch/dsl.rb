require 'minitest/autorun'
require 'sketch/dsl'

class Fake
    attr_accessor :elements

    include Sketch::DSL

    def initialize
	@elements = []
    end

    def push(*args)
	elements.push args.first
    end
end

describe Sketch::DSL do
    Point = Geometry::Point

    subject { Fake.new }

    it "must have a first command that returns the first element" do
	point = Geometry::Point[1,2]
	subject.elements.push point
	subject.first.must_be_same_as point
    end

    it "must have a last command that returns the last element" do
	point = Point[1,2]
	subject.elements.push Point[3,4]
	subject.elements.push point
	subject.last.must_be_same_as point
    end

    it "must have a hexagon command" do
	subject.hexagon center:[1,2], radius:5
	subject.last.must_be_instance_of Geometry::RegularPolygon
	subject.last.center.must_equal Point[1,2]
	subject.last.edge_count.must_equal 6
	subject.last.radius.must_equal 5
    end

    describe "when layout" do
	describe "without spacing" do
	    it "must do a horizontal layout" do
		subject.layout :horizontal do
		    rectangle from:[0,0], to:[5,5]
		    rectangle from:[0,0], to:[6,6]
		end

		group = subject.first
		group.must_be_instance_of Sketch::Layout

		group.first.must_be_kind_of Geometry::Rectangle
		group.last.must_be_kind_of Sketch::Group
	    end

	    it "must do a vertical layout" do
	    end
	end

	describe "with spacing" do
	    it "must do a horizontal layout" do
	    end

	    it "must do a vertical layout" do
	    end
	end
    end

end
