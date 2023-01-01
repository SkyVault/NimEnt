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

  # expandMacros:
  #   view(world, [Timer, Spatial]) do:
  #     echo "HERE?", ent

  world.update() 

  # dumpAstGen:
  #   let entId = 32
  #   let spatial = world.get[Spatial](entId)