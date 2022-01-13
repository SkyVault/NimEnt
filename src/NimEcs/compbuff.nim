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

  if len(self.buff) == 0:
    self.buff.setLen(size * 32)

  let start = size * self.total
  for i in 0..<len(arr):
    self.buff[start + i] = arr[i]

  result = self.total
  self.total += 1

proc get* [T](self: CompBuffer, index: int): ptr T =
  const size = sizeof(T)
  let start = size * index
  return cast[ptr T](self.buff[start].addr)
