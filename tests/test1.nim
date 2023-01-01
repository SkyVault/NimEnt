import unittest, macros, sugar

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
    world.add(ent, Spatial(x: i.float, y: 0.0))
    world.add(ent, Groups())

  echo has(world, 0, Timer, Spatial, Groups)

  world.eachWith(Spatial, Timer) do (e: EntId, s: var Spatial, t: Timer):
    echo e, " ", s.x, " ", s.y
    s.y += 1.0

  world.eachWith(Spatial) do (e: EntId, s: Spatial):
    echo e, " ", s.x, " ", s.y

  echo view(world, Spatial, Timer, Groups)