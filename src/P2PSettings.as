package  {
	
	public class P2PSettings {
		
		public static const P2P_DEVKEY:				String	= '3cd04399d42a8e6dad7c45b6-889de1dcadc6';
		public static const STRATUS_ADDRESS:	 	String	= 'rtmfp://p2p.rtmfp.net/';
		
		public static const GROUP_PREFIX:			String	= 'TicTactics/';
		public static const LOBBY_GROUP_NAME:		String	= GROUP_PREFIX + 'SafeLobby';
		public static const LOBBY_REQ_TIMEOUT: 		int		= 4000; //Таймаут (мс) ожидания ответа на запрос поиска игры
		public static const HOST_CONNECT_TIMEOUT:	int		= 20000; //Таймаут (мс) ожидания подключения к комнате
		
		public static const P2P_REGULAR_MESSAGE:	String	= String.fromCharCode(0x1); //Пока неизвестно зачем. Используется как значение по умолчанию в P2PGroup.post()
		public static const LOBBY_REQ_PACKET:		String	= String.fromCharCode(0x10);
		public static const LOBBY_RES_PACKET:		String	= String.fromCharCode(0x11);
		public static const LOBBY_CONNECT_REQ:		String	= String.fromCharCode(0x12);
		public static const LOBBY_CONNECT_RES:		String	= String.fromCharCode(0x13);
		public static const KEY_EXCHANGE_PACKET:	String	= String.fromCharCode(0x14);
		public static const KEY_EXCHANGE_PACKET2:	String	= String.fromCharCode(0x15);
		
		public static const GAME_STARTED:			String	= String.fromCharCode(0x20);
		public static const GAME_COMMAND:			String	= String.fromCharCode(0x21);
	}

}