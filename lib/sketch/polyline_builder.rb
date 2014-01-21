require 'geometry'
require 'geometry/polyline/dsl'

class Sketch
    Polyline = Geometry::Polyline

    class PolylineBuilder
	BuildError = Class.new(StandardError)

	attr_reader :elements

	include Geometry::Polyline::DSL

	def initialize
	    @elements = []
	end

	# Evaluate a block and return a new {Path}
	# @return [Path]	A new {Path} initialized with the given block
	def evaluate(&block)
	    self.instance_eval &block
	    Polyline.new(*@elements)
	end

	# @return [Point]   the first vertex of the {Polyline}
	def first
	    @elements.first
	end

	# @return [Point]   the last, or most recently added, vertex of the {Polyline}
	def last
	    @elements.last
	end

	# Push the given object
	# @param [Geometry] arg A {Geometry} object to apped to the {Path}
	# @return [Geometry]    The appended object
	def push(arg)
	    @elements.push arg
	    arg
	end
    end
end
