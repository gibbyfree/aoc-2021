# the most brute force-y solution to ever brute force
import strutils, tables, sequtils

# i regret parsing to this stupid type but i'm too lazy to refactor it out
type
    Entry = object
        patterns: seq[string]
        output: seq[string]

#[
  0:      1:      2:      3:      4:
 aaaa    ....    aaaa    aaaa    ....
b    c  .    c  .    c  .    c  b    c
b    c  .    c  .    c  .    c  b    c
 ....    ....    dddd    dddd    dddd
e    f  .    f  e    .  .    f  .    f
e    f  .    f  e    .  .    f  .    f
 gggg    ....    gggg    gggg    ....

  5:      6:      7:      8:      9:
 aaaa    aaaa    aaaa    aaaa    aaaa
b    .  b    .  .    c  b    c  b    c
b    .  b    .  .    c  b    c  b    c
 dddd    dddd    ....    dddd    dddd
.    f  e    f  .    f  e    f  .    f
.    f  e    f  .    f  e    f  .    f
 gggg    gggg    ....    gggg    gggg
]#

proc getInput(fileName: string): seq[Entry] =
    var tmp: seq[string] = readFile(fileName).strip().splitLines() # doesn't remove delimiter 
    for s in tmp:
        var entrySeq: seq[string] = s.split(" | ")
        var patternSeq: seq[string] = entrySeq[0].split()
        var outputSeq: seq[string] = entrySeq[1].split()
        result.add(Entry(patterns: patternSeq, output: outputSeq))

proc isOne(segment: string): bool =
    return segment.len == 2

proc isFour(segment: string): bool =
    return segment.len == 4

proc isSeven(segment: string): bool =
    return segment.len == 3

proc isEight(segment: string): bool =
    return segment.len == 7

proc isTwoThreeFive(segment: string): bool =
    return segment.len == 5

proc isZeroSixNine(segment: string): bool = 
    return segment.len == 6

proc findEasys(entries: seq[Entry]): int =
    for e in entries:
        for val in e.output:
            if isOne(val) or isFour(val) or isSeven(val) or isEight(val):
                result += 1

proc findFour(segments: seq[string]): string =
    for str in segments:
        if isFour(str):
            result = str

proc findSeven(segments: seq[string]): string =
    for str in segments:
        if isSeven(str):
            result = str

proc checkForSignalIntercept(known: string, unknown: string): bool =
    var knownCharSeq: seq[char] = toSeq(known.items)
    for c in knownCharSeq:
        if not unknown.contains(c):
            return false
    return true

proc checkForNIntercepts(known: string, unknown: string, target: int): bool =
    var knownCharSeq: seq[char] = toSeq(known.items)
    var count: int = 0
    for c in knownCharSeq:
        if unknown.contains(c):
            count += 1
    if count == target:
        return true
    else:
        return false

proc decodeOutput(fourStr: string, sevenStr: string, output: seq[string]): int =
    var decoded: seq[int]
    for i in output:
        if isOne(i):
            decoded.add(1)
        elif isEight(i):
            decoded.add(8)
        elif isSeven(i):
            decoded.add(7)
        elif isFour(i):
            decoded.add(4)
        elif isTwoThreeFive(i):
            if checkForSignalIntercept(sevenStr, i):
                decoded.add(3)
            elif checkForNIntercepts(fourStr, i, 3):
                decoded.add(5)
            else:
                decoded.add(2)
        elif isZeroSixNine(i):
            if checkForSignalIntercept(fourStr, i):
                decoded.add(9)
            elif checkForSignalIntercept(sevenStr, i):
                decoded.add(0)
            else:
                decoded.add(6)
        else:
            echo "what the hell is going on"
    # convert numbers to string i guess!
    var numStr: string
    for i in decoded:
        numStr.add($i)
    result = parseInt(numStr)

proc findOutputSums(entries: seq[Entry]): int =
    for e in entries:
        # find 4 + 7
        var fourStr: string = findFour(e.patterns)
        var sevenStr: string = findSeven(e.patterns)
        # decode output
        var output: int = decodeOutput(fourStr, sevenStr, e.output)
        result += output

let data = getInput("input.txt")
echo "Part 1 Solution: " & $findEasys(data)
echo "Part 2 Solution: " & $findOutputSums(data)