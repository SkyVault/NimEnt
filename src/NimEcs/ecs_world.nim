import typetraits
import std/hashes
import tables
import compbuff

const MAX_COMPONENTS = 256

type 
  EntState* {.pure.} = enum
    Alive
    Dead
    
  EntId* = int
  
  Ent* = object
    id: EntId
    indexes: array[MAX_COMPONENTS, int]
    state: EntState

type World* = ref object
  entities: seq[Ent]
  components: array[MAX_COMPONENTS, CompBuffer]
  tableTypeMap: Table[string, int]

proc initEcsWorld* (): World =
  result = World(
    entities: @[],
    tableTypeMap: initTable[string, int]()
  )
  for c in 0..<MAX_COMPONENTS:
    result.components[c] = newCompBuffer()

proc spawn* (self: World): EntId =
  result = len(self.entities)
  self.entities.add(Ent(
    id: result,
    state: EntState.Alive,
  ))

proc getTypeIndex(world: World, name: string): int =
  result = 
    if world.tableTypeMap.hasKey(name):
      world.tableTypeMap[name]
    else:
      let n = len(world.tableTypeMap)
      world.tableTypeMap[name] = n 
      n

proc add* [T](world: World, id: EntId, thing: T) =
  let componentName = name(type(T))
  let typeIndex = world.getTypeIndex(componentName)
  let compBuff = world.components[typeIndex]
  let index = compBuff.add(thing)
  world.entities[id].indexes[typeIndex] = index
  
proc get* [T](world: World, id: EntId): ptr T =
  let componentName = name(type(T))
  let typeIndex = world.getTypeIndex(componentName)
  let compBuff = world.components[typeIndex]
  let index = world.entities[id].indexes[typeIndex]
  return get[T](compBuff, index)