package
{
	
	import fl.transitions.easing.*;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	///@TODO Протестировать панель Tasks
	public class FormViewer extends Sprite
	{
		
		private var shadow:Shape; //Затемнение всего окна + блокирование кликов по фону
		private var msgBox:Sprite = new Sprite();
		private var msgBoxShape:Shape;
		private var contentMask:Sprite;
		private var contentBox:Sprite = new Sprite();
		/*private var titleText: TextField = new TextField();
		   private var textGlowFilter: GlowFilter;
		   private var msgText: TextField = new TextField();
		 private var closeBtn: LabeledAButton;*/
		private var colors:Array = ShapeManager.MSG_VIEWER_COLORS;
		private var _color:ColorTransform = new ColorTransform();
		private var colorTweener:ColorTweener = new ColorTweener();
		private var colorAnimFunc:Function = ShapeManager.MSG_VIEWER_COLOR_ANIM_FUNCTION;
		private var stageWidth:Number;
		private var stageHeight:Number;
		private var opened:Boolean = false;
		
		private var tweens:Object = {shadowAlpha: null, msgBoxHeight: null, msgBoxWidth: null, msgBoxX: null, msgBoxY: null, contentAlpha: null}
		
		public function FormViewer()
		{
			if (stage)
			{
				init();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init(e: Event = null):void
		{
			if (hasEventListener(Event.ADDED_TO_STAGE)) {
				removeEventListener(Event.ADDED_TO_STAGE, init);
			}
			stageWidth = stage.stageWidth;
			stageHeight = stage.stageHeight;
			msgBoxShape = ShapeManager.drawRectShape(Shape, 2, 2, colors[0]) as Shape;
			contentMask = ShapeManager.drawRectShape(Sprite, 2, 2, 0) as Sprite;
			shadow = ShapeManager.drawRectShape(Shape, stageWidth, stageHeight, 0) as Shape;
			
			msgBox.addChild(msgBoxShape);
			color = colors[0];
			msgBox.addChild(contentMask);
			
			contentBox.mask = msgBox.getChildByName(contentMask.name);
			
			shadow.addEventListener(MouseEvent.CLICK, onShadowClick);
			contentBox.x = 0;
			contentBox.y = stageHeight / 2 - ShapeManager.MSG_VIEWER_MSGBOX_HEIGHT / 2;
		}
		
		private function onShadowClick(e:MouseEvent):void
		{
			//Просто блокируем клики
		}
		
		public function showMessage(content:DisplayObject):void
		{
			if (opened)
			{
				setContent(content);
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
			contentBox.alpha = 0;
			setContent(content);
			addChild(contentBox);
			var shadowChild:Shape = getChildByName(shadow.name) as Shape;
			var msgBoxChild:Sprite = getChildByName(msgBox.name) as Sprite;
			var msgBoxShapeChild:Shape = msgBox.getChildByName(msgBoxShape.name) as Shape;
			var finishHeight:Number = ShapeManager.MSG_VIEWER_MSGBOX_HEIGHT;
			var duration:Number = ShapeManager.MSG_VIEWER_OPENCLOSE_ANIM_DURATION;
			with (tweens)
			{
				shadowAlpha = new Tween(shadowChild, 'alpha', None.easeNone, 0, ShapeManager.MSG_VIEWER_SHADOW_ALPHA, duration, true);
				msgBoxWidth = new Tween(msgBoxChild, 'width', Regular.easeIn, msgBoxChild.width, stageWidth, duration / 2, true);
				msgBoxX = new Tween(msgBoxChild, 'x', Regular.easeIn, msgBox.x, 0, duration / 2, true);
				msgBoxWidth.addEventListener(TweenEvent.MOTION_FINISH, onMsgBoxOpenWidthMotionFinish);
			}
		}
		
		private function onMsgBoxOpenWidthMotionFinish(e:TweenEvent):void
		{
			tweens.msgBoxWidth.removeEventListener(TweenEvent.MOTION_FINISH, onMsgBoxOpenWidthMotionFinish);
			var msgBoxChild:Sprite = getChildByName(msgBox.name) as Sprite;
			var finishHeight:Number = ShapeManager.MSG_VIEWER_MSGBOX_HEIGHT;
			var duration:Number = ShapeManager.MSG_VIEWER_OPENCLOSE_ANIM_DURATION;
			with (tweens)
			{
				msgBoxHeight = new Tween(msgBoxChild, 'height', Regular.easeOut, msgBoxChild.height, finishHeight, duration / 2, true);
				msgBoxY = new Tween(msgBoxChild, 'y', Regular.easeOut, msgBoxChild.y, msgBoxChild.y - finishHeight / 2, duration / 2, true);
				contentAlpha = new Tween(contentBox, 'alpha', None.easeNone, 0, 1, duration / 2, true);
			}
			var nextColorIdx:int = colors.indexOf(this.color) + 1;
			var nextColor:uint = (nextColorIdx == colors.length) ? colors[0] : colors[nextColorIdx];
			colorTweener.tween(this, 'color', colorAnimFunc, this.color, nextColor, ShapeManager.MSG_VIEWER_COLORS_ANIM_DURATION, true);
			colorTweener.addEventListener(TweenEvent.MOTION_FINISH, onColorMotionFinish);
		}
		
		private function onColorMotionFinish(e:TweenEvent):void
		{
			var nextColorIdx:int = colors.indexOf(this.color) + 1;
			var nextColor:uint = (nextColorIdx == colors.length) ? colors[0] : colors[nextColorIdx];
			colorTweener.tween(this, 'color', colorAnimFunc, this.color, nextColor, ShapeManager.MSG_VIEWER_COLORS_ANIM_DURATION, true);
		}
		
		public function close():void
		{
			if (!opened)
				return;
			var msgBoxChild:Sprite = getChildByName(msgBox.name) as Sprite;
			var shadowChild:Shape = getChildByName(shadow.name) as Shape;
			var finishHeight:Number = ShapeManager.MSG_VIEWER_MSGBOX_START_HEIGHT;
			var duration:Number = ShapeManager.MSG_VIEWER_OPENCLOSE_ANIM_DURATION;
			with (tweens)
			{
				shadowAlpha = new Tween(shadowChild, 'alpha', None.easeNone, shadowChild.alpha, 0, duration, true);
				msgBoxHeight = new Tween(msgBoxChild, 'height', Regular.easeIn, msgBoxChild.height, finishHeight, duration / 2, true);
				msgBoxY = new Tween(msgBoxChild, 'y', Regular.easeIn, msgBoxChild.y, stageHeight / 2 - finishHeight / 2, duration / 2, true);
				contentAlpha = new Tween(contentBox, 'alpha', None.easeNone, 1, 0, duration / 2, true);
				contentAlpha.addEventListener(TweenEvent.MOTION_FINISH, onMsgBoxCloseHeightMotionFinish);
				shadowAlpha.addEventListener(TweenEvent.MOTION_FINISH, onCloseMotionFinish);
			}
			colorTweener.stop();
			colorTweener.removeEventListener(TweenEvent.MOTION_FINISH, onColorMotionFinish);
		}
		
		private function onMsgBoxCloseHeightMotionFinish(e:TweenEvent):void
		{
			tweens.contentAlpha.removeEventListener(TweenEvent.MOTION_FINISH, onMsgBoxCloseHeightMotionFinish);
			var msgBoxChild:Sprite = getChildByName(msgBox.name) as Sprite;
			var msgBoxShapeChild:Shape = msgBox.getChildByName(msgBoxShape.name) as Shape;
			var finishWidth:Number = stageWidth / 2 - msgBox.width / 2;
			var duration:Number = ShapeManager.MSG_VIEWER_OPENCLOSE_ANIM_DURATION;
			with (tweens)
			{
				msgBoxWidth = new Tween(msgBoxChild, 'width', Regular.easeOut, msgBoxChild.width, 1, duration / 2, true);
				msgBoxX = new Tween(msgBoxChild, 'x', Regular.easeOut, msgBox.x, stageWidth / 2 - finishWidth / 2, duration / 2, true);
			}
		}
		
		private function onCloseMotionFinish(e:TweenEvent):void
		{
			tweens.shadowAlpha.removeEventListener(TweenEvent.MOTION_FINISH, onCloseMotionFinish);
			removeChild(shadow);
			removeChild(msgBox);
			opened = false;
		}
		
		public function setContent(content:DisplayObject):void
		{
			var contentBoxChild:DisplayObject;
			if (contentBox.numChildren > 0)
			{
				contentBox.removeChild(contentBox.removeChildAt(0));
			}
			contentBox.addChild(content);
			contentBoxChild = contentBox.getChildAt(0);
			
			if (content.width > stageWidth)
			{
				contentBoxChild.x = 0;
			}
			else
			{
				contentBoxChild.x = (stageWidth - content.width) / 2;
			}
			
			if (content.height > ShapeManager.MSG_VIEWER_MSGBOX_HEIGHT)
			{
				contentBoxChild.y = 0;
			}
			else
			{
				contentBoxChild.y = (ShapeManager.MSG_VIEWER_MSGBOX_HEIGHT - content.height) / 2;
			}
		}
		
		public function getContent():DisplayObject
		{
			if (contentBox.numChildren != 0) {
				return contentBox.getChildAt(0);
			}
			return null;
		}
		
		public function set color(newColor:uint):void
		{
			_color.color = newColor;
			(msgBox.getChildByName(msgBoxShape.name) as Shape).transform.colorTransform = _color;
		}
		
		public function get color():uint
		{
			return _color.color;
		}
	}

}