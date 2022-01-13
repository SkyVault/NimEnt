type CompBuffer* = ref object
  buff: seq[byte]
  total: int

proc newCompBuffer* (): CompBuffer =
  result = CompBuffer(
    buff: @[],
    total: 0,
  )

proc add* [T](self: CompBuffer, comp: T): int {.discardable.} =
  const size = sizeof(T)
  let arr = cast[array[size, byte]](comp)

  let start = size * self.total
  for i in 0..<len(arr):
    self.buff.add(arr[i])

  result = self.total
  self.total += 1

proc get* [T](self: CompBuffer, index: int): ptr T =
  const size = sizeof(T)
  let start = size * index
  return cast[ptr T](self.buff[start].addr)
