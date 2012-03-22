require 'geometry'
require_relative 'sketch/point.rb'
require_relative 'sketch/polygon'

=begin
A Sketch is a container for Geometry objects.
=end

class Sketch
    attr_reader :elements

    Line = Geometry::Line

    def initialize
	@elements = []
    end

    def line(*args)
	@elements.push Line[*args]
	@elements.last
    end

    def point(*args)
	@elements.push Point[*args]
	@elements.last
    end
end
