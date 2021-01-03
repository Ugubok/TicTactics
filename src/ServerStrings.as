package {
	
	public class ServerStrings {
		
		public static const GAME_STATE_NOT_STARTED:			String		= 'gameNotStarted';
		public static const GAME_STATE_CHOOSE_CELLS:		String		= 'chooseCells'; //Стадия выбора 9 клеток
		public static const GAME_STATE_MOVES:				String		= 'gameMoves' //Поочередные ходы
		public static const GAME_STATE_CONTINUE:			String		= 'gameContinue' //Игра закончена
		
		public static const GAMEMODE_PASSNPLAY:				String		= 'passAndPlay'; //Режим двух игроков на одной машине
		
		public static const CMD_GAME_START:					String		= 'START_GAME';
		public static const CMD_SET_9_CELLS:				String		= 'SET_9_CELLS';
		public static const CMD_PLAYER_MOVE:				String		= 'PLAYER_MOVE';
		public static const CMD_END_GAME:					String		= 'END_GAME';
		
		public static const PLAYER_ROLE_X:					String	 	= 'X';
		public static const PLAYER_ROLE_O:					String		= 'O';
		
		public static const END_GAME_REASON_LOSE:			String		= 'playerLose';
		public static const END_GAME_REASON_WIN:			String		= 'playerWin';
		public static const END_GAME_REASON_DRAWN:			String		= 'gameDrawn'; //Ничья
		
		public static const CHAT_MESSAGE:					String		= 'chatMessage'; //В этой версии это просто вывод сообщения в консоль
		public static const VIEWER_MESSAGE:					String 		= 'viewerMessage'; //Отображение сообщения в MessageViewer'е
		
	}
	
}