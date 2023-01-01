import unittest

import NimEcs

type Spatial = object
    x: float
    y: float
  
type Timer = object
    time: float
  
type Groups = object

test "can add":
  var world = initEcsWorld()

  for i in 0..5:
    let ent = world.spawn()
    world.add(ent, Timer(time: 1024.32))
    world.add(ent, Spatial(x: 0.0, y: 0.0))
    world.add(ent, Groups())

  echo has(world, 0, Timer, Spatial, Groups)