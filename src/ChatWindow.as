package  {
	
	import fl.controls.UIScrollBar;
	import flash.display.Sprite;
	import fl.controls.TextArea;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class ChatWindow extends Sprite {
		
		public const CHAT_WIN_HEIGHT: int = 150;
		private const INPUT_HEIGHT: int = 20;
		
		private var messagesField: TextArea;
		private var inputField: TextField;
		private var scrollBar: UIScrollBar;
		private var background: Sprite;
		
		public function ChatWindow() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			scrollBar = new UIScrollBar();
			messagesField = new TextArea();
			inputField = new TextField();
		}
		
		private function onAddedToStage(e: Event): void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			background = ShapeManager.drawRectShape(Sprite, stage.stageWidth, CHAT_WIN_HEIGHT, ShapeManager.CHAT_WIN_BACKGROUND_COLOR, NaN, 0x999999) as Sprite;
			background.alpha = ShapeManager.CHAT_WIN_ALPHA;
			addChild(background);
			
			graphics.lineStyle(1, 0x999999);
			graphics.lineTo(stage.stageWidth, background.y)
			
			messagesField.setSize(stage.stageWidth - 2, CHAT_WIN_HEIGHT - INPUT_HEIGHT);
			messagesField.editable = false;
			messagesField.setStyle('upSkin', Shape);
			messagesField.setStyle('focusRectSkin', Shape);
			//ScrollBarStyle
			messagesField.setStyle('thumbUpSkin', ScrollBarSliderUp);
			messagesField.setStyle('thumbOverSkin', ScrollBarSliderOver);
			messagesField.setStyle('thumbDownSkin', ScrollBarSliderUp);
			messagesField.setStyle('trackUpSkin', ScrollBarTrackUp);
			messagesField.setStyle('upArrowUpSkin', ScrollBarBtnUpUp);
			messagesField.setStyle('upArrowOverSkin', ScrollBarBtnUpOver);
			messagesField.setStyle('upArrowDownSkin', ScrollBarBtnUpDown);
			messagesField.setStyle('downArrowUpSkin', ScrollBarBtnDownUp);
			messagesField.setStyle('downArrowOverSkin', ScrollBarBtnDownOver);
			messagesField.setStyle('downArrowDownSkin', ScrollBarBtnDownDown);
			//messagesField.textField.setTextFormat(new TextFormat('System', 13));
			messagesField.text = 'asd\nasdasdasd\nasdasdasdasd';
			
			inputField.height = INPUT_HEIGHT;
			inputField.width = stage.stageWidth;
			inputField.y = messagesField.x + messagesField.height;
			inputField.multiline = false;
			inputField.type = TextFieldType.INPUT;
			inputField.
			inputField.text = 'testtest';
			addChild(messagesField);
			addChild(inputField);
			this.y = stage.stageHeight - CHAT_WIN_HEIGHT;
		}
		
	}

}

import flash.display.Shape;
import flash.events.Event;
import flash.geom.Rectangle;

internal class ScrollBarSliderUp extends Shape {
	public function ScrollBarSliderUp() {
		graphics.lineStyle(0.1, 0x999999);
		graphics.beginFill(0xDDDDDD);
		graphics.drawRect(0, 0, 5, 5);
	}
}

internal class ScrollBarSliderOver extends Shape {
	public function ScrollBarSliderOver() {
		graphics.lineStyle(0.1, 0x999999);
		graphics.beginFill(0xEEEEEE);
		graphics.drawRect(0, 0, 5, 5);
	}
}

internal class ScrollBarSliderDown extends Shape {
	public function ScrollBarSliderDown() {
		graphics.beginFill(0xAAAAAA);
		graphics.drawRect(0, 0, 5, 5);
	}
}

internal class ScrollBarTrackUp extends Shape {
	public function ScrollBarTrackUp() {
		graphics.lineStyle(0.1, 0x999999);
		graphics.beginFill(0xBBBBBB);
		graphics.drawRect(0, 0, 5, 5);
	}
}

internal class ScrollBarBtnDownUp extends Shape {
	public function ScrollBarBtnDownUp() {
		graphics.lineStyle(0.1, 0x999999);
		graphics.beginFill(0xDDDDDD);
		graphics.drawRect(0, 0, 9, 9);
		graphics.moveTo(2, 3);
		graphics.lineTo(5, 6);
		graphics.lineTo(8, 3);
		graphics.endFill();
	}
}

internal class ScrollBarBtnDownOver extends Shape {
	public function ScrollBarBtnDownOver() {
		graphics.lineStyle(0.1, 0x999999);
		graphics.beginFill(0xEEEEEE);
		graphics.drawRect(0, 0, 9, 9);
		graphics.moveTo(2, 3);
		graphics.lineTo(5, 6);
		graphics.lineTo(8, 3);
		graphics.endFill();
	}
}

internal class ScrollBarBtnDownDown extends Shape {
	public function ScrollBarBtnDownDown() {
		graphics.lineStyle(0.1, 0x999999);
		graphics.beginFill(0xAAAAAA);
		graphics.drawRect(0, 0, 9, 9);
		graphics.moveTo(2, 3);
		graphics.lineTo(5, 6);
		graphics.lineTo(8, 3);
		graphics.endFill();
	}
}

internal class ScrollBarBtnUpUp extends Shape {
	public function ScrollBarBtnUpUp() {
		graphics.lineStyle(0.1, 0x999999);
		graphics.beginFill(0xDDDDDD);
		graphics.drawRect(0, 0, 9, 9);
		graphics.moveTo(2, 6);
		graphics.lineTo(5, 3);
		graphics.lineTo(8, 6);
		graphics.endFill();
	}
}

internal class ScrollBarBtnUpOver extends Shape {
	public function ScrollBarBtnUpOver() {
		graphics.lineStyle(0.1, 0x999999);
		graphics.beginFill(0xEEEEEE);
		graphics.drawRect(0, 0, 9, 9);
		graphics.moveTo(2, 6);
		graphics.lineTo(5, 3);
		graphics.lineTo(8, 6);
		graphics.endFill();
	}
}

internal class ScrollBarBtnUpDown extends Shape {
	public function ScrollBarBtnUpDown() {
		graphics.lineStyle(0.1, 0x999999);
		graphics.beginFill(0xAAAAAA);
		graphics.drawRect(0, 0, 9, 9);
		graphics.moveTo(2, 6);
		graphics.lineTo(5, 3);
		graphics.lineTo(8, 6);
		graphics.endFill();
	}
}