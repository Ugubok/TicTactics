package {
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;

	public class BackgroundSprite extends Sprite {
		
		private var bgGradient: Shape;
		private var figures: Array;
		private var figuresAnim: Array;
		private var figuresContainer: Sprite;
		private var figuresMask: Sprite;
		private var animStarted: Boolean = false;
		private var stageHeight: int;
		private var stageWidth: int;
		
		public function BackgroundSprite() {
			figures = new Array(ShapeManager.BACKGROUND_FIGURES_COUNT);
			figuresAnim = new Array(ShapeManager.BACKGROUND_FIGURES_COUNT);
			figuresContainer = new Sprite();
			setFigures();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			function onAddedToStage(e: Event):void {
				removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				stageWidth = stage.stageWidth;
				stageHeight = stage.stageHeight;
				bgGradient = ShapeManager.drawBackgroundGradient(stageWidth, stageHeight);
				addChild(bgGradient);
				addChild(figuresContainer);
				figuresMask = ShapeManager.drawMask(stageWidth, stageHeight);
				addChild(figuresMask);
				figuresContainer.mask = figuresMask;
				startFiguresAnim();
			}
		}
		
		private function setFigures(): void { //Рисуем фигуры. Половина крестиков, половина ноликов
			var i: int = 0;
			for (i; i != Math.floor(figures.length / 2); i++) {
				figures[i] = ShapeManager.drawXShape();
			}
			for (i; i != figures.length; i++) {
				figures[i] = ShapeManager.drawOShape();
			}
		}
		
		public function startFiguresAnim(): void {
			if (animStarted) return;
			animStarted = true;
			var tweenObj: Shape;
			for (var i:int = 0; i < figuresAnim.length; i++) { //Инициализация анимаций
				tweenObj = figures[i];
				figuresAnim[i] = {
					tweenX: new Tween(tweenObj, 'x', None.easeNone, -tweenObj.width, -tweenObj.width, 0.01, true),
					tweenY: new Tween(tweenObj, 'y', None.easeNone, -tweenObj.height, -tweenObj.height, 0.01, true)
				}
				figuresAnim[i].tweenY.addEventListener(TweenEvent.MOTION_FINISH, onFiguresMotionFinish);
				figuresContainer.addChild(figures[i]);
			}
		}
		
		private function onFiguresMotionFinish(e: TweenEvent):void {
			var tweenY: Tween = (e.currentTarget as Tween);
			var tweenX: Tween = (figuresAnim[figures.indexOf(tweenY.obj)].tweenX as Tween);
			var obj: Shape = (tweenY.obj as Shape);
			var sizeDelta:Number = obj.height - obj.width;
			var minSize:Number = ShapeManager.BACKGROUND_FIGURES_MIN_SIZE;
			var maxSize:Number = ShapeManager.BACKGROUND_FIGURES_MAX_SIZE;
			obj.height = Math.round(minSize + Math.random() * (maxSize - minSize));
			obj.width = obj.height - sizeDelta;
			var horizontal: Boolean = Math.round(Math.random()) == 1; //Рандомно выбираем направление движения
			var minDuration:Number = ShapeManager.BACKGROUND_FIGURES_MIN_ANIM_DURATION;
			var maxDuration:Number = ShapeManager.BACKGROUND_FIGURES_MAX_ANIM_DURATION;
			var minAlpha:Number = ShapeManager.BACKGROUND_FIGURES_MIN_ALPHA;
			var maxAlpha:Number = ShapeManager.BACKGROUND_FIGURES_MAX_ALPHA;
			obj.alpha = minAlpha + Math.random() * (maxAlpha - minAlpha);
			tweenX.begin = Math.round(horizontal ? ((Math.round(Math.random()) == 1) ? -obj.width : (stageWidth + obj.width)) : (Math.random() * stageWidth));
			tweenX.finish = Math.round(horizontal ? ((tweenX.begin > 0) ? -obj.width : (stageWidth + obj.width)) : (Math.random() * stageWidth));
			tweenY.begin = Math.round(horizontal ? (Math.random() * stageHeight) : ((Math.round(Math.random()) == 1) ? (obj.height + stageHeight) : -obj.height));
			tweenY.finish = Math.round(horizontal ? (Math.random() * stageHeight) : ((tweenY.begin > 0) ? -obj.height : (stageHeight + obj.height)));
			tweenX.duration = Math.round(minDuration + Math.random() * (maxDuration - minDuration));
			tweenY.duration = tweenX.duration;
			tweenX.start();
			tweenY.start();
		}
		
	}
	
}