import strutils, sequtils

proc getInput(fileName: string): seq[int] =
    var strNums = readFile(fileName).strip().splitLines()
    result = strNums.map(parseInt)

proc findIncreases(nums: seq[int]): int =
    for i in 1 .. nums.len - 1:
        if nums[i] > nums[i - 1]:
            result += 1

proc findIncreasesInWindow(nums: seq[int]): int =
    var prevWindow: int = nums[0] + nums[1] + nums[2];
    for i in 3 .. nums.len - 1:
        var curWindow: int = nums[i - 2] + nums[i - 1] + nums[i];
        if curWindow > prevWindow:
            result += 1
        prevWindow = curWindow;

let dataOne = getInput("input.txt")
let dataTwo = getInput("input2.txt")
echo "Part 1 solution: " & $findIncreases(dataOne)
echo "Part 2 solution: " & $findIncreasesInWindow(dataTwo)