package  {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.StageScaleMode;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import com.junkbyte.console.Cc;
	import com.junkbyte.console.Console;
	import com.junkbyte.console.ConsoleChannel;
	import flash.media.SoundMixer;
	
	[SWF(width = "800", height = "600", frameRate = "25", backgroundColor = "0xEEEEEE")]
	public class Main extends Sprite {
		private var game: Game;
		private var gm: GraphicsManager = new GraphicsManager();
		
		public function Main() {
			//TODO: Запилить нормальный фон
			stage.scaleMode = StageScaleMode.NO_SCALE;
			setupConsole();
			SoundManager.start();
			Cc.log('TIC TACTICS [SAFE_VER] STARTED');
			Cc.log('framerate:' + stage.frameRate);
			Cc.log('TIMEOUTS: [LOBBY REQ: ' + (P2PSettings.LOBBY_REQ_TIMEOUT / 1000) + 's] [HOST CONNECT: ' + (P2PSettings.HOST_CONNECT_TIMEOUT / 1000) + 's]');
			var st:SoundTransform = new SoundTransform(0.5);
			SoundMixer.soundTransform = st;
			addChild(gm);
			game = new Game(P2P, gm);
		}
		
		private function setupConsole():void {
			Cc.config.style.backgroundAlpha = 0.65;
			Cc.startOnStage(this, "1"); // "`" - change for password. This will start hidden
			//Cc.visible = true; // Show console, because having password hides console.
			Cc.config.commandLineAllowed = true; // enable advanced (but security risk) features.
			Cc.config.tracing = false; // Also trace on flash's normal trace`
			Cc.remoting = false; // Start sending logs to remote (using LocalConnection)
			Cc.commandLine = true; // Show command line
			Cc.height = 220; // change height. You can set x y width height to position/size the main panel
			Cc.width = 800;
			
			Cc.addSlashCommand('chat', 
				function(msg:String) {
					var obj:Object = new Object();
					obj['cmd'] = ServerStrings.CHAT_MESSAGE;
					obj['msg'] = msg;
					(game.server as P2P).lobby.sendCmd(obj);
					Cc.warnch('Chat', '<< ' + msg);
				}, 
			'Показывает сообщение в консоли оппонента');
			
			Cc.addSlashCommand('viewmsg', 
				function(msg:String) {
					var obj:Object = new Object();
					obj['cmd'] = ServerStrings.VIEWER_MESSAGE;
					obj['msg'] = msg;
					(game.server as P2P).lobby.sendCmd(obj);
					Cc.warnch('Chat', 'You viewed message :' + msg);
				},
			'...');
			
			Cc.addSlashCommand('start',
				function() {
					(game.server as P2P).startSearch();
				},
			'Начать поиск оппонента');
			
			Cc.addSlashCommand('post',
				function(msg:String) {
					var obj:Object = new Object();
					obj['type'] = msg;
					(game.server as P2P).lobby.post(P2PSettings.P2P_REGULAR_MESSAGE, obj);
				},
			'Отправляет сообщение в лобби');
			
			Cc.addSlashCommand('volume',
				function(vol:Number) {
					var st:SoundTransform = new SoundTransform(vol);
					SoundMixer.soundTransform = st;
					Cc.log('Volume set to ' + vol);
				},
			'Изменяет глобальную громкость (значение от 0 до 1)');
		}
		
	}

}

/** ===================================
 * 
 * Hello from 2014!
 * 
 * ==================================== */
