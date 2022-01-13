proc fill* [T](a: var openArray[T], value: T, first, last: Natural) =
  var x = first
  while x <= last:
    a[x] = value
    inc(x)

proc fill* [T](a: var openArray[T], value: T) =
  fill(a, value, a.low, a.high)