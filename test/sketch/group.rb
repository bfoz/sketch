require 'minitest/autorun'
require 'sketch/group'

describe Sketch::Group do
    describe "when constructed" do
	describe "with no arguments" do
	    subject { Sketch::Group.new }

	    it "must have an identity transformation" do
		subject.transformation.identity?.must_equal true
	    end

	    it "must be empty" do
		subject.elements.size.must_equal 0
	    end
	end

	it "must accept valid Transformation arguments" do
	    group = Sketch::Group.new origin:[1,2,3]
	    group.transformation.translation.must_equal Point[1,2,3]
	end
    end
end
