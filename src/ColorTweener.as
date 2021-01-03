package {
	
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import fl.transitions.TweenEvent;
	import flash.events.EventDispatcher;
	
	public class ColorTweener extends EventDispatcher {
			
		private var running: Boolean = false;
		private var obj: Object;
		private var prop: String;
		private var rgb: Object;
		private var duration: Number;
		private var finish: uint;
		
		private var tweenRed: Tween;
		private var tweenGreen: Tween;
		private var tweenBlue: Tween;
		
		public function tween( //Анимация цвета
			obj: Object, //Объект
			prop: String, //Свойство объекта для изменения
			func: Function, //Формула анимации
			start: uint, //Начальный цвет
			finish: uint, //Конечный цвет
			duration: Number, //Продолжительность анимации
			inSeconds: Boolean = false
		):void {
			this.obj = obj;
			this.prop = prop;
			this.duration = duration;
			this.finish = finish;
			
			this.rgb = ShapeManager.HexToRGB(start);
			var rgbFinish: Object = ShapeManager.HexToRGB(finish);
			
			this.tweenRed = new Tween(rgb, 'r', func, rgb.r, rgbFinish.r, duration, inSeconds);
			this.tweenGreen = new Tween(rgb, 'g', func, rgb.g, rgbFinish.g, duration, inSeconds);
			this.tweenBlue = new Tween(rgb, 'b', func, rgb.b, rgbFinish.b, duration, inSeconds);
			this.tweenBlue.addEventListener(TweenEvent.MOTION_CHANGE, onPropChanged);
			this.tweenBlue.addEventListener(TweenEvent.MOTION_FINISH, onFinish);
			this.running = true;
		}
		
		private function onPropChanged(e: TweenEvent): void {
			var newColor: uint = ShapeManager.RGBToHex(rgb.r, rgb.g, rgb.b);
			obj[prop] = newColor;
		}
		
		private function onFinish(e: TweenEvent): void {
			this.running = false;
			dispatchEvent(new TweenEvent(TweenEvent.MOTION_FINISH, duration, finish));
		}
		
		public function get isRunning(): Boolean {
			return running;
		}
		
		public function stop():void {
			if (!running) return;
			tweenRed.stop();
			tweenGreen.stop();
			tweenBlue.stop();
			
			running = false;
		}
	}
	
}