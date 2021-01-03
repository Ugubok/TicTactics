package {
	
	import flash.display.SimpleButton;
	import flash.display.Shape;
	
	public class AButton extends SimpleButton {
		
		private const channelsOffset: int = 20; //Разница значений каналов RGB при осветлении/затемнении
		
		public function AButton(width: Number, height: Number, upStateColor: uint, 
		overStateColor: Number = NaN, downStateColor: Number = NaN, borderWidth: Number = NaN, borderColor: uint = 0, borderAlpha: Number = 1) {
			//Создает простую кнопку. Если overStateColor, downStateColor не указаны, 
			//их значением будет осветленный и затемненный цвет upStateColor соответственно 
			var rgb: Object;
			
			if (isNaN(overStateColor)) {
				rgb = ShapeManager.HexToRGB(upStateColor);
				rgb.r = (rgb.r + channelsOffset > 255) ? 255 : rgb.r + channelsOffset;
				rgb.g = (rgb.g + channelsOffset > 255) ? 255 : rgb.g + channelsOffset;
				rgb.b = (rgb.b + channelsOffset > 255) ? 255 : rgb.b + channelsOffset;
				overStateColor = ShapeManager.RGBToHex(rgb.r, rgb.g, rgb.b);
			}
			if (isNaN(downStateColor)) {
				rgb = ShapeManager.HexToRGB(upStateColor);
				rgb.r = (rgb.r - channelsOffset < 0) ? 0 : rgb.r - channelsOffset;
				rgb.g = (rgb.g - channelsOffset < 0) ? 0 : rgb.g - channelsOffset;
				rgb.b = (rgb.b - channelsOffset < 0) ? 0 : rgb.b - channelsOffset;
				downStateColor = ShapeManager.RGBToHex(rgb.r, rgb.g, rgb.b);
			}
			upState = ShapeManager.drawRectShape(Shape, width, height, upStateColor, borderWidth, borderColor, borderAlpha);
			overState = ShapeManager.drawRectShape(Shape, width, height, overStateColor, borderWidth, borderColor, borderAlpha);
			downState = ShapeManager.drawRectShape(Shape, width, height, downStateColor, borderWidth, borderColor, borderAlpha);
			hitTestState = upState;
		}
		
	}
	
}