package {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import com.junkbyte.console.Cc;
	import flash.utils.Timer;
	
	public class P2P extends EventDispatcher implements IServer {
		
		private var _XColor: uint;
		private var _OColor: uint;
		
		public var lastMoveCoord: Object = { };
		
		private var player: Player;
		private var _gameState: String; //Текущий этап игры (константа ServerStrings.GAME_STATE_...)
		private var _currentPlayer: String;
		
		private var netConnection: NetConnection = new NetConnection();
		public var lobby: P2PLobby;
		
		private var temp: Object = new Object(); //Сюда складываются временные переменные
		private var huiTimer:Timer;
		
		public function P2P(player: Player) {
			this.player = player;
			_gameState = ServerStrings.GAME_STATE_NOT_STARTED;
			_currentPlayer = ServerStrings.PLAYER_ROLE_X;
			//player.role = ServerStrings.PLAYER_ROLE_X;
			lobby = new P2PLobby(netConnection);
			lobby.addEventListener(P2PEvent.GROUP_CONNECTED, onLobbyConnected);
			huiTimer = new Timer(300, 6);
			function onLobbyConnected(e: P2PEvent):void {
				Cc.logch('P2P', 'lobby connected (peerID: ' + lobby.peerID + ')');
				Cc.warn('5_auto_messages!');
				huiTimer.addEventListener(TimerEvent.TIMER, onHuiTimer);
				huiTimer.start();
			}
			function onHuiTimer(e:TimerEvent):void {
				var obj:Object = new Object();
				obj['msg'] = '5auto';
				lobby.post(P2PSettings.P2P_REGULAR_MESSAGE, obj);
				if (huiTimer.currentCount == 5) {
					Cc.log('Wait 1s...');
					huiTimer.removeEventListener(TimerEvent.TIMER, onHuiTimer);
					huiTimer.addEventListener(TimerEvent.TIMER, onHuiTimer2);
					huiTimer.delay = 1500;
				}
			}
			function onHuiTimer2(e:TimerEvent):void {
				Cc.log('START_SEARCH');
				huiTimer.removeEventListener(TimerEvent.TIMER, onHuiTimer2);
				huiTimer.stop();
				startSearch();
			}
		}
		
		public function startSearch():void {
			lobby.addEventListener(P2PEvent.GAME_OPPONENT_FOUND, onOpponentFound);
			lobby.startSearch();
			
			function onOpponentFound(e:P2PEvent):void {
				lobby.removeEventListener(P2PEvent.GAME_OPPONENT_FOUND, onOpponentFound);
				lobby.addEventListener(P2PEvent.GAME_OPPONENT_LEAVE, onOpponentLeave);
				lobby.addEventListener(P2PEvent.GAME_STARTED, onGameStarted);
				lobby.addEventListener(P2PEvent.OPPONENT_COMMAND, onOpponentCommand);
				lobby.startGame();
			}
			function onGameStarted(e:P2PEvent):void {
				lobby.removeEventListener(P2PEvent.GAME_STARTED, onGameStarted);
				player.role = e.info;
				if (player.role == ServerStrings.PLAYER_ROLE_X) {
					_XColor = ShapeManager.PLAYER_CELLS_COLOR;
					_OColor = ShapeManager.OPPONENT_CELLS_COLOR;
					player.color = _XColor;
				} else {
					_XColor = ShapeManager.OPPONENT_CELLS_COLOR;
					_OColor = ShapeManager.PLAYER_CELLS_COLOR;
					player.color = _OColor;
				}
				SoundManager.connectSound.play();
				player.gm.messageViewer.showMessage('Кто-то подключился', 'Игра началась! Вы ' + (e.info == ServerStrings.PLAYER_ROLE_X ? 'крестик' : 'нолик'));
				_gameState = ServerStrings.GAME_STATE_CHOOSE_CELLS;
				dispatchEvent(new ServerEvent(ServerEvent.GAME_STARTED));
			}
			function onOpponentLeave(e:P2PEvent):void {
				player.gm.messageViewer.showMessage('', 'Ваш оппонент вышел из игры!\nФункции рестарта пока нет, для повторной игры нужно перезагрузить страницу');
			}
		}
		
		private function onOpponentCommand(e:P2PEvent):void {
			rcvCmd(e.message['data']);
		}
		
		public function sendCmd(cmd: Object): void {
			var event:ServerEvent;
			switch(cmd.cmd) {
				case ServerStrings.CMD_SET_9_CELLS:
					if (!temp['9cellschoosed']) {
						temp['9cellschoosed'] = true;
						player.gm.gameField.deactivate();
						Cc.logch('Game', 'You choosed 9cells first. Wait for opponent...');
					} else {
						_gameState = ServerStrings.GAME_STATE_MOVES;
						event = new ServerEvent(ServerEvent.OPPONENT_CHOOSED_9_CELLS);
						event.responce['moves'] = temp['9cells'];
						dispatchEvent(event);
					}
					break;
			}
			lobby.sendCmd(cmd);
		}
		
		private function rcvCmd(cmd: Object) {
			var event:ServerEvent;
			switch(cmd['cmd']) {
				case ServerStrings.CMD_SET_9_CELLS:
					if (!temp['9cellschoosed']) {
						temp['9cellschoosed'] = true;
						temp['9cells'] = cmd['moves'];
						Cc.logch('Game', 'Opponent choosed 9cells first.');
					} else {
						_gameState = ServerStrings.GAME_STATE_MOVES;
						event = new ServerEvent(ServerEvent.OPPONENT_CHOOSED_9_CELLS);
						event.responce['moves'] = cmd['moves'];
						dispatchEvent(event);
					}
					break;
				case ServerStrings.CMD_PLAYER_MOVE:
					//player.clearMove();
					SoundManager.moveSound.play();
					lastMoveCoord = cmd.move;
					event = new ServerEvent(ServerEvent.PLAYER_MOVE);
					event.responce.move = cmd['move'];
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
				case ServerStrings.CHAT_MESSAGE:
					Cc.logch('Chat', '>> ' + cmd['msg']);
					break;
				case ServerStrings.VIEWER_MESSAGE:
					player.gm.messageViewer.showMessage('', cmd['msg']);
					break;
				default:
					Cc.error('P2P Server recieved unknown command type');
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