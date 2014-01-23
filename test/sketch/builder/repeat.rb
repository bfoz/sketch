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
end
