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

  let c = Timer(time: 13)
  let arr = cast[array[sizeof(c), byte]](c)
  let c2 = cast[Timer](arr)
  echo("T: ", c2.time)
  
#   world.add(ent, Spatial(x: 32, y: 120))
  world.add(ent, Timer(time: 1024.32))

  let timer = get[Timer](world, ent)
  echo("SP: ", timer.time)

  # echo world
