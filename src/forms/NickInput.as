package forms {
	import flash.display.Sprite;
	
	public class NickInput extends Sprite {
		
		private var _okButton: SuperButton;
		
		public function NickInput() {
			super();
			_okButton = new SuperButton(150, 40, "OkKome", 25, 0x009900);
			_okButton.y = 98;
			_okButton.x = 4;
			addChild(_okButton);
		}
		
		public function get okButton():SuperButton {
			return _okButton;
		}
		
	}

}