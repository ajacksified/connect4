# So basically how this is organized-
#
# 1. Minimum cyclomatic complexity; less if checks and loops is better
# 2. Minimum width lines; less complex statements are better
# 3. Reusable interface; the grid class should be reusable, and private
#    functions are hidden from the public interface
# 4. Minimum magic strings and numbers; most options should be passed in
#    and configurable.
#
# These choices were made at a higher priority than optimization or brevity.

# Basically a one-liner for checking wins, instead of setting up counters and
# stuff.
isWinForRow = (row, player) ->
  reg = new RegExp("(#{player},?){4}")
  return row.join(",").match(reg)

# Take a given row, and pass it into the row tester.
isHorizontalWin = (row, grid, player) ->
  return isWinForRow(grid[row], player)

# Make a row out of a vertical column, and pass it on in.
isVerticalWin = (column, grid, player) ->
  columnCells = (grid[row][column] for row in [0...grid.length])
  return isWinForRow(columnCells, player)

# Make two rows (and quit early if the first one works); figure out the vector
# path from the bottom left and the top left that crosses the coordinates we
# pass in.
isDiagonalWin = (row, column, grid, player) ->
  diagonalBottomLeft = []

  delta = Math.min(row, column)
  startingRow = row - delta
  startingColumn = column - delta
  notEdge = true

  while notEdge
    diagonalBottomLeft.push(grid[startingRow][startingColumn])
    startingRow++
    startingColumn++
    notEdge = !(grid.length == startingRow || grid[0].length == startingColumn)

  return true if isWinForRow(diagonalBottomLeft, player)

  diagonalTopLeft = []
  delta = Math.max(Math.min(grid[0].length - 1 - row, column) - 1, 0)
  startingRow = row + delta
  startingColumn = column - delta
  notEdge = true

  while notEdge
    diagonalTopLeft.push(grid[startingRow][startingColumn])
    startingRow--
    startingColumn++
    notEdge = !(startingRow < 0 || grid[0].length == startingColumn)

  return true if isWinForRow(diagonalTopLeft, player)

  return false

# Drop into the given column, but error if the column is full or if the value
# passed in is out of bounds or invalid.
drop = (column, grid, xSize, ySize, player, callback) ->
  return callback("Invalid column #{column}; out of range!") if column < 1 || column > xSize

  column = column - 1

  for i in [0...ySize]
    if grid[i][column] == undefined
      grid[i][column] = player
      return callback(null, { grid: grid, column: column, row: i })

  callback("Invalid column #{column + 1}; that column is full!")

# Run our win conditions, and return the result.
isWin = (row, column, grid, player) ->
  return true if isHorizontalWin(row, grid, player)
  return true if isVerticalWin(column, grid, player)
  return true if isDiagonalWin(row, column, grid, player)

  return false

# Just a quick check.
isLastTurn = (grid, turns) ->
  return grid.length * grid[0].length == turns

class Connect4Grid
  constructor: (@xSize, @ySize, @players, @options) ->
    @grid = new Array(@ySize)
    @currentPlayerIndex = 0
    @turns = 0

    for i in [0...@ySize]
      @grid[i] = new Array(@xSize)

  turn: (column, callback) ->
    player = @getCurrentPlayer()

    grid = drop(column, @grid, @xSize, @ySize, player, (err, data) =>
      return callback(err) if err

      @grid = data.grid
      row = data.row

      @turns++

      return callback(null, { winner: player, turns: @turns }) if isWin(row, column - 1, @grid, player)
      return callback(null, { winner: "nobody", turns: @turns }) if isLastTurn(@grid, @turns)

      @currentPlayerIndex++

      if @currentPlayerIndex == @players
        @currentPlayerIndex = 0

      callback(null, false)
    )

  toString: (playerFormat) ->
    grid = []
    grid.push(row) for row in @grid
    grid.reverse()

    text = []

    for row, i in grid
      cellText = []
      blank = " "

      for cell, j in row
        t = cell || blank
        t = playerFormat(t) if playerFormat

        cellText.push(t)

      text.push(cellText.join(blank))

    text.push(("-" for i in [1..@xSize]).join("-"))
    text.push([1..@xSize].join(blank))
    return text.join("\n")

  getCurrentPlayer: () ->
    @currentPlayerIndex + 1 + ""

  getTurns: ->
    @turns

module.exports = Connect4Grid
