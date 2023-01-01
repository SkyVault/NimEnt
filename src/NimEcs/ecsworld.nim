import typetraits
import tables
import compbuff
import arrayutils

const MaxComponentTypes = 512

type 
  EntState* {.pure.} = enum
    Alive
    Dead
    
  EntId* = int
  
  Ent* = object
    id: EntId

    # TODO: Encode this enformation in a more data efficient way
    indexes: array[MaxComponentTypes, int]
    state: EntState

type World = object
  entities: seq[Ent]
  components: array[MaxComponentTypes, CompBuffer]
  tableTypeMap: Table[string, int]

type WorldRef* = ref World

proc initEcsWorld* (): World =
  result = World(
    entities: @[],
    tableTypeMap: initTable[string, int]()
  )
  for c in 0..<MaxComponentTypes:
    result.components[c] = newCompBuffer()

proc newEcsWorld* (): WorldRef =
  result = WorldRef(
    entities: @[],
    tableTypeMap: initTable[string, int]()
  )
  for c in 0..<MaxComponentTypes:
    result.components[c] = newCompBuffer()

proc spawn* (self: var World): EntId =
  result = len(self.entities)
  var ent = Ent(
    id: result,
    state: EntState.Alive,
  )
  fill(ent.indexes, -1)
  self.entities.add(ent)

proc getTypeIndex* (world: var World, name: string): int =
  result = 
    if world.tableTypeMap.hasKey(name):
      world.tableTypeMap[name]
    else:
      let n = len(world.tableTypeMap)
      world.tableTypeMap[name] = n 
      n

proc add* [T](world: var World, id: EntId, thing: T) =
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
  result = get[T](compBuff, index)

template has* (world: World, id: EntId, T: untyped): bool =
  let componentName = name(type(T))
  let typeIndex = world.getTypeIndex(componentName)
  world.entities[id].indexes[typeIndex] >= 0

template has* (world: World, id: EntId, A, B: untyped): bool =
  has(world, id, A) and has(world, id, B)

template has* (world: World, id: EntId, A, B, C: untyped): bool =
  has(world, id, A, B) and has(world, id, C)

template has* (world: World, id: EntId, A, B, C, D: untyped): bool =
  has(world, id, A, B) and has(world, id, C, D)
 
template eachEntityWith* (world: World, T: untyped, body: untyped) =
  for ent in world.entities:
    if not has(world, ent.id, T): continue
    body
  
template eachEntityWith* (world: World, A, B: untyped, body: untyped) =
  for ent in world.entities:
    if not has(world, ent.id, A, B): continue
    body
  
template eachEntityWith* (world: World, A, B, C: untyped, body: untyped) =
  for ent in world.entities:
    if not has(world, ent.id, A, B, C): continue
    body

template eachEntityWith* (world: World, A, B, C, D: untyped, body: untyped) =
  for ent in world.entities:
    if not has(world, ent.id, A, B, C, D): continue
    body