import strutils, sequtils

type
    Position = object
        x: int
        y: int

proc getInput(fileName: string): seq[tuple[startPos: Position, endPos: Position]] =
    var strPos: seq[string] = readFile(fileName).strip().splitLines()
    for str in strPos:
        var rawPos: seq[string] = str.split("->")
        var posTuple: tuple[startPos: Position, endPos: Position]
        var posSeq: seq[Position] # this is stupid.
        for pos in rawPos:
            var cleanedPos: seq[int] = pos.strip().split(",").map(parseInt)
            posSeq.add(Position(x: cleanedPos[0], y: cleanedPos[1]))
        posTuple = (posSeq[0], posSeq[1])
        result.add(posTuple)

proc findMaxVal(positions: seq[tuple[startPos: Position, endPos: Position]], forX: bool): int =
    var max: int = low(int)
    for posTup in positions:
        # it is possible to iterate through tuples in nim, but i can't deal with that right now.
        if forX:
            if posTup.startPos.x > max:
                max = posTup.startPos.x
            if posTup.endPos.x > max:
                max = posTup.endPos.x
        else:
            if posTup.startPos.y > max:
                max = posTup.startPos.y
            if posTup.endPos.y > max:
                max = posTup.endPos.y
    result = max

proc processPositions(positions: seq[tuple[startPos: Position, endPos: Position]], xSize: int, ySize: int): seq[seq[int]] =
    var board: seq[seq[int]] = newSeqWith(xSize + 1, newSeqWith(ySize + 1, 0))
    for posTup in positions:
        if posTup.startPos.x == posTup.endPos.x: # vertical
            var lineLength: int = abs(posTup.startPos.y - posTup.endPos.y)
            if posTup.startPos.y > posTup.endPos.y: # draw down
                for i in 0 .. lineLength:
                    board[posTup.startPos.x][posTup.startPos.y - i] += 1
            else:
                for i in 0 .. lineLength:
                    board[posTup.startPos.x][posTup.startPos.y + i] += 1
        elif posTup.startPos.y == posTup.endPos.y: # horizontal
            var lineLength: int = abs(posTup.startPos.x - posTup.endPos.x)
            if posTup.startPos.x > posTup.endPos.x: # draw left
                for i in 0 .. lineLength:
                    board[posTup.startPos.x - i][posTup.startPos.y] += 1
            else:
                for i in 0 .. lineLength:
                    board[posTup.startPos.x + i][posTup.startPos.y] += 1
    result = board

# x1 - x2 = y1 - y2
proc isDiagonal(startPos: Position, endPos: Position): bool =
    result = abs(startPos.x - endPos.x) == abs(startPos.y - endPos.y)

proc processPositionsWithDiagonal(positions: seq[tuple[startPos: Position, endPos: Position]], xSize: int, ySize: int): seq[seq[int]] =
    var board: seq[seq[int]] = newSeqWith(xSize + 1, newSeqWith(ySize + 1, 0))
    for posTup in positions:
        if posTup.startPos.x == posTup.endPos.x: # vertical
            var lineLength: int = abs(posTup.startPos.y - posTup.endPos.y)
            if posTup.startPos.y > posTup.endPos.y: # draw down
                for i in 0 .. lineLength:
                    board[posTup.startPos.x][posTup.startPos.y - i] += 1
            else:
                for i in 0 .. lineLength:
                    board[posTup.startPos.x][posTup.startPos.y + i] += 1
        elif posTup.startPos.y == posTup.endPos.y: # horizontal
            var lineLength: int = abs(posTup.startPos.x - posTup.endPos.x)
            if posTup.startPos.x > posTup.endPos.x: # draw left
                for i in 0 .. lineLength:
                    board[posTup.startPos.x - i][posTup.startPos.y] += 1
            else:
                for i in 0 .. lineLength:
                    board[posTup.startPos.x + i][posTup.startPos.y] += 1
        elif isDiagonal(posTup.startPos, posTup.endPos): # diagonal
            var lineLength: int = abs(posTup.startPos.x - posTup.endPos.x) # i guess?
            if posTup.startPos.x < posTup.endPos.x and posTup.startPos.y < posTup.endPos.y: 
                for i in 0 .. lineLength:
                    board[posTup.startPos.x + i][posTup.startPos.y + i] += 1
            elif posTup.startPos.x > posTup.endPos.x and posTup.startPos.y < posTup.endPos.y: 
                for i in 0 .. lineLength:
                    board[posTup.startPos.x - i][posTup.startPos.y + i] += 1
            elif posTup.startPos.x > posTup.endPos.x and posTup.startPos.y > posTup.endPos.y:
                for i in 0 .. lineLength:
                    board[posTup.startPos.x - i][posTup.startPos.y - i] += 1
            elif posTup.startPos.x < posTup.endPos.x and posTup.startPos.y > posTup.endPos.y:
                for i in 0 .. lineLength:
                    board[posTup.startPos.x + i][posTup.startPos.y - i] += 1

    result = board

proc countLines(board: seq[seq[int]]): int =
    for row in board:
        for val in row:
            if val > 1:
                result += 1

let data: seq[tuple[startPos: Position, endPos: Position]] = getInput("input.txt")
let xSize: int = findMaxVal(data, true)
let ySize: int = findMaxVal(data, false)
let filledBoard: seq[seq[int]] = processPositions(data, xSize, ySize)
let filledDiagBoard: seq[seq[int]] = processPositionsWithDiagonal(data, xSize, ySize)

echo "Part 1 Solution: " & $countLines(filledBoard)
echo "Part 2 Solution: " & $countLines(filledDiagBoard)