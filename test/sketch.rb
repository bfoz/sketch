require 'test/unit'
require_relative 'test_unit_extensions'
require_relative '../lib/sketch'

class SketchTest < Test::Unit::TestCase
    must "create a Sketch object" do
	sketch = Sketch.new
	assert_kind_of(Sketch, sketch);
    end

    must "have an elements accessor" do
	sketch = Sketch.new
	assert(sketch.public_methods.include?(:elements))
    end
end
