require 'geometry'
require_relative 'sketch/point.rb'

=begin
A Sketch is a container for Geometry objects.
=end

class Sketch
    attr_reader :elements

    def initialize
	@elements = []
    end
end
