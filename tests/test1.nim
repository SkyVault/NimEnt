import unittest

import NimEcs

type Spatial = object
    x: float
    y: float
  
type Timer = object
    time: float

test "can add":
  let world = initEcsWorld()

  for i in 0..5:
    let ent = world.spawn()
    world.add(ent, Timer(time: 1024.32))
    world.add(ent, Spatial(x: 0.0, y: 0.0))

  eachEntityWith(world, Spatial, Timer):
    echo "HERE?"