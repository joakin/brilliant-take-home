# Development plan

## Dev plan

### Graphics

- [x] Draw observer
- [x] Draw objects
- [x] Draw mirror
- [x] Draw light ray
- [ ] Draw angle between surface and rays (equal angles)
- [ ] 🥉 Draw **growing** light ray with arrow tip
- [ ] 🥈 Draw pulses within the light ray indicating direction
- [ ] 🥇 Draw many rays from object in all directions and fade them out after
      some time (make them bounce in mirrors)
- [x] 🥉 Displace overlapping observer light rays
  - Done but disabled

### Interactions

- [x] Interact with observer (drag around)
- [ ] Interact with mirror (drag around, axis locking)
- [ ] Interactable tooltip (pulse, labels on top, etc)
- [ ] Draggable/droppable areas
- [ ] 🥉Add axis locking to objects

### Mirror reflections

- [x] Reflecting objects on mirror
- [x] Keeping only reflected objects that have direct line of sight with eye
- [x] Draw light ray from objects to eye
- [x] Draw line of sight from eye to virtual object
- [x] Multiple mirrors
- [ ] Flipping/rotation of mirrored objects
- [ ] 🥉 Only draw line of sight to reflection after ray hits observer
- [ ] 🥈 Color code with shades the light ray, and use the same shades when
      drawing line of sight
- [ ] 🥇 Draw all light rays for all reflections at the same time to the
      observer

### Customizable simulation for the lesson

- [x] Move the simulation to a parametrizable program, so that you can configure
      it from Main.elm to choose what you want
  - [x] Show light rays
  - [ ] Angles
  - [ ] Can move observer or objects, which ones
  - [ ] Locking axis of the movement
  - [x] Which objects and mirrors and observer position will be there

## Time Log

- 10:30-11:00 (30m): Prep, notes & overview review, write dev plan, setup coding
  env
- 11:30-13:30 (2h): Drawing objects, mirrors, light rays
- 13:30-15:15 (1h 45m): Rendering mirrored objects when in line of sight to the
  observer
- 17:15-18:30 (1h 15m): Generating light rays and eye-sight lines from
  reflections
- 18:45-20:30 (1h 45m): Multiple mirrors and infinite reflections
- 21:30-23:30 (2h): Polish, text descriptions and multiple simulations

- Total time: 9 hours 15 minutes
