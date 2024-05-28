# Take home notes

## Links

- [Live demo](https://chimeces.com/brilliant-take-home/)
- [Source code](https://github.com/joakin/brilliant-take-home)
- Overview whiteboard:
  [excalidraw.com](https://excalidraw.com/#json=DrbMHE-ojsxax43BvESFC,nJhSo27qQRH3agrYyiwhPA),
  [PNG](https://github.com/joakin/brilliant-take-home/blob/master/docs/overview.png),
  [SVG](https://github.com/joakin/brilliant-take-home/blob/master/docs/overview.svg)
- [Development plan and time log](https://github.com/joakin/brilliant-take-home/blob/master/docs/dev-plan.md)

## Questions

### Now that you've had a chance to implement it, are there different features you would have prioritized, knowing what you know now?

At the start of the day I made myself a development plan to keep myself on track
and knowing what to do next. It wasn't necessarily in order, but I clearly
separated the important features from "stretch" features.

Given the conversation about the brief and the advice in it, my priority was to
make a simulation/playground were I'd be able to have at least up to the
parallel mirrors with infinite reflections working (as they were emphasized as
important, or so I understood), and then at the end layer on the simulation some
sort of exercise or objective.

This approach ended up working but it did take me a bunch of time to figure out
the right way to do the simulation once I got to multiple (N) mirrors and
infinite reflections. Partly because I confused myself at times, even with
taking frequent breaks. Being focused on the code for so long in a single day
was a bit rough. Maybe splitting the work across 2 days would have been better.

In the end, I got to a workable demo, but there is a lot I wanted to do and show
that I didn't have time to, particularly around visual and interaction
usability.

Knowing what I know now, I think I would have focused on a simple exercise like
the ones I drew in the overview whiteboard, with a single mirror or two mirrors
but without the infinite reflections, and usable dragging and placeholders and
exercise completion.

Only when that was fully complete and up to the level I wanted, I would have
moved on to the harder infinite reflections part and see if I could get that
working.

So, for features maybe I should have prioritized above the time spent on
infinite reflections:

- Animated light rays
- In simulation draggable indicators
- Droppable placeholders for the exercise
- Interactive objects
- Correct flipping/rotation of mirrored objects
- Showing "equal angles" indicators

### How could your interactive be extended to cover more concepts in optics?

A few things come to mind that would be related, particularly for this
interactive where the light rays are lines and not waves:

- Refraction
  - Could introduce different materials where the light bends as it passes from
    one surface to another, like water
  - Could introduce prisms or lenses to teach about how light can be dispersed
    or focused
- Light and colors
  - Could use an adaptation of the simulation to teach about how we see color,
    how light refracts differently on different surfaces, and why we see objects
    the color they are
- Sunsets and the color of the sky
  - Related to the previous two topics, using this kind of simulation to show
    how light travels differently in the atmosphere with the angle and that
    determines what color we see the sky
- Optic fiber and data transmission
  - Using the mirrors and the light rays could show how light travels through
    optic fiber cables even if they are bent
- Concave/convex mirrors
  - Why do you see things upside down? Using this sort of simulation adding
    convex/concave mirrors could be used to teach about it
- Lenses, glasses and telescopes
  - How do they work? How do they magnify or adjust light to change what we see?
    Exploring these would be very interesting

### What parts of your interactive could be useful in other areas of STEM? Give a few examples.

The objects and light rays (lines) simulation could be adapted to be useful to
explore physics simulations and geometry, exploring things like forces, bounces
and collisions, and trajectory paths.

The part about showing angles could be used with the lines to teach about
trigonometry (angles, distances, and other geometric concepts).

More directly related to optics, but in the computer science realm, this work
would probably be useful to illustrate how ray tracing and ray marching
algorithms work, at a basic level at least. This would involve emitting the
light rays and having them bounce in the surfaces until reaching the observer or
a "canvas", the light rays and objects part of the simulation would be useful.
