import unittest

import NimEcs

type Spatial = object
    x: float
    y: float
  
type Timer = object
    time: float

test "can add":
  let world = initEcsWorld()
  let ent = world.spawn()
  
#   world.add(ent, Spatial(x: 32, y: 120))
  world.add(ent, Timer(time: 1024.32))

  var timer = get[Timer](world, ent)
  timer.time = 123

  echo("T:", get[Timer](world, ent).time)

  # echo world
