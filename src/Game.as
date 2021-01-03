package {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import forms.NickInput;
	import mx.utils.StringUtil;
	import com.junkbyte.console.Cc;
	
	public class Game {
		
		public var server: IServer;
		private var ServerClass: Class;
		private var player: Player;
		private var gm: GraphicsManager;
		private var blinkedBoard: Board = null;
		private var winner: String;
		private var winCombinations: Array = new Array(8);
		
		public function Game(ServerClass: Class, graphicsManager: GraphicsManager) {
			this.gm = graphicsManager;
			this.ServerClass = ServerClass;
			Cc.log('Game type: ' + ServerClass);
			/*switch(gameMode) {
				case ServerStrings.GAMEMODE_PASSNPLAY:
					server = new PassAndPlay(player = new Player(gm));
					break;
			}*/
			server = new ServerClass(player = new Player(gm));
			gm.addEventListener(GraphicsManager.MOVE_BUTTON_CLICK, onMoveButtonClick);
			gm.gameField.addEventListener(BoardEvents.ON_CELL_CLICK, onCellClick);
			server.addEventListener(ServerEvent.GAME_STARTED, onGameStart);
			server.addEventListener(ServerEvent.OPPONENT_CHOOSED_9_CELLS, onOpponentChoosed9Cells);
			server.addEventListener(ServerEvent.PLAYER_MOVE, onPlayerMove);
			server.addEventListener(ServerEvent.GAME_OVER, onGameOver);
			
			for (var i:int = 0; i < 8; i++) { //Постройка массива winCombinations
				if (i < 3) { //Вертикали
					winCombinations[i] = new Array(new Point(i+1, 1), new Point(i+1, 2), new Point(i+1, 3));
					continue;
				}
				if (i < 6) { //Горизонтали
					winCombinations[i] = new Array(new Point(1, i-2), new Point(2, i-2), new Point(3, i-2));
					continue;
				}
				if (i == 6) { // Диагональ (\)
					winCombinations[i] = new Array(new Point(1, 1), new Point(2, 2), new Point(3, 3));
					continue;
				}
				if (i == 7) { // Диагональ (/)
					winCombinations[i] = new Array(new Point(1, 3), new Point(2, 2), new Point(3, 1));
				}
			}
		}
		
		private function onMoveButtonClick(e: Event): void {
			switch(server.gameState) {
				case ServerStrings.GAME_STATE_CHOOSE_CELLS:
					if (checkMove()) {
						player.stopChoose9Cells();
						var request: Object = new Object();
						request.cmd = ServerStrings.CMD_SET_9_CELLS;
						request.moves = { };
						for (var i:int = 0; i < player.selectedCell.length; i++) {
							request.moves[String(i)] = player.selectedCell[i];
						}
						server.sendCmd(request);
						player.clearMove();
						SoundManager.pressSound.play();
						gm.moveButton.down();
					}
					break;
				case ServerStrings.GAME_STATE_MOVES:
					if (checkMove()) {
						request = new Object();
						request.cmd = ServerStrings.CMD_PLAYER_MOVE;
						request.move = player.selectedCell[0];
						var board: Board = gm.gameField.getBoardByCoord(request.move.board.x, request.move.board.y); //Доска на которой сходили //ПО БОЛЬШОМУ УААХАХХАХУАХ
						var cell: Cell = board.getCellByCoord(request.move.cell.x, request.move.cell.y);
						gm.gameField.deactivate();
						if (blinkedBoard != null) blinkedBoard.stopCellBlink();
						board.startCellBlink(cell, player.color);
						blinkedBoard = board;
						gm.gameField.getBoardByCoord(cell.getCoord().x, cell.getCoord().y).stopHighlight();
						//if (!board.hasOwner() && board.checkWin(player.role)) board.owner = player.role;
						if (!board.hasOwner()) board.owner = board.checkWinner();
						server.sendCmd(request);
						player.clearMove();
						SoundManager.pressSound.play();
						gm.moveButton.down();
						checkEndGame();
					}
			}
			
		}
		
		private function onCellClick(e: BoardEvents): void { //Поднимает и опускает кнопку хода
			if (checkMove()) {
				if (!gm.moveButton.isUp) gm.moveButton.up();
			} else {
				if (gm.moveButton.isUp) gm.moveButton.down();
			}
		}
		
		private function checkMove(): Boolean {
			Cc.logch('Game', 'checkMove: selected ' + player.selectedCell.length + 'cells');
			if (server.gameState == ServerStrings.GAME_STATE_CHOOSE_CELLS) {
				if (player.selectedCell.length == 9) return true;
				else return false;
			} else {
				if (player.selectedCell.length == 1) return true;
			}
			return false;
		}
		
		private function onGameStart(e: ServerEvent): void {
			player.choose9Cells();
		}
		
		private function onOpponentChoosed9Cells(e: ServerEvent): void {
			for each(var move: Object in e.responce.moves) { //Объединение полей происходит здесь
				var board: Board = gm.gameField.getBoardByCoord(move.board.x, move.board.y);
				var cell: Cell = board.getCellByCoord(move.cell.x, move.cell.y);
				if (cell.hasSymbol()) {
					cell.setBlank();
					cell.setColor(board.cellsColor);
				} else {
					cell.setColor( (player.role == ServerStrings.PLAYER_ROLE_X ? server.OColor : server.XColor) );
					(player.role == ServerStrings.PLAYER_ROLE_X) ? cell.setO() : cell.setX();
				}
			}
			gm.gameField.deactivate();
			if (player.role == ServerStrings.PLAYER_ROLE_X) { //Первый ход после выбора 9 ячеек
				//В первом ходе нельзя допускать занятия игроком доски
				function checkWin(combination: String): Boolean {
					for (var i:int = 0; i < 3; i++) { //Проверка по горизонтали
						if (combination.substr(i * 3, 3) == '111') return true;
					}
					for (i = 0; i < 3; i++) { //Проверка по вертикали
						if (combination.charAt(i) + combination.charAt(i + 3) + combination.charAt(i + 6) == '111' ) return true;
					}
					if (combination.charAt(0) + combination.charAt(4) + combination.charAt(8) == '111' ) return true;
					if (combination.charAt(2) + combination.charAt(4) + combination.charAt(6) == '111' ) return true;
					return false;
				}
				gm.gameField.activate(true, true);
				gm.gameField.forEach(function(board: Board): void {
					var currentCombination: String = '';
					for (var i:int = 0; i < board.cellsArr.length; i++) { //Формируем строку с текущей комбинацией
						currentCombination += (board.cellsArr[i].owner == player.role) ? '1' : '0';
					}
					var oldCombination: String = currentCombination;
					for (i = 0; i < board.cellsArr.length; i++) { //Опускаем ячейки с выигрышной комбинацией
						if (board.cellsArr[i].hasSymbol()) continue; //Пропускаем занятые ячейки
						currentCombination = currentCombination.substr(0, i) + '1' + currentCombination.substr(i+1, currentCombination.length - i);
						if (checkWin(currentCombination)) {
							board.cellsArr[i].down();
							return;
						}
						currentCombination = oldCombination;
					}
				});
				player.move();
			}
		}
		
		private function onPlayerMove(e: ServerEvent): void {
			var move: Object = e.responce['move'];
			var board: Board = gm.gameField.getBoardByCoord(move.board.x, move.board.y);
			var cell: Cell = board.getCellByCoord(move.cell.x, move.cell.y);
			if (!board.hasOwner()) {
				if (board.checkWinner() == 'XO') { //Если доска стала общей
					board.setCellsColor(ShapeManager.COMMON_CELLS_COLOR);
				} else { 
					cell.setColor(player.opponentColor);					
				}
			}
			if (player.role == ServerStrings.PLAYER_ROLE_X) cell.setO();
			else cell.setX();
			if (blinkedBoard != null && blinkedBoard != board) blinkedBoard.stopCellBlink();
			board.startCellBlink(cell, (player.role == ServerStrings.PLAYER_ROLE_X) ? server.OColor : server.XColor);
			blinkedBoard = board;
			if (!board.hasOwner() && board.checkWin(player.opponentRole)) { //Если соперник занял доску
				board.setCellsColor(player.opponentColor);
				board.owner = player.opponentRole;
			}
			if (checkEndGame()) return;
			var moveBoard: Board = gm.gameField.getBoardByCoord(cell.getCoord().x, cell.getCoord().y)
			if (moveBoard.getCheckedCellsCount() < 9) {
				player.move(moveBoard);
			} else {
				gm.gameField.activate();
				player.move();
			}
		}
		
		private function onGameOver(e: ServerEvent): void {
			var reason: String = e.responce.reason;
			Cc.logch('Game', 'Game Over! Reason: ' + reason);
			switch(reason) { //Тут идет разбор причины, присланной ОППОНЕНТОМ, потому тут такая ахинея.
				case ServerStrings.END_GAME_REASON_LOSE:
					gm.messageViewer.showMessage('Вы выиграли!', 'Функции рестарта пока нет, для повторной игры нужно перезагрузить страницу');
					break;
				case ServerStrings.END_GAME_REASON_WIN:
					gm.messageViewer.showMessage('Вы проиграли!', 'Функции рестарта пока нет, для повторной игры нужно перезагрузить страницу');
					break;
				case ServerStrings.END_GAME_REASON_DRAWN:
					gm.messageViewer.showMessage('Ничья!', 'Функции рестарта пока нет, для повторной игры нужно перезагрузить страницу');
					break;
			}
			if (reason != ServerStrings.END_GAME_REASON_DRAWN) {
				var finishBoardCoord: Point = new Point((server as ServerClass).lastMoveCoord.board.x, (server as ServerClass).lastMoveCoord.board.y);
				var finishCell: Cell = gm.gameField.getBoardByCoord(finishBoardCoord.x, finishBoardCoord.y).getCellByCoord(
					(server as ServerClass).lastMoveCoord.cell.x, (server as ServerClass).lastMoveCoord.cell.y);
				var winnerBoards: Array = [];
				var eqCount: int;
				var curCoord: Point;
				var curComb: Array;
				var highlightColor: uint = //Цвет, которым будем подсвечивать выигрышную комбинацию досок
					(winner == ServerStrings.PLAYER_ROLE_X) ? (server as ServerClass).XColor : (server as ServerClass).OColor;
				finishCell.stopBlink();
				gm.gameField.forEach(function(b: Board): void { //Собираем в массив доски, принадлежащие победителю
					if (b.owner.indexOf(e.responce.winner) != -1) {
						winnerBoards.push(b.getCoord());
					}
				});
				Cc.logch('Game', StringUtil.substitute("finishBoardCoord: {0}, finishCell: {1}, \nWinnerBoards: {2}", finishBoardCoord, finishCell, winnerBoards));
				for (var i:int = 0; i < winCombinations.length; i++) {
					//trace('i ' + i);
					eqCount = 0;
					curComb = winCombinations[i];
					for (var j:int = 0; j < winnerBoards.length; j++) {
						//trace('  j ' + j);
						curCoord = winnerBoards[j];
						if (curCoord.equals(curComb[0]) || curCoord.equals(curComb[1]) || curCoord.equals(curComb[2])) {
							if (++eqCount == 3) {
								break;
							}	
						}
					}
					if (eqCount == 3) {
						winnerBoards = winCombinations[i];
						Cc.logch('Game', "Boards to highlight: " + winnerBoards);
						break;
					}
				}
				var tmr: Timer = new Timer(Math.floor(ShapeManager.BOARD_HIGHLIGHT_ANIM_DURATION * 1000 / 3), 3);
				tmr.addEventListener(TimerEvent.TIMER, onTimerTick);
				tmr.start();
				function onTimerTick(e: TimerEvent): void {
					var tickCount: int = tmr.currentCount - 1;
					curCoord = winnerBoards[tickCount];
					gm.gameField.getBoardByCoord(curCoord.x, curCoord.y).highlight(highlightColor);
					if (tickCount == 2) {
						tmr.removeEventListener(TimerEvent.TIMER, onTimerTick);
					}
				}
			}
		}
		
		private function checkEndGame(): Boolean {
			if ((winner = gm.gameField.checkWinner())) { //Если кто-то выиграл
				//winner = player.opponentRole;
				var request: Object = {
					cmd: ServerStrings.CMD_END_GAME,
					reason: (player.role == winner) ? ServerStrings.END_GAME_REASON_WIN : ServerStrings.END_GAME_REASON_LOSE,
					winner: winner
				}
				server.sendCmd(request);
				return true;
			}
			if (gm.gameField.getBlankCellsCount() == 0) { //Если не осталось свободных клеток
				winner = ServerStrings.END_GAME_REASON_DRAWN;
				request = {
					cmd: ServerStrings.CMD_END_GAME,
					reason: ServerStrings.END_GAME_REASON_DRAWN
				}
				server.sendCmd(request);
				return true;
			}
			return false;
		}
		
	}
	
}