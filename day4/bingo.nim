import strutils, sequtils

proc getInput(fileName: string): tuple[commands: seq[int], boards: seq[seq[seq[int]]]] =
    var strNums = readFile(fileName).strip().splitLines()
    # parse out commands
    var commandSeq: seq[int] = strNums[0].split(',').map(parseInt)
    strNums.delete(0..0)
    # parse out 5x5 boards
    var boardSeq: seq[seq[seq[int]]]
    strNums.keepItIf(it != "") # remove blank lines

    var globalIdx: int = 0
    var localIdx: int = 0
    var currSeq: seq[seq[int]]
    while true:
        if globalIdx == strNums.len - 1:
            break;
        if localIdx < 5:
            var rowSeq: seq[int] = strNums[globalIdx].split(' ').filterIt(it.len != 0).map(parseInt)
            currSeq.add(rowSeq)
            localIdx += 1
            globalIdx += 1
        else: # this board is complete
            boardSeq.add(currSeq)
            localIdx = 0
            currSeq.setLen(0) # I'm sure there's a better way to clear a seq, but can't find atm
            continue
    
    result = (commandSeq, boardSeq)

proc generateRow(idx: int, row: seq[int]): seq[int] =
    for i in 0 .. 4:
        if (i == idx):
            result.add(-2) # we will mark spaces like this
        else:
            result.add(row[i])

proc checkBoards(drawn: int, boards: seq[seq[seq[int]]]): seq[seq[seq[int]]] =
    for board in boards:
        var checkedBoard: seq[seq[int]]
        for row in board:
            var idx: int = find(row, drawn)
            var checkedRow: seq[int] = generateRow(idx, row)
            checkedBoard.add(checkedRow)
        result.add(checkedBoard)

proc calculateWinningScore(board: seq[seq[int]]): int =
    for row in board:
        for space in row:
            if (space != -2):
                result += space

proc checkRow(board: seq[seq[int]]): int =
    for i in 0 .. board.len - 1: # check row
        var rowSum: int = foldl(board[i], a + b)
        if (rowSum == -10):
            result = -1
            break;

proc transpose(s: seq[seq[int]]): seq[seq[int]] = # don't care to figure out how to do this with map()
  result = newSeq[seq[int]](s[0].len)
  for i in 0 .. s[0].high:
    result[i] = newSeq[int](s.len)
    for j in 0 .. s.high:
      result[i][j] = s[j][i]
    
proc checkForWinner(boards: seq[seq[seq[int]]]): int =
    for board in boards:
        var rowOutcome: int = checkRow(board)
        var flippedBoard: seq[seq[int]] = transpose(board)
        var colOutcome: int = checkRow(flippedBoard)

        if colOutcome == -1 or rowOutcome == -1:
            result = calculateWinningScore(board)
            break;

proc boardLoop(commands: seq[int], boards: seq[seq[seq[int]]]): int =
    var currBoards: seq[seq[seq[int]]] = boards
    for s in commands:
        var checkedBoards: seq[seq[seq[int]]] = checkBoards(s, currBoards)
        var winningScore: int = checkForWinner(checkedBoards)
        if (winningScore != 0):
            result = winningScore * s
            break
        currBoards = checkedBoards

proc checkAndCleanBoards(drawn: int, boards: seq[seq[seq[int]]]): seq[seq[seq[int]]] =
    for board in boards:
        var checkedBoard: seq[seq[int]]
        # check if this board has won already
        var rowOutcome: int = checkRow(board)
        var flippedBoard: seq[seq[int]] = transpose(board)
        var colOutcome: int = checkRow(flippedBoard)

        if colOutcome != -1 and rowOutcome != -1:
            for row in board:
                var idx: int = find(row, drawn)
                var checkedRow: seq[int] = generateRow(idx, row)
                checkedBoard.add(checkedRow)
            result.add(checkedBoard)

proc boardLoopLastWinner(commands: seq[int], boards: seq[seq[seq[int]]]): int =
    var currBoards: seq[seq[seq[int]]] = boards
    for s in commands:
        var checkedBoards: seq[seq[seq[int]]] = checkAndCleanBoards(s, currBoards)
        var winningScore: int = checkForWinner(checkedBoards)
        if (winningScore != 0):
            result = winningScore * s
        currBoards = checkedBoards

let data = getInput("input.txt")
echo "Part 1 Score: " & $boardLoop(data.commands, data.boards)
echo "Part 2 Score: " & $boardLoopLastWinner(data.commands, data.boards)