package  {
	
	import fl.transitions.easing.*;
	import fl.transitions.Tween;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	public class Cell extends Sprite {
		
		public static const ON_LOAD = 'onLoad';
		
		private var cellSprite: Sprite = new Sprite();
		private var cellShape: Shape = new Shape();
		private var shadowSprite: Sprite = new Sprite();
		private var shadowMask: Sprite = new Sprite();
		private var colorSprite: Shape = new Shape();
		private var coord: Point = new Point();
		private var symbol: DisplayObject;
		private var _owner: String = '';
		private var cellColor: ColorTransform = new ColorTransform();
		private var colorTweener: ColorTweener = new ColorTweener();
		private var blinkTweens: Object = {
			blinkTween: Tween,
			blinkTweenWidth: Tween,
			blinkTweenHeight: Tween,
			blinkTweenX: Tween,
			blinkTweenY: Tween
		}
		private var upDownAnimX: Tween;
		private var upDownAnimY: Tween;
		
		private var _isUp: Boolean = false;
		
		public function Cell() {
			cellShape = ShapeManager.drawCellShape();
			shadowSprite = ShapeManager.drawShadowSprite();
			shadowMask = ShapeManager.drawShadowSprite();
			colorSprite = ShapeManager.drawCellShape();
			with (shadowMask) {
				mask = this.shadowSprite;
				x -= -ShapeManager.CELL_UP_OFFSET;
				y += -ShapeManager.CELL_UP_OFFSET;
			}
			with (cellSprite) {
				addChild(shadowMask);
				addChild(cellShape);	
				addChild(colorSprite);
			}
			addChild(shadowSprite);
			color = ShapeManager.CELL_DEFAULT_COLOR;
			addChild(cellSprite);
			dispatchEvent(new Event(Cell.ON_LOAD));
		}
		
		public function set color(color: uint) {
			this.cellColor.color = color;
			this.cellColor.alphaMultiplier = 0.3;
			//cellSprite.removeChild(colorSprite);
			cellSprite.getChildByName(colorSprite.name).transform.colorTransform = cellColor;
			//cellSprite.addChildAt(colorSprite, 2);
		}
		
		public function get color(): uint {
			return this.cellColor.color;
		}
		
		public function setColor(color: uint): void {
			if (colorTweener.isRunning) {
				colorTweener.stop();
			}
			colorTweener.tween(this, 'color', None.easeNone, this.color, color, ShapeManager.CELL_UPDOWN_ANIM_DURATION);
			//this.color = color;
		}

		
		public function setCoord(x, y: int): Point {
			this.coord.x = x;
			this.coord.y = y;
			
			return getCoord();
		}
		
		public function getCoord(): Point {
			return this.coord;
		}
		
		public function setSymbol(symbol: DisplayObject): void {
			var cellSize = ShapeManager.CELL_SIZE;
			var borderSize = ShapeManager.CELL_BORDER_SIZE;
			
			if (hasSymbol()) removeSymbol();
			if (symbol is Bitmap) (symbol as Bitmap).smoothing = true;
			with (symbol) {
				height = cellSize - borderSize * 2;
				width = cellSize - borderSize * 2;
				x = borderSize;
				y = borderSize;
			}
			this.symbol = symbol;
			cellSprite.addChild(symbol);
		}
		
		public function removeSymbol(): void {
			if (symbol == null) return;
			cellSprite.removeChild(symbol);
			this.symbol = null;
		}
		
		public function hasSymbol(): Boolean {
			return this.symbol != null;
		}
		
		public function get isUp(): Boolean {
			return _isUp;
		}
		
		public function up(upOffset: int = ShapeManager.CELL_UP_OFFSET): void {
			if (!_isUp) {
				var duration = ShapeManager.CELL_UPDOWN_ANIM_DURATION;
				var animFunc = ShapeManager.CELL_ANIM_UP_FUNCTION;
				
				upDownAnimX = new Tween(cellSprite, 'x', animFunc, cellSprite.x, -upOffset, duration);
				upDownAnimY = new Tween(cellSprite, 'y', animFunc, cellSprite.y, upOffset, duration);
				_isUp = true;
			}
		}
		
		public function down(): void {
			if (_isUp) {
				var duration = ShapeManager.CELL_UPDOWN_ANIM_DURATION;
				var upOffset = ShapeManager.CELL_UP_OFFSET;
				var animFunc = ShapeManager.CELL_ANIM_DOWN_FUNCTION;
				
				upDownAnimX = new Tween(cellSprite, 'x', animFunc, cellSprite.x, 0, duration);
				upDownAnimY = new Tween(cellSprite, 'y', animFunc, cellSprite.y, 0, duration);
				_isUp = false;
			}
		}
		
		public function startBlink(color: uint) {
			color = ShapeManager.colorShift(color, -0x444444);
			var blinker: Sprite = ShapeManager.drawBlinkerShape(color);
			var blinkerSize = 10;
			var blinkerFinishWidth: Number = blinker.width + blinkerSize;
			var blinkerFinishCoord: Number = -blinkerSize / 2;
			var duration: Number = 20;
			
			//blinker.alpha = 0.5;
			addChildAt(blinker, 0);
			with (blinkTweens) {
				blinkTween = new Tween(getChildAt(0), 'alpha', Regular.easeOut, blinker.alpha, 0, duration);
				blinkTweenWidth = new Tween(getChildAt(0), 'width', Regular.easeOut, blinker.width, blinkerFinishWidth, duration);
				blinkTweenHeight = new Tween(getChildAt(0), 'height', Regular.easeOut, blinker.height, blinkerFinishWidth, duration);
				blinkTweenX = new Tween(getChildAt(0), 'x', Regular.easeOut, blinker.x, blinkerFinishCoord, duration);
				blinkTweenY = new Tween(getChildAt(0), 'y', Regular.easeOut, blinker.y, blinkerFinishCoord, duration);
			}
			for each(var tween: Tween in blinkTweens) {
				tween.looping = true;
			}
		}
		
		public function stopBlink() {
			if (blinkTweens.blinkTween == null) return;
			for each(var tween: Tween in blinkTweens) {
				tween.stop();
				tween = null;
			}
			removeChildAt(0);
		}
		
		public function get owner(): String {
			return _owner;
		}
		
		public function setX(): void {
			setSymbol(new ShapeManager.SymbolX());
			_owner = ServerStrings.PLAYER_ROLE_X;
		}
		
		public function setO(): void {
			setSymbol(new ShapeManager.SymbolO());
			_owner = ServerStrings.PLAYER_ROLE_O;
		}
		
		public function setBlank(): void {
			removeSymbol();
			_owner = '';
		}
	}

}