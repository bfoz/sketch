require 'geometry'
require_relative 'point'

class Sketch
    Polygon = Geometry::Polygon

    class PolygonBuilder
	attr_reader :elements
	
	Edge = Geometry::Edge
	
	def initialize
	    @elements = []
	end
	def evaluate(&block)
	    @self_before_instance_eval = eval "self", block.binding
	    self.instance_eval &block
	    Polygon.new(*@elements)
	end
	def method_missing(method, *args, &block)
	    p "missing #{method.to_s}"
	    @self_before_instance_eval.send method, *args, &block
	end

	def edge(*args)
	    @elements.push Edge.new(*args)
	end
	def point(*args)
	    self.vertex(*args)
	end
	def vertex(*args)
	    @elements.push Point[*args]
	end
    end
    
    def polygon(*args, &block)
	if block_given?
	    @elements.push PolygonBuilder.new.evaluate(&block)
	    @elements.last
	else
	    @elements.push Polygon.new(*args)
	    @elements.last
	end
    end
end
