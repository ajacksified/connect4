#!/usr/bin/env node

// Just because we're in a bin file doesn't mean we can't write proper
// javascript. IEFE++
!function(require, process){
  'use strict';

  // The game board is built in coffeescript.
  require('coffee-script');

  // Readline is what we use for terminal prompts. CLC gives us ANSI terminal
  // colors, so we can color players. The grid is a modular game grid, not
  // specific to any implementation (such as this.) Optimist is a really cool
  // utility for passing in CLI args, in our case, width, height, and number of
  // players. We then shuffle an array of colors so we can get a new set each 
  // game.
  var readline = require('readline'),
      clc = require('cli-color'),
      Connect4Grid = require('./connect'),
      args = require('optimist')
        .usage("connect4 -w [num] -h [num] -p [num]")
        .default({ w: 7, h: 6, p: 2 }),
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
      rl, grid, setPrompt, finish, colorize, argv;

  argv = args.argv;

  // If we pass in --help, just write the details and quit.
  if(argv.help){
    process.stdout.write(args.help());
    process.exit(0);
  }

  rl = readline.createInterface(process.stdin, process.stdout);
  grid = new Connect4Grid(argv.w, argv.h, argv.p);

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
    process.stdout.write("\n----------------\nGAME OVER: " +
        (player || colorize(grid.getCurrentPlayer())) + " won in " +
        grid.getTurns() + " turns!\n");

    process.exit(0);
  };

  // This event is called each time a player enters something and hits enter.
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
  }).on('close', function() { //fired if one hits ctrl-c
    finish("nobody");
  });

  process.stdout.write(grid.toString() + "\n");
  setPrompt();

}(require, process);
