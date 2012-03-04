require 'matrix'

class Sketch
    class Point
	attr_reader :x, :y
	def initialize(*args)
	    args[0] = args[0].to_a if args[0].is_a?(Vector)
	    args = args[0] if args[0].is_a?(Array)
	    @elements = args
	    @x = args[0] if args[0]
	    @y = args[1] if args[1]
	end
	
	def Point.[](*array)
	    new *array
	end

	def [](i)
	    @elements[i]
	end
	def inspect
	    'Point(' + @elements.inspect + ')'
	end
	def size
	    @elements.size
	end
	def to_a
	    @elements.dup
	end
	def to_s
	    'Point(' + @elements.join(',') + ')'
	end
    end
end
