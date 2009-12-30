// Author: Jordan Fowler (TheBreeze)

var TicTacToe = new Class({
  wins: 0,
  loses: 0,
  draws: 0,
  methodMap: {
    'queued': 'onQueued',
    'start': 'onStart',
    'turn': 'onTurn',
    'move': 'onMove',
    'game_over': 'onGameOver',
    'win': 'onWin',
    'loss': 'onLoss',
    'draw': 'onDraw',
    'user_count': 'onUserCount'
  },

  initialize: function() {
    if (TicTacToe.connection == null) {
      TicTacToe.connection = new WebSocket('ws://localhost:8000/tictactoe');
    };

    TicTacToe.connection.onopen = this.join.bind(this);
    TicTacToe.connection.onmessage = this.onMessage.bind(this);
    TicTacToe.connection.onclose = this.onGameOver.bind(this);

    this.setGameStats();
  },

  onMessage: function(event) {
    var command = JSON.decode(event.data);

    console.log('[RCV] ' + command.msg);

    this[this.methodMap[command.msg]].call(this, command);
  },

  message: function(msg, options) {
    var command = JSON.encode({msg: msg, data: options});

    console.log('[SENT] ' + msg);

    TicTacToe.connection.send(command);
  },

  setStatus: function(status) {
    $('status').set('text', status);
  },

  setGameStats: function() {
    $('game-stats').set('text', 'Wins: '+this.wins+' / Losses: '+this.wins+' / Draws: '+this.draws);
  },

  setUserCount: function(userCount) {
    $('user-count').set('text', 'Number of players: ' + userCount);
  },

  join: function(event) {
    this.message('join');

    this.setStatus('Connecting you to a game...');
  },

  reset: function() {
    $$('.cell').set('text', '');

    this.join();
  },

  onQueued: function(command) {
    this.setStatus('Waiting for another player...');
  },

  onStart: function(command) {
    this.setStatus('Game found! Their turn first...');
  },

  onTurn: function(command) {
    this.setStatus('Your turn...');
  },

  onMove: function(command) {
    $('cell-'+command.data.x+'-'+command.data.y).set('text', command.key);

    this.setStatus('Their turn...');
  },

  move: function(x, y) {
    this.message('move', {x: x, y: y});
  },

  onGameOver: function(command) {
    this.setStatus('Game over.');
    this.setGameStats();
    this.reset();
  },

  onWin: function(command) {
    this.wins += 1;
    this.setStatus('Game over. You win!');
    this.setGameStats();
  },

  onLoss: function(command) {
    this.losses += 1;
    this.setStatus('Game over. You lose!');
    this.setGameStats();
  },

  onDraw: function(command) {
    this.draws += 1;
    this.setStatus('Game over. It was a draw!');
    this.setGameStats();
  },

  onUserCount: function(command) {
    this.setUserCount(command.data);
  }
});

$$('.cell').addEvent('click', function(event) {
  try {
    currentGame.move($(this).get('id').split('-')[1], $(this).get('id').split('-')[2]);
  } catch(error) {
    alert('Please wait while we connect you to a game...');
  }
});

currentGame = new TicTacToe();