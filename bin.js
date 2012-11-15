#!/usr/bin/env node

!function(require, process){
  'use strict';

  require('coffee-script');

  var readline = require('readline'),
      Connect4Grid = require('./connect'),
      argv = require('optimist')
        .usage('Usage: connect4 -w [num] -h [num] -p [num]')
        .boolean('c')
        .default('w', 7)
        .default('h', 6)
        .default('p', 2)
        .argv,
      rl, grid, setPrompt, finish;

  rl = readline.createInterface(process.stdin, process.stdout);
  grid = new Connect4Grid(argv.w, argv.h, argv.p, { color: argv.c });

  setPrompt = function(){
    rl.setPrompt('Drop ' + grid.getCurrentPlayer(true) + ' in column > ');
    rl.prompt();
  };

  finish = function(player){ 
    process.stdout.write("\n----------------\nGAME OVER: " + (player || grid.getCurrentPlayer(true)) + " won in " + grid.getTurns() + " turns!\n");
    process.exit(0);
  };

  rl.on('line', function(line) {
    var column = parseInt(line, 10);

    grid.turn(column, function(err, win){
      if(err){
        process.stdout.write(err + "\n");
      }else{
        process.stdout.write(grid.toString() + "\n");

        if(win){
          return finish();
        }
      }

      setPrompt();
    });
  }).on('close', function() {
    finish("nobody");
  });

  process.stdout.write(grid.toString() + "\n");
  setPrompt();

}(require, process);
