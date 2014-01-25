require 'minitest/autorun'
require 'sketch/builder/repeat'

describe Sketch::Builder::Repeat do
    subject { Sketch::Builder::Repeat.new([0,0]) }

    it 'must simply repeat' do
	subject.build([0,4], 4) do |step|
	    forward step
	end.must_equal [[0,1], [0,2], [0,3], [0,4]].map {|a| Point[a] }
    end

    it 'must ensure that the end of each repeat block is connected to the base line' do
	subject.build [0,4], 4 do |step|
	    forward	step
	    left	1
	end.must_equal [[0,1], [-1,1], [0,1],
			[0,2], [-1,2], [0,2],
			[0,3], [-1,3], [0,3],
			[0,4], [-1,4], [0,4]].map {|a| Point[a] }
    end

    it 'must have a first? attribute that is only true for the first repetition' do
	firsts = []
	subject.build [0,4], 4 do |step|
	    firsts.push first?
	end
	firsts.must_equal [true, false, false, false]
    end

    it 'must have a last? attribute that is only true for the last repetition' do
	lasts = []
	subject.build [0,4], 4 do |step|
	    lasts.push last?
	end
	lasts.must_equal [false, false, false, true]
    end

    it 'must be first? and last? when repeating only once' do
	subject.build [0,4], 1 do |step|
	    first?.must_equal true
	    last?.must_equal true
	end
    end
end
