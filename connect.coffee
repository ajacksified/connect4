clc = require('cli-color')

shuffle = (array) ->
  top = array.length;

  if top
    while --top
      current = Math.floor(Math.random() * (top + 1))
      tmp = array[current]
      array[current] = array[top]
      array[top] = tmp

  array

colors = shuffle(['bgRed', 'bgGreen', 'bgYellow', 'bgBlue', 'bgMagenta', 'bgCyan'])

resetColor = '\u001b[0m'

winRegex = (row, player) ->
  reg = new RegExp("(#{player},?){4}")
  return row.join(",").match(reg)

isHorizontalWin = (row, grid, player) ->
  return winRegex(grid[row], player)

isVerticalWin = (column, grid, player) ->
  columnCells = (grid[row][column] for row in [0...grid.length])
  return winRegex(columnCells, player)

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

  return true if winRegex(diagonalBottomLeft, player)

  diagonalTopLeft = []
  delta = Math.max(Math.min(grid[0].length - 1 - row, column) - 1, 0)
  startingRow = row + delta
  startingColumn = column - delta
  notEdge = true
  console.log startingRow, startingColumn

  while notEdge
    diagonalTopLeft.push(grid[startingRow][startingColumn])
    startingRow--
    startingColumn++
    notEdge = !(startingRow < 0 || grid[0].length == startingColumn)

  return true if winRegex(diagonalTopLeft, player)

  return false

drop = (column, grid, xSize, ySize, player, callback) ->
  return callback("Invalid column #{column}; out of range!") if column < 1 || column > xSize

  column = column - 1

  for i in [0...ySize]
    if grid[i][column] == undefined
      grid[i][column] = player
      return callback(null, { grid: grid, column: column, row: i })

  callback("Invalid column #{column + 1}; that column is full!")

isWin = (row, column, grid, player) ->
  return true if isHorizontalWin(row, grid, player)
  return true if isVerticalWin(column, grid, player)
  return true if isDiagonalWin(row, column, grid, player)

  return false

lastTurn = (grid, turns) ->
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
      return callback(null, { winner: "nobody", turns: @turns }) if lastTurn(@grid, @turns)

      @currentPlayerIndex++

      if @currentPlayerIndex == @players
        @currentPlayerIndex = 0

      callback(null, false)
    )

  toString: ->
    grid = []
    grid.push(row) for row in @grid
    grid.reverse()

    text = []

    for row, i in grid
      cellText = []
      blank = if @options.color then clc.bgBlack(" ") else " "

      for cell, j in row
        cell = if cell and @options.color then clc.bold(clc.whiteBright(clc[colors[cell]](cell))) else cell
        t = cell || blank

        cellText.push(t)

      text.push(cellText.join(blank))

    text.push(("-" for i in [1..@xSize]).join("-"))
    text.push([1..@xSize].join(blank))
    return text.join("\n")

  getCurrentPlayer: (colored) ->
    player = @currentPlayerIndex + 1 + ""

    if colored and @options.color
      return clc.bold(clc.whiteBright(clc[colors[player]](player)))

    player

  getTurns: ->
    @turns

module.exports = Connect4Grid
