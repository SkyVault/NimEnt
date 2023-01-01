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

  view(world, [Timer, Spatial]) do:
    echo "HERE"

  view(world, [Timer, Spatial]) do:
    echo "HERE2"

  world.update() 

  # expandMacros:
  #   view(world, [Timer, Spatial]) do:
  #     echo "HERE: "

  dumpAstGen:
    if not world.has(entId, Spatial):
      return