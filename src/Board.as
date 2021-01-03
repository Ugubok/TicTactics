package {
	
	import fl.transitions.TweenEvent;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	
	public class Board extends Sprite {
		
		public static const ON_LOAD: String = 'onLoad';
		
		private var _owner: String = '';
		
		private const cols: int = ShapeManager.BOARD_COLS; //Столбцов
		private const rows: int = ShapeManager.BOARD_ROWS; //Строк
		
		private var cells: Array;
		private var _cellsColor: uint; //Сюда записывается цвет ячеек после вызова setCellsColor()
		private var _color: uint = ShapeManager.BOARD_DEFAULT_COLOR; //Сюда записывается цвет доски после вызова setColor()
		private var boardShape: Shape;
		private var boardBg: Shape;
		private var cellsSprite: Sprite = new Sprite();
		private var coord: Point = new Point();
		private var blinkTweens: Object = {
			blinkTween: null,
			blinkTweenWidth: null,
			blinkTweenHeight: null,
			blinkTweenX: null,
			blinkTweenY: null
		}
		private var highlightTweens: Object = {
			highlightTweenA: null, //Alpha
			highlightTweenW: null, //Width
			highlightTweenH: null, //Height
			highlightTweenX: null,
			highlightTweenY: null
		}
		private var blinker: Sprite;
		private var blinkerMask: Sprite = ShapeManager.drawBlinkerMask();
		private var highlighted: Boolean = false;
		
		private var temp: Object = new Object(); //Для временных значений
		
		public function Board() {
			boardShape = ShapeManager.drawBoardShape();
			boardShape.alpha = 0.3;
			boardBg = ShapeManager.drawBoardShape(0x00000033);
			cellsSprite.x = ShapeManager.BOARD_SIZE_OFFSET / 2;
			cellsSprite.y = cellsSprite.x;
			//addChild(boardBg);
			addChild(boardShape);
			addChild(cellsSprite);
			setCells();
			dispatchEvent(new Event(Board.ON_LOAD));
		}
		
		private function setCells(): void {
			
			var cellSize: int = ShapeManager.CELL_SIZE;
			var cellSpaces: int = ShapeManager.BOARD_CELL_SPACES;
			
			cells = new Array(this.cols * this.rows);
		
			function onCellSet(cell: Cell): void {
				//var cell:Cell = cell;
				var coord: Point = cell.getCoord();
				
				cell.x = (coord.x - 1) * cellSize + cellSpaces * coord.x;
				cell.y = (coord.y - 1) * cellSize + cellSpaces * coord.y;
				cell.addEventListener(MouseEvent.CLICK, onCellClick);
				//addChild(cell);
			}
			
			function setCellsDepth(): void {
				var addOrder: Array = new Array(); // = [7, 8, 9, 4, 5, 6, 1, 2, 3];
				for (var i: int = rows - 1; i != -1; i--) {
					for (var j: int = 1; j <= cols; j++) {
						addOrder.push(i * cols + j);
					}
				}
				var addOrderLength: int = addOrder.length;
				for (i = 0; i < addOrderLength; i++) {
					cellsSprite.addChild(cells[addOrder.pop() - 1]);
				}
			}
			
			for (var i: int = 1; i <= this.rows * this.cols; i++) {
				(cells[i-1] = new Cell()).setCoord(i - (Math.ceil(i / this.rows)-1) * this.rows, Math.ceil(i / this.rows));
				onCellSet(cells[i-1]);
			}
			
			setCellsDepth();
		}
		
		private function onCellClick(e: MouseEvent): void {
			var event: BoardEvents = new BoardEvents(BoardEvents.ON_CELL_CLICK);
			event.cell = (e.currentTarget as Cell);
			dispatchEvent(event);
		}
		
		public function getCellByCoord(x: int, y: int): Cell {
			return cells[(y-1) * this.rows + x - 1];
		}
		
		public function activate(onlyBlank: Boolean = true, quick: Boolean = false, upOffset: int = ShapeManager.CELL_UP_OFFSET): void {
			//При установленном onlyIfHasSymbol поднимает только пустые ячейки, иначе поднимает все ячейки
			//При установленном quick поднимает все ячейки сразу, иначе - с задержкой
			if (quick) {
				for each (var cell:Cell in cells) {
					if (cell.hasSymbol() && onlyBlank) continue;
					cell.up(upOffset);
				}
				dispatchEvent(new BoardEvents(BoardEvents.ON_CELL_UP_COMPLETE));
				return;
			}
			if (onlyBlank && (getCheckedCellsCount() == 9)) {
				dispatchEvent(new BoardEvents(BoardEvents.ON_CELL_UP_COMPLETE));
				return;
			}
			var i: int = 0;
			var timer: Timer = new Timer(40, 9 - getCheckedCellsCount());
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
			timer.start();
			function onTimer(e: TimerEvent): void {
				var cell: Cell;
				if (onlyBlank) {
					for (i; i < 9; i++) {
						cell = cells[i];
						if (cell.hasSymbol()) continue;
							else { i++; break; }
					}
				} else {
					cell = cells[i++];
				}
				cell.up(upOffset);
			}
			function onComplete(e: TimerEvent): void {
				dispatchEvent(new BoardEvents(BoardEvents.ON_CELL_UP_COMPLETE));
			}
		}
		
		public function deactivate(onlyBlank: Boolean = false): void {
			//Опускает все ячейки
			for each(var cell:Cell in cells) {
				if (cell.hasSymbol() && onlyBlank) continue;
				cell.down();
			}
		}
		
		public function setCoord(x: int, y: int): void {
			coord.x = x;
			coord.y = y;
		}
		
		public function getCoord(): Point {
			return coord;
		}
		
		public function setColor(color: uint): void {
			var index: int = getChildIndex(boardShape);
			removeChild(boardShape);
			boardShape = ShapeManager.drawBoardShape(color);
			addChildAt(boardShape, index);
			_color = color;
		}
		
		public function get color(): uint {
			return _color;
		}
		
		public function setCellsColor(color: uint, withAnim: Boolean = true): void {
			this._cellsColor = color;
			if(withAnim) {
				for each(var cell:Cell in cells) {
					cell.setColor(color);
				}
			} else {
				for each(cell in cells) {
					cell.color = color;
				}
			}
		}
		
		public function get cellsColor(): uint {
			return this._cellsColor;
		}
		
		public function checkWin(playerSymbol: String): Boolean {
			var currentCombination: String = '';
			for (var i:int = 0; i < cells.length; i++) { //Формируем строку с текущей комбинацией
				currentCombination += (cells[i].owner == playerSymbol) ? '1' : '0';
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
			if (checkWin('X')) return 'X';
			if (checkWin('O')) return 'O';
			if (getCheckedCellsCount() == 9) return 'XO'; //Доска общая
			return '';
		}
		
		public function set owner(newOwner: String): void {
			trace(coord.toString() + ' owner: ' + newOwner);
			this._owner = newOwner;
		}
		
		public function get owner(): String {
			return this._owner;
		}
		
		public function hasOwner(): Boolean {
			return Boolean(owner);
		}
		
		public function getCheckedCellsCount(): int {
			var count: int = 0;
			for each(var cell: Cell in cells) {
				if (cell.hasSymbol()) count++;
			}
			return count;
		}
		
		public function startCellBlink(cell: Cell, color: uint): void {
			/*if (blinkTweens.blinkTween != null) stopBlink();
			blinker = ShapeManager.drawBlinkerShape(color);
			blinker.x = cell.x;
			blinker.y = cell.y;
			var blinkerSize = ShapeManager.BOARD_BLINKER_SIZE;
			var blinkerFinishWidth: Number = blinker.width + blinkerSize;
			var blinkerFinishCoordX: Number = blinker.x - blinkerSize / 2;
			var blinkerFinishCoordY: Number = blinker.y - blinkerSize / 2;
			var duration: Number = ShapeManager.BOARD_BLINKER_ANIM_DURATION;
			
			blinkerMask.x = blinker.x + blinkerSize / 2;
			blinkerMask.y = blinker.y + blinkerSize / 2;
			blinker.mask = blinkerMask;
			//blinker.alpha = 0.5;
			addChild(blinker);
			addChild(blinkerMask);
			var animObj = getChildByName(blinker.name);
			
			with (blinkTweens) {
				blinkTween = new Tween(animObj, 'alpha', None.easeOut, blinker.alpha, 0, duration);
				blinkTweenWidth = new Tween(animObj, 'width', Regular.easeOut, blinker.width, blinkerFinishWidth, duration);
				blinkTweenHeight = new Tween(animObj, 'height', Regular.easeOut, blinker.height, blinkerFinishWidth, duration);
				blinkTweenX = new Tween(animObj, 'x', Regular.easeOut, blinker.x, blinkerFinishCoordX, duration);
				blinkTweenY = new Tween(animObj, 'y', Regular.easeOut, blinker.y, blinkerFinishCoordY, duration);
			}
			for each(var tween: Tween in blinkTweens) {
				tween.looping = true;
			}*/
			if (temp.blinkedCell != null) temp.blinkedCell.stopBlink();
			cell.startBlink(color);
			temp.blinkedCell = cell;
		}
		
		public function stopCellBlink(): void {
		/*	if (blinkTweens.blinkTween == null) return; //Выход если не обнаружена анимация
			if (!this.contains(blinker)) return; //Выход если не обнаружена мигалка
			removeChild(blinker);
			removeChild(blinkerMask);
			for each(var tween: Tween in blinkTweens) {
				tween.stop();
				tween = null;
			}*/
			if (temp.blinkedCell != null) temp.blinkedCell.stopBlink();
		}
		
		public function forEach(callback: Function): void {
			//Выполняет действие для каждой клетки
			for each(var cell: Cell in cells) {
				callback(cell);
			}
		}
		
		public function get cellsArr(): Array {
			return cells;
		}
		
		public function highlight(color: uint = ShapeManager.BOARD_HIGHLIGHT_COLOR): void {
			if (highlighted) return;
			var cellSize: int = ShapeManager.CELL_SIZE;
			var sizeOffset: int = ShapeManager.BOARD_SIZE_OFFSET;
			var startWidth: Number = cellSize * rows + ShapeManager.BOARD_CELL_SPACES * (rows + 1) + sizeOffset;
			var startHeight: Number = cellSize * cols + ShapeManager.BOARD_CELL_SPACES * (cols + 1) + sizeOffset;
			var finishWidth: Number = startWidth + ShapeManager.BOARD_HIGHLIGHT_SIZE;
			var finishHeight: Number = startHeight + ShapeManager.BOARD_HIGHLIGHT_SIZE;
			temp.oldColor = _color;
			temp.oldAlpha = boardShape.alpha;
			setColor(color); //Меняем цвет до того, как запомнить объект для анимации, ведь setColor создает новый boardShape
			var tweenObj: DisplayObject = getChildByName(boardShape.name);
			var tweenFunc: Function = Regular.easeOut;
			var duration: Number = ShapeManager.BOARD_HIGHLIGHT_ANIM_DURATION;
			
			highlighted = true;
			with (highlightTweens) {
				highlightTweenA = new Tween(tweenObj, 'alpha', tweenFunc, 1, 0, duration, true);
				highlightTweenH = new Tween(tweenObj, 'height', tweenFunc, startHeight, finishHeight, duration, true);
				highlightTweenW = new Tween(tweenObj, 'width', tweenFunc, startWidth, finishWidth, duration, true);
				highlightTweenX = new Tween(tweenObj, 'x', tweenFunc, 0, -ShapeManager.BOARD_HIGHLIGHT_SIZE / 2, duration, true);
				highlightTweenY = new Tween(tweenObj, 'y', tweenFunc, 0, -ShapeManager.BOARD_HIGHLIGHT_SIZE / 2, duration, true);
				//highlightTweenY.addEventListener(TweenEvent.MOTION_FINISH, onMotionFinish);
			}
			//function onMotionFinish(e: TweenEvent) {
				for each(var tween: Tween in highlightTweens) {
					//tween.yoyo();
					tween.looping = true;
				}
			//}
		}
		
		public function stopHighlight(): void {
			if (!highlighted) return;
			setColor(temp.oldColor);
			getChildByName(boardShape.name).alpha = temp.oldAlpha;
			for each(var tween: Tween in highlightTweens) {
				tween.stop();
			}
			highlighted = false;
		}
	}
}