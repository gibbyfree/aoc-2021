import strutils, sequtils, tables, std/algorithm

proc getInput(fileName: string): seq[seq[int]] =
    var strLines: seq[string] = readFile(fileName).strip().splitLines()
    for line in strLines:
        var lineSplit: seq[string]
        for c in line.items:
            lineSplit.add($c)
        result.add(lineSplit.map(parseInt))

proc findLows(heightmap: seq[seq[int]]): seq[tuple[x: int, y: int]] =
    for i in 0 .. heightmap.len - 1:
        for j in 0 .. heightmap[i].len - 1:
            var isLow: bool = true
            if (j != 0): # check left
                if (heightmap[i][j - 1] <= heightmap[i][j]):
                    isLow = false
            if (i < heightmap.len - 1): # check down
                if (heightmap[i + 1][j] <= heightmap[i][j]):
                    isLow = false
            if (j < heightmap[i].len - 1): # check right
                if (heightmap[i][j + 1] <= heightmap[i][j]):
                    isLow = false
            if (i != 0): # check up
                if (heightmap[i - 1][j] <= heightmap[i][j]):
                    isLow = false
            if isLow:
                result.add((x: i, y: j))

proc sumRiskLevels(lows: seq[tuple[x: int, y: int]], heightmap: seq[seq[int]]): int =
    for t in lows:
        result += heightmap[t.x][t.y] + 1

proc getAdjacents(heightmap: seq[seq[int]], x: int, y: int): seq[tuple[x: int, y: int]] =
    if (y != 0): 
        result.add((x: x, y: y - 1))
    if (x < heightmap.len - 1): 
        result.add((x: x + 1, y: y))
    if (y < heightmap[x].len - 1): 
        result.add((x: x, y: y + 1))
    if (x != 0): 
        result.add((x: x - 1, y: y))

# Locations of height 9 do not count as being in any basin
proc findBasinSize(heightmap: seq[seq[int]], low: tuple[x: int, y: int], visited: Table[tuple[x: int, y: int], bool], size: int): 
        tuple[basinSize: int, visited: Table[tuple[x: int, y: int], bool]] =
    var visited: Table[tuple[x: int, y: int], bool] = visited
    var size: int = size
    visited[(low.x, low.y)] = true
    for tAdj in getAdjacents(heightMap, low.x, low.y):
        if heightmap[tAdj.x][tAdj.y] == 9:
            visited[tAdj] = true
            continue
        if heightmap[tAdj.x][tAdj.y] != 9 and not visited.hasKey(tAdj):
            visited[tAdj] = true
            size += 1
            var output: tuple[basinSize: int, visited: Table[tuple[x: int, y: int], bool]] = findBasinSize(heightmap, tAdj, visited, size)
            size += output.basinSize
            visited = output.visited

    result = (size, visited)

proc getBasinSizes(heightmap: seq[seq[int]], lows: seq[tuple[x: int, y: int]], visited: Table[tuple[x: int, y: int], bool], size: int): seq[int] =
    var visited: Table[tuple[x: int, y: int], bool] = visited
    for tRoot in lows:
        var output: tuple[basinSize: int, visited: Table[tuple[x: int, y: int], bool]] = findBasinSize(heightmap, tRoot, visited, size)
        result.add(output.basinSize)
        visited = output.visited
    result.sort()
    echo result

let data = getInput("test_input.txt")
echo "Part 1 Solution: " & $sumRiskLevels(findLows(data), data)

var visited: Table[tuple[x: int, y: int], bool]
echo "Part 2 Solution: " & $foldl(getBasinSizes(data, findLows(data), visited, 0), a * b) 
