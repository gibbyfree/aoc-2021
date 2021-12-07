import strutils, sequtils, tables, os, times


proc getInput(fileName: string): CountTable[int] = 
    var nums: seq[int] = readFile(fileName).strip().split(',').map(parseInt)
    for n in nums:
        result.inc(n)
        
proc cycleFishies(fish: CountTable[int], n: int): CountTable[int] =
    var currFish: CountTable[int] = fish
    for i in 1 .. n:
        var newCounts: CountTable[int]
        for k in countdown(8, 0):
            var fishHere: int = currFish[k]
            if k == 0: # flip to 6, create new fish
                newCounts.inc(6, fishHere)
                newCounts.inc(8, fishHere)
            else: # standard case, i think
                newCounts.inc(k - 1, fishHere)
        currFish = newCounts
    result = currFish

proc countFish(fish: CountTable[int]): int =
    for v in values(fish):
        result += v
        
let data = getInput("input.txt")
let processedFish = cycleFishies(data, 80)
let megaProcessedFish = cycleFishies(data, 256)
echo "Part 1 Solution: " & $countFish(processedFish)
echo "Part 2 Solution: " & $countFish(megaProcessedFish)