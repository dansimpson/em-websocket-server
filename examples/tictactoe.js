// Author: Jordan Fowler

var currentGame = null;

var TicTacToe = new Class({
  methodMap: {
    'queued': 'onQueued',
    'start': 'onStart',
    'turn': 'onTurn',
    'move': 'onMove',
    'game_over': 'onGameOver'
  },

  initialize: function() {
    if (TicTacToe.connection == null) {
      TicTacToe.connection = new WebSocket('ws://192.168.0.2:8000/tictactoe');
    };

    TicTacToe.connection.onopen = this.onJoin.bind(this);
    TicTacToe.connection.onmessage = this.onMessage.bind(this);
    TicTacToe.connection.onclose = this.onGameOver.bind(this);
  },

  onMessage: function(event) {
    var command = JSON.decode(event.data);

    console.log('[RCV] ' + command.msg);

    this[this.methodMap[command.msg]].call(this, [command]);
  },

  onJoin: function(event) {
    console.log('[SENT] join game');

    TicTacToe.connection.send(JSON.encode({msg: 'join'}));
  },

  onQueued: function(command) {
    
  },

  onStart: function(command) {
    
  },

  onTurn: function(command) {
    
  },

  onMove: function(command) {
    
  },

  onGameOver: function(command) {
    
  }
});

$('join-game').addEvent('click', function(event) {
  currentGame = new TicTacToe();
});

