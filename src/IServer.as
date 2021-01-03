package {
	
	import flash.events.IEventDispatcher;
	
	internal interface IServer extends IEventDispatcher{
		
		function sendCmd(cmd: Object): void;
		function get gameState(): String;
		function get currentPlayer(): String;
		function get XColor(): uint;
		function get OColor(): uint;
	}
	
}