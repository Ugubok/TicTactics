package {
	
	import flash.events.Event;
	
	public class ServerEvent extends Event {
		
		public static const GAME_STARTED = 'gameStarted';
		public static const OPPONENT_CHOOSED_9_CELLS = 'opponentChoosed9Cells';
		public static const PLAYER_MOVE	= 'playerMove';
		public static const GAME_OVER = 'gameOver';
		
		public var responce: Object = new Object();
		
		public function ServerEvent(type: String) {
			super(type);
		}
		
		public override function clone(): Event {
			var event: ServerEvent = new ServerEvent(type);
			event.responce = responce;
			return event;
		}
	}
	
}