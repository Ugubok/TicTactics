package
{
	import com.adobe.crypto.MD5;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.utils.Timer;
	import com.junkbyte.console.Cc;
	
	public class P2PLobby extends P2PGroup
	{
		private var hostGroup:P2PGroup;
		private var clientGroup:P2PGroup;
		private var _gameGroup:P2PGame;
		private var _search:Boolean = false; //Идет ли поиск соперника
		private var _isHost:Boolean;
		private var hosters:Array;
		private var hostGroupName:String;
		private var collectHostersTimer:Timer;
		private var hostConnectTimer:Timer; //Таймаут подключения к хосту
		private var clientConnectTimer:Timer; //Таймаут ожидания клиента
		private var token:String;
		private var myToken:String;
		private var opponentPeerID:String;
		
		public function P2PLobby(connection:NetConnection)
		{
			super(connection, P2PSettings.LOBBY_GROUP_NAME);
			hosters = new Array();
			collectHostersTimer = new Timer(P2PSettings.LOBBY_REQ_TIMEOUT, 1);
			clientConnectTimer = new Timer(P2PSettings.HOST_CONNECT_TIMEOUT, 1);
			hostConnectTimer = new Timer(P2PSettings.HOST_CONNECT_TIMEOUT, 1);
			hostConnectTimer.addEventListener(TimerEvent.TIMER, tryConnectHostTimeout);
			clientConnectTimer.addEventListener(TimerEvent.TIMER, tryConnectClientTimeout);
			collectHostersTimer.addEventListener(TimerEvent.TIMER, collectHostersTimeout);
		}
		
		public function startSearch():void
		{
			if (_search || !groupConnected)
				return;
			Cc.infoch('P2P', 'Start searching opponent');
			addEventListener(P2PEvent.ON_MESSAGE, searchRcvListener);
			post(P2PSettings.LOBBY_REQ_PACKET);
			collectHostersTimer.start();
			_search = true;
		}
		
		private function searchRcvListener(e:P2PEvent):void
		{
			if (e.message['type'] == P2PSettings.LOBBY_RES_PACKET)
			{
				if (hosters.indexOf(e.messageID) == -1)
				{
					hosters.push(e.messageID);
				}
			}
		}
		
		private function collectHostersTimeout(e:TimerEvent):void
		{
			removeEventListener(P2PEvent.ON_MESSAGE, searchRcvListener);
			_search = false;
			if (hosters.length == 0)
			{
				startHost();
			}
			else
			{
				Cc.logch('P2P', 'Connect to random of ' + hosters.length + ' hosts');
				var randomHoster:String = hosters[Math.floor(Math.random() * hosters.length)];
				tryConnectToHost(randomHoster);
			}
			hosters = [];
		}
		
		private function tryConnectToHost(mid:String):void
		{
			addEventListener(P2PEvent.ON_MESSAGE, tryConnectHostMessage);
			post(P2PSettings.LOBBY_CONNECT_REQ, '', mid);
			hostConnectTimer.start();
		}
		
		private function tryConnectHostMessage(e:P2PEvent):void
		{
			if (e.message['type'] == P2PSettings.LOBBY_CONNECT_RES && (isMyMessage(e.message['mid']) && String(e.message['data']).length > 10))
			{
				Cc.infoch('P2P', '[Client] Host responded groupname ' + e.message['data']);
				if (clientGroup == null)
					clientGroup = new P2PGroup(netConnection, e.message['data'])
				else
					clientGroup.changeGroupName(e.message['data']);
				clientGroup.addEventListener(P2PEvent.ON_MESSAGE, tryConnectHostMessage);
				clientGroup.addEventListener(P2PEvent.GROUP_CONNECTED, onClientGroupConnected);
			}
			if (e.message['type'] == P2PSettings.KEY_EXCHANGE_PACKET && (String(e.message['data']).length > 10 && clientGroup.isMyMessage(e.message['mid'])))
			{
				Cc.infoch('P2P', '[Client] Host responded key ' + e.message['data']);
				token = e.message['data'] + myToken + '|';
				clientGroup.post(P2PSettings.KEY_EXCHANGE_PACKET2, MD5.hash(token + 'test'));
			}
			if (e.message['type'] == P2PSettings.KEY_EXCHANGE_PACKET2 && e.message['data'] == MD5.hash(token + 'testOK'))
			{
				Cc.infoch('P2P', '[Client] Key exchange success');
				opponentPeerID = e.peerID;
				hostConnectTimer.stop();
				clientGroup.addEventListener(P2PEvent.ON_MESSAGE, commandListener); //TODO: DELETE THIS
				clientGroup.addEventListener(P2PEvent.ON_PEER_DISCONNECT, testDisconnectedPeer); //(And this)
				stopTryConnectToHost();
				onOpponentFound(clientGroup.groupName, clientGroup.netGroup);
			}
			
			function onClientGroupConnected(e:P2PEvent):void
			{
				Cc.infoch('P2P', '[Client] Connected to hoster group');
				clientGroup.removeEventListener(P2PEvent.GROUP_CONNECTED, onClientGroupConnected);
				myToken = generateGroupName();
				clientGroup.post(P2PSettings.KEY_EXCHANGE_PACKET, myToken);
			}
		}
		
		private function testDisconnectedPeer(e:P2PEvent):void
		{
			//Проверяет, не вышел ли оппонент
			if (e.peerID == opponentPeerID)
			{
				Cc.warnch('P2P', 'Opponent leave');
				opponentPeerID = '';
				var event:P2PEvent = new P2PEvent(P2PEvent.GAME_OPPONENT_LEAVE);
				event.peerID = e.peerID;
				dispatchEvent(event);
			}
		}
		
		private function stopTryConnectToHost():void
		{
			removeEventListener(P2PEvent.ON_MESSAGE, tryConnectHostMessage);
			if (clientGroup != null)
			{
				clientGroup.removeEventListener(P2PEvent.ON_MESSAGE, tryConnectHostMessage);
			}
		}
		
		private function tryConnectHostTimeout(e:TimerEvent):void
		{
			Cc.warnch('P2P', 'Connect to host timeout');
			stopTryConnectToHost();
			startSearch();
		}
		
		public function startHost(groupName:String = null):void
		{
			if (_isHost)
				return;
			Cc.infoch('P2P', 'Start host');
			if (groupName == null)
				groupName = generateGroupName();
			if (hostGroup == null)
			{
				hostGroup = new P2PGroup(netConnection, groupName);
			}
			else
			{
				hostGroup.changeGroupName(groupName);
			}
			hostGroupName = groupName;
			addEventListener(P2PEvent.ON_MESSAGE, hostReqLisneter);
			_isHost = true;
		}
		
		private function hostReqLisneter(e:P2PEvent):void
		{
			if (e.message['type'] == P2PSettings.LOBBY_REQ_PACKET)
			{
				post(P2PSettings.LOBBY_RES_PACKET);
			}
			if (e.message['type'] == P2PSettings.LOBBY_CONNECT_REQ && isMyMessage(e.message['mid']))
			{
				tryConnectClient(e.messageID);
			}
		}
		
		private function tryConnectClient(mid:String):void
		{
			Cc.logch('P2P', 'Try connecting with client ' + mid);
			removeEventListener(P2PEvent.ON_MESSAGE, hostReqLisneter);
			hostGroup.addEventListener(P2PEvent.ON_CLIENT_CONNECT, tryHostConnectClientConnect);
			hostGroup.addEventListener(P2PEvent.ON_MESSAGE, tryHostConnectMessage);
			post(P2PSettings.LOBBY_CONNECT_RES, hostGroupName, mid);
			clientConnectTimer.start();
		}
		
		private function tryHostConnectMessage(e:P2PEvent):void
		{
			if (e.message['type'] == P2PSettings.KEY_EXCHANGE_PACKET && String(e.message['data']).length > 10)
			{
				Cc.logch('P2P', '[Host] Client send key ' + e.message['data']);
				var opponentToken:String = e.message['data'];
				myToken = generateGroupName();
				token = myToken + opponentToken + '|';
				hostGroup.post(P2PSettings.KEY_EXCHANGE_PACKET, myToken, e.messageID);
			}
			if (e.message['type'] == P2PSettings.KEY_EXCHANGE_PACKET2)
			{
				Cc.logch('P2P', '[Host] Client send control checksum');
				if (e.message['data'] == MD5.hash(token + 'test'))
				{
					//Обмен ключами успешен
					Cc.infoch('P2P', '[Host] Key exchange success');
					hostGroup.post(P2PSettings.KEY_EXCHANGE_PACKET2, MD5.hash(token + 'testOK'));
					clientConnectTimer.stop();
					hostGroup.addEventListener(P2PEvent.ON_MESSAGE, commandListener); //TODO: DELETE THIS
					hostGroup.addEventListener(P2PEvent.ON_PEER_DISCONNECT, testDisconnectedPeer); //(And this)
					stopTryConnectClient();
					opponentPeerID = e.peerID;
					onOpponentFound(hostGroup.groupName, hostGroup.netGroup);
				}
			}
		}
		
		private function tryHostConnectClientConnect(e:P2PEvent):void
		{
			Cc.infoch('P2P', '[Host] Client entered the room. peerID: ' + e.peerID);
			//Тут должен быть код, который отключается при подключении третьего клиента до обмена ключами
		}
		
		private function stopTryConnectClient():void
		{
			hostGroup.removeEventListener(P2PEvent.ON_MESSAGE, tryHostConnectMessage);
			hostGroup.removeEventListener(P2PEvent.ON_CLIENT_CONNECT, tryHostConnectClientConnect);
		}
		
		private function tryConnectClientTimeout(e:TimerEvent):void
		{
			Cc.warnch('P2P', 'Connection with client timeout.');
			stopTryConnectClient();
			reHost();
		}
		
		private function reHost():void
		{
			Cc.warnch('P2P', 'Rehost');
			hostGroup.changeGroupName(generateGroupName());
			_isHost = false;
			startHost(hostGroup.groupName);
		}
		
		private function onOpponentFound(groupName:String, netGroup:NetGroup):void {
			//_gameGroup = new P2PGame(netConnection, groupName, netGroup);
			//_gameGroup.opponentPeerID = opponentPeerID;
			dispatchEvent(new P2PEvent(P2PEvent.GAME_OPPONENT_FOUND));
		}
		
		public function get search():Boolean
		{
			return _search;
		}
		
		public function get isHost():Boolean
		{
			return _isHost;
		}
		
		public function get gameGroup():P2PGame {
			return _gameGroup;
		}
		
		//Все функции ниже сделаны на скорую руку лишь бы поиграть. Их следует удалить
		public function startGame() {
			if (_isHost) {
				var e:P2PEvent = new P2PEvent(P2PEvent.GAME_STARTED);
				var opponentRole: String;
				if (Math.round(Math.random())) {
					e.info = ServerStrings.PLAYER_ROLE_X;
					opponentRole = ServerStrings.PLAYER_ROLE_O;
				} else {
					e.info = ServerStrings.PLAYER_ROLE_O;
					opponentRole = ServerStrings.PLAYER_ROLE_X;
				}
				for (var i:int = 0; i < 6; i++) {
					//Иногда это сообщение не приходило, поэтому психанул и сделал отправку 5 раз
					hostGroup.post(P2PSettings.GAME_STARTED, opponentRole);
				}
				dispatchEvent(e);
			}
		}
		
		public function sendCmd(cmd: Object):void {
			if (_isHost) {
				hostGroup.post(P2PSettings.GAME_COMMAND, cmd);
			} else {
				clientGroup.post(P2PSettings.GAME_COMMAND, cmd);
			}
		}
		
		private function commandListener(e: P2PEvent) {
			var event:P2PEvent;
			if (e.message['type'] == P2PSettings.GAME_STARTED) {
				event = new P2PEvent(P2PEvent.GAME_STARTED);
				event.info = e.message['data'];
				dispatchEvent(event);
			}
			if(e.message['type'] == P2PSettings.GAME_COMMAND) {
				event = new P2PEvent(P2PEvent.OPPONENT_COMMAND);
				event.message = e.message;
				dispatchEvent(event);
			}
		}
	}
}