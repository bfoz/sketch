Sketching with Ruby
===================

[![Build Status](https://travis-ci.org/bfoz/sketch.png)](https://travis-ci.org/bfoz/sketch)

Classes and methods for programmatically creating, manipulating, and exporting 
simple geometric drawings. This gem is primarily intended to support mechanical
design generation, but it can also handle the doodling that you used to do in 
your notebook while stuck in that really boring class (you know the one).

At its most basic, Sketch is a container for Geometry objects. The classes in 
this gem are based on the classes provided by the [Geometry gem](https://github.com/bfoz/geometry), but have some
extra magic applied to support transformations, constraints, etc. Like the 
Geometry module, Sketch assumes that primitives lie in 2D space, but doesn't 
enforce that constraint. Please let me know if you find cases that don't work in
higher dimensions and I'll do my best to fix them.

License
-------

Copyright 2012-2014 Brandon Fosdick <bfoz@bfoz.net> and released under the BSD license.

Examples
--------

A basic sketch with a single circle

```ruby
require 'sketch'

sketch = Sketch.new do
    circle center:[0,0], diameter:5	# Center = [0,0], Radius = 5
end
```

The same sketch again, but a little more square

```ruby
Sketch.new { rectangle origin:[0,0], size:[1,1] }
```

You can also group elements for convenience

```ruby
Sketch.new do
    group origin:[0,2] do
        circle center:[-2, 0], radius:1
        circle center:[2, 0], radius:1
    end
    circle center:[0, -1], radius:1
end
```

There's a shortcut for when you're only creating a group to translate some elements

```ruby
Sketch.new do
    translate [0,2] do
        circle center:[-2, 0], radius:1
        circle center:[2, 0], radius:1
    end
    circle center:[0, -1], radius:1
end
```

Sometimes you feel like a group, sometimes you feel like a layout.

```ruby
Sketch.new do
    layout :horizontal do
        circle center:[-2, 0], radius:1
        circle center:[2, 0], radius:1
    end
end
```

The layout command also takes options for spacing and alignment. For example, to add one unit of extra space between each element, and align them with the X-axis:

```ruby
Sketch.new do
    layout :horizontal, spacing:1, align: :bottom do
        circle center:[-2, 0], radius:1
        circle center:[2, 0], radius:1
    end
end
```

### Repetition
Do you ever get tired of making the same square over and over again?

```ruby
Sketch.new do
    repeat count:2, step:[5,5] do
        square size:1
    end
end
```

### Paths, Polylines and Polygons
If you're as old as I am, you might remember a certain [turtle](http://en.wikipedia.org/wiki/Turtle_graphics)
that would obey your every command. Well, any command involving a certain pen.

```ruby
Sketch.new do
    polygon do      # Drawing a square, the hard way
        start_at    [0,0]
        up          5
        right       5
        down        5
        # Polygons close automatically; there's no need to draw the final line
    end
end
```

Simlarly, the `path` and `polyline` commands will create _Path_ and _Polyline_
objects, respectively. Neither paths nor polylines are closed by default, which
allows you to draw any open shape you'd like. But, should you change your mind,
just use the `close` command as the last line in the block to automatically
close the shape.

#### Repeat
When you get tired of doing the same thing over and over, you can use the
`repeat` command inside of the `path`, `polygon`, and `polyline` commands.
It's not quite the same as the `repeat` command from the Sketch DSL, so be careful.

```ruby
Sketch.new do	    # A simple panel with box joints on 2 edges
    polygon do
        start_at    [0,0]

        repeat to:[0, PANEL_HEIGHT], count:2 do |step|
            forward step/2
            right   PANEL_THICKNESS
            forward step/2
        end

        right       PANEL_WIDTH

        repeat to:[last.x, 0], count:2 do |step|
            forward step/2
            right   PANEL_THICKNESS
            forward step/2
        end
    end
end
```