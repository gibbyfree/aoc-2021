import strutils

proc getInput(fileName: string): seq[tuple[direction: string, x: int]] =
    var strTuples = readFile(fileName).strip().splitLines()
    for str in strTuples:
        let s = str.splitWhitespace()
        let t = (direction: s[0], x: s[1].parseInt)
        result.add(t)

proc getFinalPosition(commands: seq[tuple[direction: string, x:int]]): tuple[horizontal: int, depth: int] =
    var 
        hz: int
        depth: int
    for t in commands:
        case t.direction
        of "forward":
            hz += t.x
        of "down":
            depth += t.x
        of "up":
            depth -= t.x
        else: discard
    result = (hz, depth)

proc getFinalPositionWithAim(commands: seq[tuple[direction: string, x:int]]): tuple[horizontal: int, depth: int] =
    var
        hz: int
        depth: int
        aim: int
    for t in commands:
        case t.direction
        of "forward":
            hz += t.x
            depth += (aim * t.x)
        of "down":
            aim += t.x
        of "up":
            aim -= t.x
        else: discard
    result = (hz, depth)


let data = getInput("input.txt")
echo "Part 1 solution: " & (getFinalPosition(data).horizontal * getFinalPosition(data).depth).intToStr()
echo "Part 2 solution: " & (getFinalPositionWithAim(data).horizontal * getFinalPositionWithAim(data).depth).intToStr()