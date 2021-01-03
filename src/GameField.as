package {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class GameField extends Sprite {
		
		private var boards: Array;
		private var boardsSprite: Sprite = new Sprite();
		
		public function GameField() {
			setBoards();
			addChild(boardsSprite);
		}
		
		private function setBoards():void {
			
			var cols:int = ShapeManager.GF_COLS;
			var rows:int = ShapeManager.GF_ROWS;
			var boardSpaces:Number = ShapeManager.GF_BOARD_SPACES;
			
			boards = new Array(cols * rows);
			
			function setBoardsDepth():void {
				var addOrder: Array = new Array(); // = [7, 8, 9, 4, 5, 6, 1, 2, 3];
				for (var i:int = rows - 1; i != -1; i--) {
					for (var j:int = 1; j <= cols; j++) {
						addOrder.push(i * cols + j);
					}
				}
				var addOrderLength:int = addOrder.length;
				for (i = 0; i < addOrderLength; i++) {
					boardsSprite.addChild(boards[addOrder.pop() - 1]);
				}
			}
			
			for (var i:int = 1; i <= boards.length; i++) {
				(boards[i - 1] = new Board()).setCoord(i - (Math.ceil(i / rows) - 1) * rows, Math.ceil(i / rows));
				var board: Board = boards[i - 1];
				var coord: Point = board.getCoord();
				
				board.x = (coord.x - 1) * board.width + boardSpaces * coord.x;
				board.y = (coord.y - 1) * board.height + boardSpaces * coord.y;
				if (i % 2 == 0) board.setCellsColor(ShapeManager.CELL_COLOR_2, false);
					else board.setCellsColor(ShapeManager.CELL_DEFAULT_COLOR, false);
				//board.addEventListener(BoardEvents.ON_CELL_CLICK, onCellClick);
				//addChild(board);
				//board.activate();
			}
			
			setBoardsDepth();
		}
		
		/*private function onCellClick(e: BoardEvents) {
			dispatchEvent(e);
		}*/
		
		public function getBoardByCoord(x:int, y: int): Board {
			return boards[(y-1) * ShapeManager.GF_ROWS + x - 1];
		}
		
		public function activate(onlyIfHasSymbol: Boolean = true, quick: Boolean = false):void {
			//Активирует все свободные ячейки на всех досках
			for each(var board: Board in boards) {
				board.activate(onlyIfHasSymbol, quick);
			}
		}
		
		public function deactivate(onlyBlank: Boolean = false):void {
			//Деактивирует все свободные ячейки на всех досках
			for each(var board: Board in boards) {
				board.deactivate(onlyBlank);
			}
		}
		
		public function forEach(callback: Function): void {
			//Выполняет действие для каждой доски
			for each(var board: Board in boards) {
				callback(board);
			}
		}
		
		public function checkWin(playerSymbol: String): Boolean {
			//FIXME: Ряд из общих досок не должен считаться выигрышным
			var currentCombination: String = '';
			for (var i:int = 0; i < boards.length; i++) { //Формируем строку с текущей комбинацией
				currentCombination += (boards[i].owner.indexOf(playerSymbol) != -1) ? '1' : '0';
			}
			for (i = 0; i < 3; i++) { //Проверка по горизонтали
				if (currentCombination.substr(i * 3, 3) == '111') return true;
			}
			for (i = 0; i < 3; i++) { //Проверка по вертикали
				if (currentCombination.charAt(i) + currentCombination.charAt(i + 3) + currentCombination.charAt(i + 6) == '111' ) return true;
			}
			if (currentCombination.charAt(0) + currentCombination.charAt(4) + currentCombination.charAt(8) == '111' ) return true;
			if (currentCombination.charAt(2) + currentCombination.charAt(4) + currentCombination.charAt(6) == '111' ) return true;
			return false;
		}
		
		public function checkWinner(): String {
			if (checkWin(ServerStrings.PLAYER_ROLE_X)) return ServerStrings.PLAYER_ROLE_X;
			if (checkWin(ServerStrings.PLAYER_ROLE_O)) return ServerStrings.PLAYER_ROLE_O;
			return '';
		}
		
		public function getBlankCellsCount(): int {
			var count: int = 0;
			for each(var board: Board in boards) {
				count += 9 - board.getCheckedCellsCount();
			}
			return count;
		}
		
	}
	
}