import strutils, sequtils

proc getInput(fileName: string): seq[seq[int]] =
    let strNums = readFile(fileName).strip().splitLines()
    let numLen = strNums[0].len # get digit length of each number
    for i in 0 .. numLen - 1:
        var digSeq: seq[int]
        for j in 0 .. strNums.len - 1:
            var strDig: string = strNums[j][i .. i]
            digSeq.add(parseInt(strDig))
        result.add(digSeq)

proc getUnparsedInput(fileName: string): seq[string] =
    result = readFile(fileName).strip().splitLines()

proc getRatesAsStr(bits: seq[seq[int]]): tuple[gamma: string, epsilon: string] = 
    var
        gamma: string
        epsilon: string
    for s in bits:
        let sum = s.foldl(a + b) 
        if sum.float > (s.len - 1) / 2:
            gamma.add("1")
            epsilon.add("0")
        else:
            gamma.add("0")
            epsilon.add("1")
    result = (gamma, epsilon)

proc countBitsAtIndex(bits: seq[string], idx: int): tuple[one: int, zero: int] =
    var
        one: int
        zero: int
    for s in bits:
        if $s[idx] == "1":
            one += 1
        else:
            zero += 1
    result = (one, zero)

proc interpretBitCount(one: int, zero: int, findMost: bool): string =
    if findMost:
        if one > zero or one == zero:
            result = "1"
        else:
            result = "0"
    else:
        if zero < one or one == zero:
            result = "0"
        else:
            result = "1"

proc getRating(bits: seq[string], findOxygen: bool): string =
    var idx: int = 0
    var currBits: seq[string] = bits
    while true:
        var bitCount: tuple[one: int, zero: int] = countBitsAtIndex(currBits, idx)
        var target: string = interpretBitCount(bitCount.one, bitCount.zero, findOxygen)
        var filteredBits: seq[string] = filter(currBits, proc(x: string): bool = $x[idx] == target)
        if (filteredBits.len == 1):
            result = filteredBits.pop()
            break;
        else:
            idx += 1
            currBits = filteredBits

let data = getInput("input.txt")
echo "Part 1 Gamma: " & getRatesAsStr(data).gamma 
echo "Part 1 Epsilon: " & getRatesAsStr(data).epsilon
echo "Part 1 Power Consumption: " & $(getRatesAsStr(data).gamma.parseBinInt() * getRatesAsStr(data).epsilon.parseBinInt())

let strData = getUnparsedInput("input.txt")
echo "\nPart 2 Oxygen Generator Rating: " & getRating(strData, true)
echo "Part 2 CO2 Scrubber Rating: " & getRating(strData, false)
echo "Part 2 Life Support Rating: " & $(getRating(strData, true).parseBinInt() * getRating(strData, false).parseBinInt())