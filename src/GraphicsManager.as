package {
	
	import com.adobe.protocols.dict.util.CompleteResponseEvent;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class GraphicsManager extends Sprite {
		
		public static const MOVE_BUTTON_CLICK: String = 'moveButtonClick';
		
		private var gf: GameField = new GameField();
		private var _moveButton: SuperButton = new SuperButton(ShapeManager.CELL_SIZE * 3 + ShapeManager.BOARD_CELL_SPACES * 4 + 50, 40, 'Сделать ход');
		private var background: BackgroundSprite;
		private var msgViewer: MessageViewer = new MessageViewer();
		private var _formViewer: FormViewer = new FormViewer();
		private var stageWidth: Number;
		private var stageHeight: Number;
		//private var _chatWindow: ChatWindow;
		
		public function GraphicsManager() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e: Event): void {
			background = new BackgroundSprite();
			//_chatWindow = new ChatWindow();
			addChild(background);
			//addChild(_chatWindow);
			stageWidth = stage.stageWidth;
			stageHeight = stage.stageHeight;
			with (gf) {
				x = stageWidth / 2 - width / 2;
				//y = (stageHeight - _chatWindow.CHAT_WIN_HEIGHT) / 2 - height / 2;
				y = stageHeight / 2 - height / 2;
			}
			addChild(gf);
			with (_moveButton) {
				x = gf.x + ShapeManager.CELL_SIZE * 3 + ShapeManager.BOARD_CELL_SPACES * 3 - 25;
				y = gf.y + gf.height;
				addEventListener(MouseEvent.CLICK, onMoveButtonClick);
			}
			addChild(_moveButton);
			addChild(msgViewer);
			addChild(_formViewer);
		}
		
		public function get gameField(): GameField {
			return gf;
		}
		
		private function onMoveButtonClick(e: MouseEvent): void {
			var event: Event = new Event(GraphicsManager.MOVE_BUTTON_CLICK);
			dispatchEvent(event);
		}
		
		public function get messageViewer(): MessageViewer {
			return msgViewer;
		}
		
		public function get moveButton(): SuperButton {
			return _moveButton;
		}
		
		public function get formViewer():FormViewer {
			return _formViewer;
		}
		
		/*public function get chatWindow(): ChatWindow {
			return _chatWindow;
		}*/
		
	}
	
}