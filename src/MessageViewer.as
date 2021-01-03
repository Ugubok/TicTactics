package {
	
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import fl.transitions.TweenEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	///@TODO Протестировать панель Tasks
	public class MessageViewer extends Sprite {
		
		private var shadow: Shape;
		private var msgBox: Sprite = new Sprite();
		private var msgBoxShape: Shape;
		private var textMask: Sprite;
		private var textBox: Sprite = new Sprite();
		private var titleText: TextField = new TextField();
		private var textGlowFilter: GlowFilter;
		private var msgText: TextField = new TextField();
		private var closeBtn: LabeledAButton;
		private var colors: Array = ShapeManager.MSG_VIEWER_COLORS;
		private var _color: ColorTransform = new ColorTransform();
		private var colorTweener: ColorTweener = new ColorTweener();
		private var colorAnimFunc: Function = ShapeManager.MSG_VIEWER_COLOR_ANIM_FUNCTION;
		private var stageWidth: Number;
		private var stageHeight: Number;
		private var opened: Boolean = false;
		
		private var tweens: Object = {
			shadowAlpha: null,
			msgBoxHeight: null,
			msgBoxWidth: null,
			msgBoxX: null,
			msgBoxY: null,
			textAlpha: null
		}
		
		public function MessageViewer() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			msgBoxShape = ShapeManager.drawRectShape(Shape, 2, 2, colors[0]) as Shape;
			textMask = ShapeManager.drawRectShape(Sprite, 2, 2, 0) as Sprite;
			closeBtn = new LabeledAButton(150, 40, 'OK', 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 2, 0xFFFFFF);
			closeBtn.button.upState.alpha = 0.1;
			closeBtn.button.overState.alpha = 0.5
			msgBox.addChild(msgBoxShape);
			color = colors[0];
			msgBox.addChild(textMask);
			textGlowFilter = new GlowFilter(0, 0.5, 5, 5);
			/*var font: Font = new CityNovaFont();
			var fontBold: Font = new CityNovaBoldFont();*/
			var font: Font = new CalibriFont();
			var fontBold: Font = new CalibriBoldFont();
			function setTextStyle (tf: TextField, size: int = 30,  bold: Boolean = true) {
				with (tf) {
					var selFont: Font = bold ? fontBold: font;
					defaultTextFormat = new TextFormat(selFont.fontName, size, 0xFFFFFF, bold, null, null, null, null, TextFormatAlign.CENTER);
					embedFonts = true;
					selectable = false;
					antiAliasType = AntiAliasType.ADVANCED;
					multiline = true;
					width = 800;
					wordWrap = true;
					tf.filters = [textGlowFilter];
				}
			}
			setTextStyle(titleText, 40);
			setTextStyle(msgText, 20, false);
			
			with (textBox) {
				addChild(titleText);
				addChild(msgText);
				addChild(closeBtn);
				mask = msgBox.getChildByName(textMask.name);
			}
		}
		
		private function onAddedToStage(e: Event): void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stageWidth = stage.stageWidth;
			stageHeight = stage.stageHeight;
			shadow = ShapeManager.drawRectShape(Shape, stageWidth, stageHeight, 0) as Shape;
			shadow.addEventListener(MouseEvent.CLICK, onShadowClick);
			textBox.x = 0;
			textBox.y = stageHeight / 2 - ShapeManager.MSG_VIEWER_MSGBOX_HEIGHT / 2;
			var closeBtnChild: DisplayObject = textBox.getChildByName(closeBtn.name);
			closeBtnChild.x = stageWidth - closeBtnChild.width - 5;
			closeBtnChild.y = ShapeManager.MSG_VIEWER_MSGBOX_HEIGHT - closeBtn.height - 7;
			var titleTextChild: TextField = textBox.getChildByName(titleText.name) as TextField;
			titleTextChild.y = 0;
			titleTextChild.x = stageWidth / 2 - titleTextChild.width / 2;
			var msgTextChild: TextField = textBox.getChildByName(msgText.name) as TextField;
			titleTextChild.text = ' ';
			msgTextChild.y = titleTextChild.height + titleTextChild.y;
			msgTextChild.x = stageWidth / 2 - msgTextChild.width / 2;
			msgTextChild.height = ShapeManager.MSG_VIEWER_MSGBOX_HEIGHT - titleTextChild.textHeight;
		}
		
		private function onShadowClick(e: MouseEvent): void {
			//Просто блокируем клики
		}
		
		public function showMessage(title: String = '', text: String = ''): void {
			if (opened) {
				setText(title, text);
				return;
			}
			opened = true;
			shadow.alpha = 0;
			addChild(shadow);
			msgBox.height = ShapeManager.MSG_VIEWER_MSGBOX_START_HEIGHT;
			msgBox.width = 1;
			msgBox.y = stageHeight / 2 - msgBox.height / 2;
			msgBox.x = stageWidth / 2 - msgBox.width / 2;
			addChild(msgBox);
			textBox.alpha = 0;
			setText(title, text);
			addChild(textBox);
			textBox.getChildByName(closeBtn.name).addEventListener(MouseEvent.CLICK, onCloseBtnClick);
			var shadowChild: Shape = getChildByName(shadow.name) as Shape;
			var msgBoxChild: Sprite = getChildByName(msgBox.name) as Sprite;
			var msgBoxShapeChild: Shape = msgBox.getChildByName(msgBoxShape.name) as Shape;
			var finishHeight: Number = ShapeManager.MSG_VIEWER_MSGBOX_HEIGHT;
			var duration: Number = ShapeManager.MSG_VIEWER_OPENCLOSE_ANIM_DURATION;
			with (tweens) {
				shadowAlpha = new Tween(shadowChild, 'alpha', None.easeNone, 0, ShapeManager.MSG_VIEWER_SHADOW_ALPHA, duration, true);
				msgBoxWidth = new Tween(msgBoxChild, 'width', Regular.easeIn, msgBoxChild.width, stageWidth, duration / 2, true);
				msgBoxX = new Tween(msgBoxChild, 'x', Regular.easeIn, msgBox.x, 0, duration / 2, true);
				msgBoxWidth.addEventListener(TweenEvent.MOTION_FINISH, onMsgBoxOpenWidthMotionFinish);
			}
		}
		
		private function onCloseBtnClick(e: MouseEvent): void {
			textBox.getChildByName(closeBtn.name).removeEventListener(MouseEvent.CLICK, onCloseBtnClick);
			close();
		}
		
		private function onMsgBoxOpenWidthMotionFinish(e: TweenEvent) {
			tweens.msgBoxWidth.removeEventListener(TweenEvent.MOTION_FINISH, onMsgBoxOpenWidthMotionFinish);
			var msgBoxChild: Sprite = getChildByName(msgBox.name) as Sprite;
			var finishHeight: Number = ShapeManager.MSG_VIEWER_MSGBOX_HEIGHT;
			var duration: Number = ShapeManager.MSG_VIEWER_OPENCLOSE_ANIM_DURATION;
			with (tweens) {
				msgBoxHeight = new Tween(msgBoxChild, 'height', Regular.easeOut, msgBoxChild.height, finishHeight, duration / 2, true);
				msgBoxY = new Tween(msgBoxChild, 'y', Regular.easeOut, msgBoxChild.y, msgBoxChild.y - finishHeight / 2, duration / 2, true);
				textAlpha = new Tween(textBox, 'alpha', None.easeNone, 0, 1, duration / 2, true);
			}
			var nextColorIdx = colors.indexOf(this.color) + 1;
			var nextColor: uint = (nextColorIdx == colors.length) ? colors[0] : colors[nextColorIdx];
			colorTweener.tween(this, 'color', colorAnimFunc, this.color, nextColor, ShapeManager.MSG_VIEWER_COLORS_ANIM_DURATION, true);
			colorTweener.addEventListener(TweenEvent.MOTION_FINISH, onColorMotionFinish);
		}
		
		private function onColorMotionFinish(e: TweenEvent): void {
			var nextColorIdx = colors.indexOf(this.color) + 1;
			var nextColor: uint = (nextColorIdx == colors.length) ? colors[0] : colors[nextColorIdx];
			colorTweener.tween(this, 'color', colorAnimFunc, this.color, nextColor, ShapeManager.MSG_VIEWER_COLORS_ANIM_DURATION, true);
		}
		
		public function close(): void {
			if (!opened) return;
			var msgBoxChild: Sprite = getChildByName(msgBox.name) as Sprite;
			var shadowChild: Shape = getChildByName(shadow.name) as Shape;
			var finishHeight: Number = ShapeManager.MSG_VIEWER_MSGBOX_START_HEIGHT;
			var duration: Number = ShapeManager.MSG_VIEWER_OPENCLOSE_ANIM_DURATION;
			with (tweens) {
				shadowAlpha = new Tween(shadowChild, 'alpha', None.easeNone, shadowChild.alpha, 0, duration, true);
				msgBoxHeight = new Tween(msgBoxChild, 'height', Regular.easeIn, msgBoxChild.height, finishHeight, duration / 2, true);
				msgBoxY = new Tween(msgBoxChild, 'y', Regular.easeIn, msgBoxChild.y, stageHeight / 2 - finishHeight / 2, duration / 2, true);
				textAlpha = new Tween(textBox, 'alpha', None.easeNone, 1, 0, duration / 2, true);
				textAlpha.addEventListener(TweenEvent.MOTION_FINISH, onMsgBoxCloseHeightMotionFinish);
				shadowAlpha.addEventListener(TweenEvent.MOTION_FINISH, onCloseMotionFinish);
			}
			colorTweener.stop();
			colorTweener.removeEventListener(TweenEvent.MOTION_FINISH, onColorMotionFinish);
		}
		
		private function onMsgBoxCloseHeightMotionFinish(e: TweenEvent) {
			tweens.textAlpha.removeEventListener(TweenEvent.MOTION_FINISH, onMsgBoxCloseHeightMotionFinish);
			var msgBoxChild: Sprite = getChildByName(msgBox.name) as Sprite;
			var msgBoxShapeChild: Shape = msgBox.getChildByName(msgBoxShape.name) as Shape;
			var finishWidth: Number = stageWidth / 2 - msgBox.width / 2;
			var duration: Number = ShapeManager.MSG_VIEWER_OPENCLOSE_ANIM_DURATION;
			with (tweens) {
				msgBoxWidth = new Tween(msgBoxChild, 'width', Regular.easeOut, msgBoxChild.width, 1, duration / 2, true);
				msgBoxX = new Tween(msgBoxChild, 'x', Regular.easeOut, msgBox.x, stageWidth / 2 - finishWidth / 2, duration / 2, true);
			}
		}
		
		private function onCloseMotionFinish(e: TweenEvent): void {
			tweens.shadowAlpha.removeEventListener(TweenEvent.MOTION_FINISH, onCloseMotionFinish);
			removeChild(shadow);
			removeChild(msgBox);
			opened = false;
		}
		
		public function setText(title: String, text: String): void {
			var titleField: TextField = textBox.getChildByName(titleText.name) as TextField;
			var msgField: TextField = textBox.getChildByName(msgText.name) as TextField;
			titleField.text = title;
			msgField.text = text;
			msgField.y = ShapeManager.MSG_VIEWER_MSGBOX_HEIGHT / 2 - msgField.textHeight / 2;
		}
		
		public function set color(newColor: uint) {
			_color.color = newColor;
			(msgBox.getChildByName(msgBoxShape.name) as Shape).transform.colorTransform = _color;
		}
		
		public function get color(): uint {
			return _color.color;
		}
	}
	
}