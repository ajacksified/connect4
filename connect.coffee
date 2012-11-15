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

# Basically a one-liner for checking wins. Hacky, but concise.
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
  # start from the bottom leftmost, edging aginst the bottom or left such that
  # it will intersect
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

  # start from the top leftmost, edging aginst the top or the left
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
  return callback("Invalid column #{column}; out of range!") if column < 0 || column >= xSize

  for i in [0...ySize]
    if grid[i][column] == undefined
      grid[i][column] = player
      return callback(null, { grid: grid, column: column, row: i })

  callback("Invalid column #{column + 1}; that column is full!")

# Run our win conditions, and return the result.
isWin = (row, column, grid, player) ->
  isHorizontalWin(row, grid, player) or
    isVerticalWin(column, grid, player) or
    isDiagonalWin(row, column, grid, player)

# If it's the last turn, we shouldn't go further.
isLastTurn = (grid, turns) ->
  return grid.length * grid[0].length == turns

# All of the above are now private functions; only the functions that need to
# be public will be exposed through Connect4Grid.
class Connect4Grid
  constructor: (@xSize, @ySize, @players, @options) ->
    # Look, an actual use for `new Array`: a bounded-size array.
    @grid = new Array(@ySize)
    @currentPlayerIndex = 0
    @turns = 0

    for i in [0...@ySize]
      @grid[i] = new Array(@xSize)

  # Take a turn - drop into a column and increment the current player,
  # then call back with either an error or null and data about the move.
  turn: (column, callback) ->
    player = @getCurrentPlayer()
    column = column - 1

    grid = drop(column, @grid, @xSize, @ySize, player, (err, data) =>
      return callback(err) if err

      @grid = data.grid
      row = data.row

      @turns++

      # Return immediately if we have a winner or if it's the last turn
      return callback(null, { winner: player, turns: @turns }) if isWin(row, column, @grid, player)
      return callback(null, { winner: "nobody", turns: @turns }) if isLastTurn(@grid, @turns)

      @currentPlayerIndex++
      @currentPlayerIndex = 0 if @currentPlayerIndex == @players

      callback(null, false)
    )

  # Return an ascii representation of the game board, with an optional
  # formatting function that wraps cells. In the bin, we use this to add ansi
  # terminal colors to players, but you might wrap these in span tags or
  # something in html.
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
