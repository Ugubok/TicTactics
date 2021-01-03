package {
	
	import fl.transitions.easing.*;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * Поднимающаяся псевдо-3D кнопка
	 */
	public class SuperButton extends Sprite {
		
		public static const DOWN_ANIM_FINISH: String = 'downAnimFinish';
		public static const UP_ANIM_FINISH: String = 'upAnimFinish';
		
		private const borderWidth: int = 3;
		private const borderColor: uint = 0xAAAAAA;
		private const borderAlpha: Number = 0.3;
		
		private var _isUp: Boolean = false; //Определяет, поднята ли кнопка (read-only)
		private var buttonSprite: Sprite = new Sprite();
		private var shadowSprite: Sprite;
		private var caption: TextField = new TextField();
		private var captionFont: Font = new CityNovaFont();
		private var captionGlowFilter: GlowFilter = new GlowFilter(0, 0.5);
		private var borderShape: Shape;
		private var shadowMask: Sprite;
		private var upDownAnimX: Tween;
		private var upDownAnimY: Tween;
		
		public function SuperButton(width: int, height: int, label: String = '', fontSize: int = 25, color: uint = 0xABCDEF) {
			var shadowColorOffset: int = -0x444444;
			var shadowColor: uint = ShapeManager.colorShift(color, shadowColorOffset);
			
			shadowSprite = ShapeManager.drawShadowSprite(shadowColor, width, height);
			shadowMask = ShapeManager.drawShadowSprite(shadowColor, width, height);
			borderShape = ShapeManager.drawRectShape(Shape, width + borderWidth * 2, height + borderWidth * 2, borderColor) as Shape;
			with (borderShape) {
				alpha = borderAlpha;
				x = -borderWidth;
				y = -borderWidth;
			}
			with (shadowMask) {
				mask = this.shadowSprite;
				x -= -ShapeManager.CELL_UP_OFFSET;
				y += -ShapeManager.CELL_UP_OFFSET;
			}
			caption.width = width;
			with (caption) {
				defaultTextFormat = new TextFormat(captionFont.fontName, fontSize, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.CENTER);
				embedFonts = true;
				selectable = false;
				filters = [captionGlowFilter];
				text = label;
				multiline = true;
				antiAliasType = AntiAliasType.ADVANCED
			}
			caption.height = caption.textHeight;
			caption.y = Math.floor(height / 2 - caption.height / 2 - 2);
			buttonSprite.addChild(shadowMask)
			buttonSprite.addChild(ShapeManager.drawSuperButtonShape(width, height, color));
			buttonSprite.addChild(caption);
			
			addChild(borderShape);
			addChild(shadowSprite);
			addChild(buttonSprite);
		}
		
/*		private function onAnimFinish(event:TweenEvent):void {
			var e:Event;
			if (_isUp) e = new Event(UP_ANIM_FINISH)
				else e = new Event(DOWN_ANIM_FINISH);
			dispatchEvent(e);
		}*/
		
		public function up(upOffset: int = ShapeManager.CELL_UP_OFFSET): void {
			if (!_isUp) {
				var duration:int = ShapeManager.CELL_UPDOWN_ANIM_DURATION;
				var animFunc:Function = ShapeManager.CELL_ANIM_UP_FUNCTION;
				
				upDownAnimX = new Tween(buttonSprite, 'x', animFunc, buttonSprite.x, -upOffset, duration);
				upDownAnimY = new Tween(buttonSprite, 'y', animFunc, buttonSprite.y, upOffset, duration);
				_isUp = true;
			}
		}
		
		public function down(): void {
			if (_isUp) {
				var duration:int = ShapeManager.CELL_UPDOWN_ANIM_DURATION;
				var upOffset:int = ShapeManager.CELL_UP_OFFSET;
				var animFunc:Function = ShapeManager.CELL_ANIM_DOWN_FUNCTION;
				
				upDownAnimX = new Tween(buttonSprite, 'x', animFunc, buttonSprite.x, 0, duration);
				upDownAnimY = new Tween(buttonSprite, 'y', animFunc, buttonSprite.y, 0, duration);
				_isUp = false;
			}
		}
		
		/**
		 * Возвращает true, если кнопка "поднята".
		 */
		public function get isUp(): Boolean {
			return _isUp;
		}
		
	}
	
}