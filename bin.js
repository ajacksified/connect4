#!/usr/bin/env node

!function(require, process){
  'use strict';

  require('coffee-script');

  var readline = require('readline'),
      clc = require('cli-color'),
      Connect4Grid = require('./connect'),
      argv = require('optimist')
        .usage('Usage: connect4 -w [num] -h [num] -p [num]')
        .boolean('c')
        .default('w', 7)
        .default('h', 6)
        .default('p', 2)
        .argv,
      colors = ['bgRed', 'bgGreen', 'bgYellow', 'bgBlue', 'bgMagenta', 'bgCyan'],
      shuffle = function(array){
        var top = array.length, current, tmp;

        if(top){
          while(--top){
            current = Math.floor(Math.random() * (top + 1));
            tmp = array[current];
            array[current] = array[top];
            array[top] = tmp;
          }
        }
        return array;
      },
      blank = clc.bgBlack(" "),
      rl, grid, setPrompt, finish, colorize;

  rl = readline.createInterface(process.stdin, process.stdout);
  grid = new Connect4Grid(argv.w, argv.h, argv.p, { color: argv.c });

  colorize = function(player){
    if(colors[player]){
      return clc[colors[player]](player);
    }else{
      return player;
    }
  };

  setPrompt = function(){
    rl.setPrompt('Drop ' + colorize(grid.getCurrentPlayer(true)) + ' in column > ');
    rl.prompt();
  };

  finish = function(player){ 
    process.stdout.write("\n----------------\nGAME OVER: " + (player || colorize(grid.getCurrentPlayer())) + " won in " + grid.getTurns() + " turns!\n");
    process.exit(0);
  };

  rl.on('line', function(line) {
    var column = parseInt(line, 10);

    if(isNaN(column)){
      process.stdout.write("Please choose a number 1-" + argv.w + "\n");
      return setPrompt();
    }

    grid.turn(column, function(err, win){
      if(err){
        process.stdout.write(err + "\n");
      }else{
        process.stdout.write(grid.toString(colorize) + "\n");

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
