package  {
	
	import flash.events.Event;
	
	public class P2PEvent extends Event {
		
		public static const CONNECTED: String = 'onConnected'; //При успешном подключении NetConnection
		public static const GROUP_CONNECTED: String = 'onGroupConnected'; //При успешном подключении NetGroup
		public static const ERROR: String = 'onError';
		public static const ON_PEER_CONNECT:String = 'onPeerConnect';
		public static const ON_PEER_DISCONNECT:String = 'onPeerDisconnect';
		public static const ON_MESSAGE:String = 'onMessage';
		public static const ON_CLIENT_CONNECT:String = 'onClientConnect'; //При подключении клиента
		public static const ON_HOST_CONNECTED:String = 'onHostConnected'; //При подключении к хосту
		public static const GAME_OPPONENT_FOUND:String = 'onGameOpponentFound';
		public static const GAME_OPPONENT_LEAVE:String = 'onGameOpponentLeave';
		public static const OPPONENT_COMMAND:String = 'onOpponentCommand';
		public static const GAME_STARTED:String = 'onGameStarted';
		
		public var info: String;
		public var peerID: String;
		public var myPeerID:String;
		public var message: Object;
		public var messageID: String;
		
		public function P2PEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new P2PEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("P2PEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}