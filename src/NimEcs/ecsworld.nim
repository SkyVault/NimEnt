import typetraits, tables, compbuff, arrayutils, sets, macros

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

type 
  View = object
    keys: HashSet[int] # type indexes

  World = object
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

proc add* [T](world: var World, id: EntId, component: T) =
  let componentName = name(type(T))
  let typeIndex = world.getTypeIndex(componentName)
  let compBuff = world.components[typeIndex]
  let index = compBuff.add(component)
  world.entities[id].indexes[typeIndex] = index
  
proc get* [T](world: var World, id: EntId): ptr T =
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
 
proc getView* (world: var World, a: typedesc): seq[EntId] =
  for ent in world.entities:
    var valid = true
    if not world.has(ent.id, a):
      valid = false
      break
    if valid: result.add(ent.id)

proc getView* (world: var World, a, b: typedesc): seq[EntId] =
  for ent in world.entities:
    var valid = true
    if not world.has(ent.id, a) or not world.has(ent.id, b):
      valid = false
      break
    if valid: result.add(ent.id)

proc getView* (world: var World, a, b, c: typedesc): seq[EntId] =
  for ent in world.entities:
    var valid = true
    if not world.has(ent.id, a) or not world.has(ent.id, b) or not world.has(ent.id, c):
      valid = false
      break
    if valid: result.add(ent.id)
 
template eachWith* (world: var World, a: typedesc, fn: untyped) =
  for ent in world.entities:
    var valid = true
    if not world.has(ent.id, a):
      valid = false
      break
    if valid:
      fn(ent.id, get[a](world, ent.id)[])

template eachWith* (world: var World, a, b: typedesc, fn: untyped) =
  for ent in world.entities:
    var valid = true
    if not world.has(ent.id, a, b):
      valid = false
      break
    if valid:
      fn(ent.id, get[a](world, ent.id)[], get[b](world, ent.id)[])

template eachWith* (world: var World, a, b, c: typedesc, fn: untyped) =
  for ent in world.entities:
    var valid = true
    if not world.has(ent.id, a, b, c):
      valid = false
      break
    if valid:
      fn(ent.id, get[a](world, ent.id)[], get[b](world, ent.id)[], get[c](world, ent.id)[])

template eachWith* (world: var World, a, b, c, d: typedesc, fn: untyped) =
  for ent in world.entities:
    var valid = true
    if not world.has(ent.id, a, b, c, d):
      valid = false
      break
    if valid:
      fn(ent.id, get[a](world, ent.id)[], get[b](world, ent.id)[], get[c](world, ent.id)[], get[c](world, ent.id)[])

macro lenVarargs*(a: varargs[untyped]): untyped = newLit len(a)

macro view* (w: World, xs: varargs[untyped]): seq[EntId] =
  result = quote do:
    var res = newSeq[EntId]()
    for e in `w`.entities:
      for i in 0..<lenVarargs(xs):
        if `w`.has(e.id, `xs[i]`):
          res.add(e.id)
    res