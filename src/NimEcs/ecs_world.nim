import typetraits
import std/hashes
import tables

const MAX_COMPONENTS = 256

type CompBuffer* = ref object
  buff: seq[byte]
  total: int

proc newCompBuffer* (): CompBuffer =
  result = CompBuffer(
    buff: @[],
    total: 0,
  )

proc add[T](self: CompBuffer, comp: T): int {.discardable.} =
  const size = sizeof(T)
  let arr = cast[array[size, byte]](comp)

  if len(self.buff) == 0:
    self.buff.setLen(size * 32)

  let start = size * self.total
  for i in 0..<len(arr):
    self.buff[start + i] = arr[i]

  result = self.total
  self.total += 1

proc get[T](self: CompBuffer, index: int): T =
  const size = sizeof(T)
  let start = size * index

  var arr: array[size, byte]
  for i in 0..<len(arr):
    arr[i] = self.buff[start + i]

  return cast[T](arr)

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
  
proc get* [T](world: World, id: EntId): T =
  let componentName = name(type(T))
  let typeIndex = world.getTypeIndex(componentName)
  let compBuff = world.components[typeIndex]
  let index = world.entities[id].indexes[typeIndex]
  return get[T](compBuff, index)