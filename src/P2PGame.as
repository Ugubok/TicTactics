package  {
	
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	
	public class P2PGame extends P2PGroup {
		
		public var opponentPeerID: String;
		
		public function P2PGame(connection:NetConnection, groupName:String, netGroup:NetGroup) {
			super(connection, groupName, netGroup);
			this._groupName = groupName;
		}
		
	}

}