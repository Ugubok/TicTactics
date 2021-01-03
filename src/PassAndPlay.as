package {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import com.junkbyte.console.Cc;
	
	public class PassAndPlay extends EventDispatcher implements IServer {
		
		private const _XColor: uint = ShapeManager.PLAYER_CELLS_COLOR;
		private const _OColor: uint = 0x1560BD;
		
		public var lastMoveCoord: Object = { };
		
		private var player: Player;
		private var _gameState: String; //Текущий этап игры (константа ServerStrings.GAME_STATE_...)
		private var _currentPlayer: String;
		
		private var temp: Object = new Object(); //Сюда складываются временные переменные
		
		public function PassAndPlay(player: Player) {
			this.player = player;
			_gameState = ServerStrings.GAME_STATE_NOT_STARTED;
			Cc.logch('Game', 'Server changed gamestate to ' + ServerStrings.GAME_STATE_NOT_STARTED);
			_currentPlayer = ServerStrings.PLAYER_ROLE_X;
			player.role = ServerStrings.PLAYER_ROLE_X;
		}
		
		public function sendCmd(cmd: Object): void {
			switch(cmd.cmd) {
				case ServerStrings.CMD_GAME_START:
					_gameState = ServerStrings.GAME_STATE_CHOOSE_CELLS;
					Cc.logch('Game', 'Server changed gamestate to ' + ServerStrings.GAME_STATE_CHOOSE_CELLS);
					dispatchEvent(new ServerEvent(ServerEvent.GAME_STARTED));
					break;
				case ServerStrings.CMD_SET_9_CELLS:
					if (player.role == ServerStrings.PLAYER_ROLE_X) {
						temp.playerX9Cells = cmd.moves; //Сохраняем ходы первого игрока для последующего слияния ходов
						player.role = ServerStrings.PLAYER_ROLE_O;
						player.color = _OColor;
						player.opponentColor = _XColor;
						var event: ServerEvent = new ServerEvent(ServerEvent.OPPONENT_CHOOSED_9_CELLS);
						event.responce.moves = cmd.moves;
						dispatchEvent(event);
						//player.clearMove();
						dispatchEvent(new ServerEvent(ServerEvent.GAME_STARTED)); //Повторный выбор 9 клеток
					} else {
						_gameState = ServerStrings.GAME_STATE_MOVES;
						Cc.logch('Game', 'Server changed gamestate to ' + ServerStrings.GAME_STATE_MOVES);
						event = new ServerEvent(ServerEvent.OPPONENT_CHOOSED_9_CELLS);
						event.responce.moves = temp.playerX9Cells;
						dispatchEvent(event);
						player.role = ServerStrings.PLAYER_ROLE_X;
						player.color = _XColor;
						player.opponentColor = _OColor;
						event.responce.moves = { };
						dispatchEvent(event); //Заставляем Game сделать первый ход.
					}
					break;
				case ServerStrings.CMD_PLAYER_MOVE:
					//player.clearMove();
					lastMoveCoord = cmd.move;
					player.color = (player.role == ServerStrings.PLAYER_ROLE_X) ? _OColor : _XColor;
					player.opponentColor = (player.role == ServerStrings.PLAYER_ROLE_X) ? _XColor : _OColor;
					player.role = (player.role == ServerStrings.PLAYER_ROLE_X) ? ServerStrings.PLAYER_ROLE_O : ServerStrings.PLAYER_ROLE_X;
					event = new ServerEvent(ServerEvent.PLAYER_MOVE);
					event.responce.move = cmd.move;
					dispatchEvent(event);
					break;
				case ServerStrings.CMD_END_GAME:
					if (_gameState == ServerStrings.GAME_STATE_CONTINUE) return;
					_gameState = ServerStrings.GAME_STATE_CONTINUE;
					event = new ServerEvent(ServerEvent.GAME_OVER);
					event.responce.reason = cmd.reason;
					if (cmd.winner) event.responce.winner = cmd.winner;
					dispatchEvent(event);
					break;
			}
		}
		
		public function get gameState(): String {
			return _gameState;
		}
		
		public function get currentPlayer(): String {
			return _currentPlayer;
		}
		
		public function get XColor(): uint {
			return _XColor;
		}
		
		public function get OColor(): uint {
			return _OColor;
		}
	}
	
}