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

proc findSignalMapping(patterns: seq[string]): Table[int, string] =
    # find 1478
    for val in patterns:
        if isOne(val):
            result[1] = val
        elif isFour(val):
            result[4] = val
        elif isSeven(val):
            result[7] = val
        elif isEight(val):
            result[8] = val
    # separate possible 069 (nice) and possible 235
    var zeroSixNine: seq[string]
    var twoThreeFive: seq[string]
    for val in patterns:
        if isZeroSixNine(val):
            zeroSixNine.add(val)
        elif isTwoThreeFive(val):
            twoThreeFive.add(val)
    # identify 069 
    # 9 and 4 are the only non-8 digits in this set that share bcdf
    for val in zeroSixNine:
        if checkForSignalIntercept(result[4], val):
            result[9] = val
            zeroSixNine.delete(zeroSixNine.find(val))
            break
    # 0 and 7 are the only remaining non-8 digits in this set that share acf
    for val in zeroSixNine:
        if checkForSignalIntercept(result[7], val):
            result[0] = val
            zeroSixNine.delete(zeroSixNine.find(val))
            break
    # whatever remains is 6!
    result[6] = zeroSixNine.pop()
    # identify 235
    # 3 is the only digit in this set that shares acf with 7
    for val in twoThreeFive:
        if checkForSignalIntercept(result[7], val):
            result[3] = val
            twoThreeFive.delete(twoThreeFive.find(val))
            break
    # 5 doesn't share all of 4's segments, but unlike 2 it has bdf. 2 only has cd
    for val in twoThreeFive:
        if checkForNIntercepts(result[4], val, 3):
            result[5] = val
            twoThreeFive.delete(twoThreeFive.find(val))
            break
    # whatever remains is 2!
    result[2] = twoThreeFive.pop()

proc decodeOutput(puzzleKey: Table[int, string], output: seq[string]): int =
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
            if checkForSignalIntercept(puzzleKey[7], i):
                decoded.add(3)
            elif checkForNIntercepts(puzzleKey[4], i, 3):
                decoded.add(5)
            else:
                decoded.add(2)
        elif isZeroSixNine(i):
            if checkForSignalIntercept(puzzleKey[4], i):
                decoded.add(9)
            elif checkForSignalIntercept(puzzleKey[7], i):
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
        # generate puzzle key
        var puzzleKey: Table[int, string] = findSignalMapping(e.patterns)
        # decode output
        var output: int = decodeOutput(puzzleKey, e.output)
        result += output

let data = getInput("input.txt")
echo "Part 1 Solution: " & $findEasys(data)
echo "Part 2 Solution: " & $findOutputSums(data)