import strutils, sequtils, std/algorithm, std/stats, std/math

proc getInput(fileName: string): seq[int] =
    result = readFile(fileName).strip().split(',').map(parseInt)

proc findMedian(n: seq[int]): int =
    var n: seq[int] = n
    n.sort()

    var med1: int = n[int(n.len / 2)]
    var med2: int = n[int((n.len / 2) - 1)]
    result = int((med1 + med2) / 2)

# Need to check both rounding up + rounding down
proc findMean(n: seq[int]): tuple[low: int, high: int] =
    var n: seq[int] = n
    var high: int = int(round(mean(n)))
    var low: int = int(mean(n))
    result = (low, high)

proc calculateFuel(n: seq[int], median: int): int =
    for num in n:
        result += abs(num - median)

# Need to check both rounding up + rounding down
proc calculateFuelNotConstant(n: seq[int], means: tuple[low: int, high: int]): int =
    var highResult: int = 0
    var lowResult: int = 0
    for num in n:
        var lowDistance: int = abs(num - means.low)
        var highDistance: int = abs(num - means.high)
        lowResult += int((lowDistance * (lowDistance + 1)) / 2) # (4 * (4 + 1)) / 2 = 10
        highResult += int((highDistance * (highDistance + 1)) / 2)
    result = min(highResult, lowResult)

let data = getInput("input.txt")
let median = findMedian(data)
let mean = findMean(data)
echo "Part 1 Solution: " & $calculateFuel(data, median)
echo "Part 2 Solution: " & $calculateFuelNotConstant(data, mean)