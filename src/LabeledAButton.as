package {
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class LabeledAButton extends Sprite {
		
		public var button: AButton;
		public var labelText: TextField = new TextField();
		private var border: Shape = new Shape();
		
		public function LabeledAButton(width: Number, height: Number, label: String, upStateColor: uint, 
		overStateColor: Number = NaN, downStateColor: Number = NaN, borderWidth: Number = NaN, borderColor: uint = 0, borderAlpha: Number = 1) {
			button = new AButton(width, height, upStateColor, overStateColor, downStateColor, borderWidth, borderColor, borderAlpha);
			addChild(button);
			
			labelText.selectable = false;
			labelText.width = width;
			labelText.antiAliasType = AntiAliasType.ADVANCED;
			labelText.mouseEnabled = false;
			labelText.defaultTextFormat = new TextFormat('Calibri', 25, 0xFFFFFF, true);
			labelText.autoSize = TextFieldAutoSize.CENTER;
			labelText.text = label;
			labelText.y = (height - labelText.textHeight) / 2 - borderWidth;
			addChild(labelText);
			
			border.graphics.lineStyle(borderWidth, borderColor, borderAlpha);
			border.graphics.beginFill(0, 0);
			border.graphics.drawRect(0, 0, width, height);
			addChild(border);
			
			button.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
			button.addEventListener(MouseEvent.MOUSE_UP, onButtonUp);
			button.addEventListener(MouseEvent.MOUSE_OUT, onButtonUp);
		}
		
		private function onButtonDown(e: MouseEvent) {
			labelText.textColor = 0;
		}
		
		private function onButtonUp(e: MouseEvent) {
			labelText.textColor = 0xFFFFFF;
		}
		
		public function set label(newLabel: String) {
			(getChildByName(labelText.name) as TextField).text = newLabel;
		}
		
		public function get label(): String {
			return (getChildByName(labelText.name) as TextField).text;
		}
		
	}
	
}