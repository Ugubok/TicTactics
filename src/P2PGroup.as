package
{
	import com.adobe.crypto.MD5;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.utils.Timer;
	import com.junkbyte.console.Cc;
	
	public class P2PGroup extends EventDispatcher
	{
		internal var netConnection:NetConnection;
		internal var netGroup:NetGroup;
		internal var _groupName:String;
		private var _peerID:String;
		private var _groupConnected:Boolean = false;
		private var connectionTimer:Timer;
		private var myMessages:Array = new Array();
		private var debug_messages:Array = new Array(); //Сюда складываются все входящие сообщения (для отладки)
		
		public function P2PGroup(connection:NetConnection, groupName:String, netGroup:NetGroup = null)
		{
			_groupName = groupName;
			connectionTimer = new Timer(300, 1);
			connectionTimer.addEventListener(TimerEvent.TIMER, onConnectionTimer);
			netConnection = connection;
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, netConnectionHandler);
			if (!netConnection.connected)
			{
				netConnection.connect(P2PSettings.STRATUS_ADDRESS + P2PSettings.P2P_DEVKEY);
			}
			else
			{
				if (netGroup == null)
				{
					onConnect();
				}
				else
				{
					_peerID = netConnection.nearID;
					this.netGroup = netGroup;
					this.netGroup.addEventListener(NetStatusEvent.NET_STATUS, netGroupHandler);
				}
			}
		}
		
		private function netConnectionHandler(e:NetStatusEvent):void
		{
			var p2pEvent:P2PEvent;
			switch (e.info.code)
			{
				case 'NetConnection.Connect.Success':
					p2pEvent = new P2PEvent(P2PEvent.CONNECTED);
					dispatchEvent(p2pEvent);
					onConnect();
					break;
				case 'NetGroup.Connect.Success': 
					if (!_groupConnected)
					{
						debug_messages.push(e.info);
						Cc.debugch('P2P', 'Connected to group ', e.info);
						connectionTimer.start();
						_groupConnected = true;
					}
					break;
				case 'NetConnection.Connect.Closed': 
					debug_messages.push(e.info);
					Cc.infoch('P2P', 'Connection closed ' + e.info);
					_groupConnected = false;
				default: 
					if (e.info.level == 'error')
					{
						debug_messages.push(e.info);
						Cc.errorch('P2P', 'netConnectionHandler :: ERROR: ' + e.info);
						p2pEvent = new P2PEvent(P2PEvent.ERROR);
						p2pEvent.info = e.toString();
						dispatchEvent(p2pEvent);
					}
			}
		}
		
		private function onConnectionTimer(e:TimerEvent):void
		{
			var p2pEvent:P2PEvent;
			p2pEvent = new P2PEvent(P2PEvent.GROUP_CONNECTED);
			dispatchEvent(p2pEvent);
		}
		
		private function netGroupHandler(e:NetStatusEvent):void
		{
			var p2pEvent:P2PEvent;
			switch (e.info.code)
			{
				// К сети p2p подключился новый участник
				case "NetGroup.Neighbor.Connect":
					Cc.infoch('P2P', '<' + groupName +'> ' + 'Peer connected (' + e.info.peerID + ')');
					p2pEvent = new P2PEvent(P2PEvent.ON_PEER_CONNECT);
					p2pEvent.peerID = e.info.peerID;
					p2pEvent.myPeerID = _peerID;
					break;
				// Из сети вышел кто то из участников
				case "NetGroup.Neighbor.Disconnect": 
					Cc.infoch('P2P', '<' + groupName +'> ' + 'Peer disconnected (' + e.info.peerID + ')');
					p2pEvent = new P2PEvent(P2PEvent.ON_PEER_DISCONNECT);
					p2pEvent.peerID = e.info.peerID;
					p2pEvent.myPeerID = _peerID;
					break;
				// Пришло новое сообщение из сети
				case "NetGroup.Posting.Notify": 
					if (isMyMessage(e.info.messageID))
						return;
					debug_messages.push(e.info);
					Cc.logch('P2P', '<' + groupName +'> ' + 'MSG [' + e.info.message.type + ']: ', e.info);
					p2pEvent = new P2PEvent(P2PEvent.ON_MESSAGE);
					p2pEvent.message = e.info.message;
					p2pEvent.peerID = e.info.message['peerid'];
					p2pEvent.messageID = e.info.messageID;
					p2pEvent.myPeerID = _peerID;
					break;
			}
			dispatchEvent(p2pEvent);
		}
		
		private function onConnect():void
		{
			_peerID = netConnection.nearID;
			var groupSpecifier:GroupSpecifier = new GroupSpecifier(_groupName);
			groupSpecifier.serverChannelEnabled = true;
			groupSpecifier.postingEnabled = true;
			netGroup = new NetGroup(netConnection, groupSpecifier.groupspecWithAuthorizations());
			netGroup.addEventListener(NetStatusEvent.NET_STATUS, netGroupHandler);
		}
		
		public function post(type:String = '', data:Object = '', midReply:String = ''):String
		{
			var obj:Object = new Object();
			if (type)
				obj['type'] = type;
			if (data)
				obj['data'] = data;
			if (midReply)
				obj['mid'] = midReply;
			obj['peerid'] = _peerID;
			obj['anticache'] = MD5.hash(Math.round(Math.random() * 9999999).toString());
			var mid:String = netGroup.post(obj);
			if (mid == null)
			{
				Cc.errorch('P2P', '[' + _groupName + '] Unable to post message ' + obj);
			}
			myMessages.push(mid);
			return mid;
		}
		
		public function isMyMessage(mid:String):Boolean
		{
			return myMessages.indexOf(mid) != -1;
		}
		
		public function get peerID():String
		{
			return _peerID;
		}
		
		public function get groupName():String
		{
			return _groupName;
		}
		
		internal function changeGroupName(newName:String):void
		{
			netGroup.close();
			_groupConnected = false;
			netGroup.removeEventListener(NetStatusEvent.NET_STATUS, netGroupHandler);
			_groupName = newName;
			onConnect();
		}
		
		public function get groupConnected():Boolean
		{
			return _groupConnected;
		}
		
		internal function generateGroupName():String
		{
			return P2PSettings.GROUP_PREFIX + MD5.hash(peerID + Math.random() * 1000000);
		}
	}
}