Sketching with Ruby
===================

Classes and methods for programmatically creating, manipulating, and exporting 
simple geometric drawings. This gem is primarily intended to support mechanical
design generation, but it can also handle the doodling that you used to do in 
your notebook while stuck in that really boring class (you know the one).

At its most basic, Sketch is a container for Geometry objects. The classes in 
this gem are based on the classes provided by the Geometry gem, but have some 
extra magic applied to support transformations, constraints, etc. Like the 
Geometry module, Sketch assumes that primitives lie in 2D space, but doesn't 
enforce that constraint. Please let me know if you find cases that don't work in
higher dimensions and I'll do my best to fix them.

License
-------

Copyright 2012 Brandon Fosdick <bfoz@bfoz.net> and released under the BSD 
license.

Examples
--------

A basic sketch with a single circle

```ruby
require 'sketch'

sketch = Sketch do
    circle [0,0], 5	# Center = [0,0], Radius = 5
end
```