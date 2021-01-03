package {
	
	import com.adobe.serialization.json.*;
	import com.junkbyte.console.Cc;
	
	public class Player {
		
		public var color: uint;
		public var opponentColor: uint;
		public var gm: GraphicsManager;
		public var name: String;
		
		private var _role: String;
		private var _opponentRole: String;
		private var selectedCells: Array = [];
		private var onCellUpComplete: Function;
		private var _lastMove: Object;
		
		private var lastActivatedBoard: Board = null;
		private var lastHighlightedBoard: Board = null;
		private var lastMoveHasActivatedGamefield: Boolean = false;
		private var lastChooseHasWinBoard: Boolean = false;
		private var lastChooseHasTurnedBoardToCommon: Boolean = false;
		private var oldCellsColor: uint;
		private var oldCellColor: uint;
		private var moveBoard: Board;
		
		public function Player(gm: GraphicsManager) {
			this.gm = gm;
			color = ShapeManager.PLAYER_CELLS_COLOR;
			opponentColor = ShapeManager.OPPONENT_CELLS_COLOR;
		}
		
		public function choose9Cells(): void {
			if (gm.hasEventListener(BoardEvents.ON_CELL_CLICK)) {
				gm.removeEventListener(BoardEvents.ON_CELL_CLICK, onCellClick, true);
				trace('Old onCellClick listener has deleted');
				if (gm.hasEventListener(BoardEvents.ON_CELL_CLICK)) {
					trace('СОБЫТИЕ ON_CELL_CLICK ВСЕ ЕЩЕ СУЩЕСТВУЕТ! ОНО ЖИВО! ООО!')
				}
			}
			
			this.onCellUpComplete = function(e: BoardEvents): void {
				gm.gameField.getBoardByCoord(1, 1).removeEventListener(BoardEvents.ON_CELL_UP_COMPLETE, onCellUpComplete);
				gm.addEventListener(BoardEvents.ON_CELL_CLICK, onCellClick, true);
				Cc.logch('Game', 'CellUP complete');
			}
			
			gm.gameField.forEach(function(board: Board): void { //Поднимаем все клетки, кроме центральной
				if (board.getCoord().y == 2 && board.getCoord().x == 2) {
					board.forEach(function(cell: Cell): void {
						if (!(cell.getCoord().x == 2 && cell.getCoord().y == 2)) cell.up();
						else cell.down();
					});
				} else board.activate(false);
			});
			gm.gameField.getBoardByCoord(1, 1).addEventListener(BoardEvents.ON_CELL_UP_COMPLETE, onCellUpComplete);
		}
		
		/**
		 * Удаляет слушатель onCellClick, зарегистрированный методом choose9Cells()
		 */
		public function stopChoose9Cells(): void {
			if (gm.hasEventListener(BoardEvents.ON_CELL_CLICK)) {
				gm.removeEventListener(BoardEvents.ON_CELL_CLICK, onCellClick, true);
			}
		}
		
		private function onCellClick(e: BoardEvents): void {
			//Обработчик события для choose9cells
			var cell: Cell = e.cell;
			Cc.logch('Game', 'Cell clicked (' + cell.name + ')' + ' (e: ' + e.currentTarget + ')')
			if (!cell.hasSymbol() && cell.isUp) { //Если ставим свой знак на ячейку
				selectedCells.push(getChooseObject((e.target as Board), cell));
				cell.setColor(color);
				SoundManager.cellSelSound.play();
				if (role == ServerStrings.PLAYER_ROLE_X) cell.setX();
					else if (role == ServerStrings.PLAYER_ROLE_O) cell.setO();
				gm.gameField.forEach(function(board: Board): void {
					if (board == (e.target as Board)) {
						if (board.getCheckedCellsCount() == 2) board.deactivate(true);
					} else {
						if (board.getCheckedCellsCount() == 2) return; //Не опускаем ячейки у заполненных досок
						board.getCellByCoord(cell.getCoord().x, cell.getCoord().y).down();
					}
				});
			} else if (cell.hasSymbol()) { //Если убираем свой знак с ячейки
				SoundManager.cellSelSound.play();
				removeChoose(getChooseObject((e.target as Board), cell));
				cell.setBlank();
				cell.setColor((e.target as Board).cellsColor);
				gm.gameField.forEach(function(board: Board): void {
					if (board == (e.target as Board)) { //Если доска, на которой ходили
						if (board.getCheckedCellsCount() == 1) {
							if (board.getCoord().x == 2 && board.getCoord().y == 2) { //Не поднимаем центральную
								board.forEach(function(cell: Cell): void {
									if (!(cell.getCoord().x == 2 && cell.getCoord().y == 2) && !cellPositionChoosed(cell)) cell.up();
								});
							} else {
								board.forEach(function(cell: Cell): void {
									if (!cellPositionChoosed(cell)) cell.up();
								});
							}
						}
					} else {
						if (board.getCoord().x == 2 && board.getCoord().y == 2 && cell.getCoord().x == 2 && cell.getCoord().y == 2) return; //Не поднимаем центральную
						if (board.getCheckedCellsCount() == 2) return; //Не поднимаем ячейки у заполненных досок
						board.getCellByCoord(cell.getCoord().x, cell.getCoord().y).up();
					}
				});
			}
			function cellPositionChoosed(cell: Cell): Boolean {
				for each(var choose: Object in selectedCells) {
					if (choose.cell.x == cell.getCoord().x && choose.cell.y == cell.getCoord().y) {
						return true;
					}
				}
				return false;
			}
		}
		
		private function onCellClick2(e: BoardEvents): void {
			//Обработчик события для move
			var board: Board = (e.target as Board);
			var cell: Cell = (e.cell as Cell);
			if (!cell.isUp) return;
			if (!cell.hasSymbol()) { //Если свободна
				if (moveBoard != null && board != moveBoard) return; //Если указана доска для хода, и не совпадает с текущей, выходим
				SoundManager.cellSelSound.play();
				if (selectedCells.length != 0) { //Удаление старого выбора
					var choosenBoard: Board = gm.gameField.getBoardByCoord(selectedCells[0].board.x, selectedCells[0].board.y);
					var choosenCell: Cell = choosenBoard.getCellByCoord(selectedCells[0].cell.x, selectedCells[0].cell.y);
					choosenCell.setColor(choosenBoard.cellsColor);
					choosenCell.setBlank();
				}
				
				if (!board.hasOwner() || (board.owner == role)) {
					cell.setColor(color);
				}
				else {
					cell.setColor(opponentColor);
				}
				
				if (role == ServerStrings.PLAYER_ROLE_X) cell.setX();
				else if (role == ServerStrings.PLAYER_ROLE_O) cell.setO();
				
				//Опускаем и возвращаем прежний цвет ранее приподнятой доске, если есть
				if (lastActivatedBoard != null) {
					lastActivatedBoard.deactivate();
					lastActivatedBoard.stopHighlight();
					lastActivatedBoard = null;
				}
				if (lastMoveHasActivatedGamefield) {
					gm.gameField.forEach(function(b: Board): void {
						if (b != board) b.deactivate();
					});
					lastMoveHasActivatedGamefield = false;
				}
				if (lastHighlightedBoard != null) {
					lastHighlightedBoard.stopHighlight();
					lastHighlightedBoard = null;
				}
				if (!board.hasOwner() && board.checkWin(role)) { //Если выбор выигрышный, и доска не занята
					oldCellsColor = board.cellsColor;
					board.setCellsColor(color);
					lastChooseHasWinBoard = true;
				}
				if (!board.hasOwner() && (board.checkWinner() == 'XO')) { //Если выбор превращает доску в общую
					//Меняем цвет на общий
					oldCellsColor = board.cellsColor;
					oldCellColor = cell.color;
					cell.setColor(ShapeManager.COMMON_CELLS_COLOR);
					board.setCellsColor(ShapeManager.COMMON_CELLS_COLOR);
					lastChooseHasTurnedBoardToCommon = true;
				}
				if ( (lastChooseHasWinBoard && !board.checkWin(role)) || (lastChooseHasTurnedBoardToCommon && !(board.checkWinner() == 'XO')) ) { //Возвращаем цвет на место
					if (lastChooseHasTurnedBoardToCommon) {
						//cell.setColor(oldCellColor);
						lastChooseHasTurnedBoardToCommon = false;
					}
					choosenBoard.setCellsColor(oldCellsColor); //Строка нужна для возвращения цвета пустых клеток на серый
					choosenBoard.forEach(function(c: Cell): void { //А этот цикл для возвращения цвета занятым ячейкам 
						if (c.hasSymbol()) {
							if (role == c.owner) c.setColor(color)
							else c.setColor(opponentColor);
						}
					});
					lastChooseHasWinBoard = false;
				}
				
				var targetBoard: Board = gm.gameField.getBoardByCoord(cell.getCoord().x, cell.getCoord().y);
				if(moveBoard != null){
					if (targetBoard != board) { //Приподнимаем доску перенаправления, если она не текущая
						if (targetBoard.getCheckedCellsCount() == 9) { //Если доска перенаправления полностью занята, приподнимаем все кроме текущей
							gm.gameField.forEach(function(b: Board): void {
								if (b != board) b.activate(true, true, ShapeManager.CELL_UP_OFFSET / 2);
							});
							lastMoveHasActivatedGamefield = true;
						} else {
							targetBoard.activate(true, true, ShapeManager.CELL_UP_OFFSET / 2);
							lastActivatedBoard = targetBoard;
							targetBoard.highlight(opponentColor);
						}
					} else { //Если текущая, то только подсвечиваем
						targetBoard.highlight(opponentColor);
						lastHighlightedBoard = targetBoard;
					}
				} else {
					targetBoard.highlight(opponentColor);
					lastHighlightedBoard = targetBoard;
				}
				setChoose(getChooseObject(board, cell));
			}
		}
		
		public function move(moveBoard: Board = null): void {
			//Позволяет игроку сделать ход на свободной поднятой ячейке, если не указан Board. Если указан, то только на нем
			Cc.logch('Game', 'move вызвали');
			lastActivatedBoard = null;
			lastHighlightedBoard = null;
			lastMoveHasActivatedGamefield = false;
			lastChooseHasWinBoard = false;
			lastChooseHasTurnedBoardToCommon = false;
			this.moveBoard = moveBoard;
			if (gm.hasEventListener(BoardEvents.ON_CELL_CLICK)) gm.removeEventListener(BoardEvents.ON_CELL_CLICK, onCellClick2, true);
			if (moveBoard != null) moveBoard.activate();
			
			gm.addEventListener(BoardEvents.ON_CELL_CLICK, onCellClick2, true);
		}
		
		private function getChooseObject(board: Board, cell:Cell): Object {
			//Формирует объект координаты выбранной ячейки, готовый к отправке на сервер
			var chooseObject: Object = {
				board: {
					x: board.getCoord().x,
					y: board.getCoord().y
				},
				cell: {
					x: cell.getCoord().x,
					y: cell.getCoord().y
				}
			}
			return chooseObject;
		}
		
		private function setChoose(choose: Object): void {
			this.selectedCells = [];
			this.selectedCells.push(choose);
		}
		
		private function removeChoose(choose: Object): void {
			var chooseStr: String = new JSONEncoder(choose).getString();
			selectedCells.forEach(function(obj: *, index: int, array: Array): void {
				if (new JSONEncoder(obj).getString() == chooseStr) array.splice(index, 1);
			});
		}
		
		public function get selectedCell(): Array {
			return [].concat(this.selectedCells);
		}
		
		public function clearMove(): void {
			this._lastMove = this.selectedCell[0];
			this.selectedCells = [];
			//if (gm.hasEventListener(BoardEvents.ON_CELL_CLICK)) gm.removeEventListener(BoardEvents.ON_CELL_CLICK, onCellClick);
		}
		
		public function get lastMove(): Object {
			return _lastMove;
		}
		
		public function set role(newRole: String): void {
			_role = newRole;
			_opponentRole = (newRole == ServerStrings.PLAYER_ROLE_X) ? ServerStrings.PLAYER_ROLE_O : ServerStrings.PLAYER_ROLE_X;
		}
		
		public function get role(): String {
			return _role;
		}
		
		public function get opponentRole(): String {
			return _opponentRole;
		}
		
		public function get graphicsManager(): GraphicsManager {
			return gm;
		}
		
	}
	
}