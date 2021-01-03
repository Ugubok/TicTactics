package  {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import com.junkbyte.console.Cc;
	
	public class SoundManager {
		
		public static var cellSelSound:Sound;
		public static var moveSound:Sound;
		public static var connectSound:Sound;
		public static var pressSound:Sound;
		
		public static function start():void {
			var urlRequest:URLRequest = new URLRequest('sounds/select.mp3');
			cellSelSound = new Sound();
			cellSelSound.addEventListener(Event.COMPLETE, onLoadComplete);
			cellSelSound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			cellSelSound.load(urlRequest);
			
			urlRequest.url = 'sounds/move.mp3';
			moveSound = new Sound();
			moveSound.addEventListener(Event.COMPLETE, onLoadComplete);
			moveSound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			moveSound.load(urlRequest);
			
			urlRequest.url = 'sounds/connect.mp3';
			connectSound = new Sound();
			connectSound.addEventListener(Event.COMPLETE, onLoadComplete);
			connectSound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			connectSound.load(urlRequest);
			
			urlRequest.url = 'sounds/btnpress.mp3';
			pressSound = new Sound();
			pressSound.addEventListener(Event.COMPLETE, onLoadComplete);
			pressSound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			pressSound.load(urlRequest);
		}
		
		static private function onIOError(e:IOErrorEvent):void {
			(e.currentTarget as Sound).removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			Cc.error('Sound ' + (e.currentTarget as Sound).url + ' failed to load!');
		}
		
		private static function onLoadComplete(e:Event):void {
			(e.currentTarget as Sound).removeEventListener(Event.COMPLETE, onLoadComplete);
			Cc.log('Sound ' + (e.currentTarget as Sound).url + ' complete loading.');
		}
		
	}

}