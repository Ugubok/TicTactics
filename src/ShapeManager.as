package {

	//import fl.controls.Button;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Shape;
	import fl.transitions.easing.*;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.display.GraphicsPathCommand;
	import flash.display.SimpleButton;
	import flash.text.Font;
	
	public class ShapeManager {
		
		[Embed(source="images/X.png")]
		public static var SymbolX: Class;
		[Embed(source="images/O.png")]
		public static var SymbolO: Class;
		
		//КЛЕТКА
		public static const CELL_SIZE: 								int 	= 40; //Размер грани клетки в пикселях (DEFAULT: 40)
		public static const CELL_BORDER_SIZE: 						int 	= 2; //Толщина рамки клетки
		public static const CELL_BORDER_SHADE_ALPHA:				Number 	= 0.4; //Коэф. затенения рамки от основного цвета
		public static const CELL_DEFAULT_COLOR:						uint 	= 0xC0C0C0; //Стандартный цвет
		public static const CELL_COLOR_2:							uint	= 0xEFEFEF; //Альтернативный цвет
		public static const CELL_SHADOW_COLOR:						uint	= 0x888888; //Цвет тени клетки
		public static const CELL_UP_OFFSET:							int		= -10; //Изменение высоты клетки при "поднятии"
		public static const CELL_UPDOWN_ANIM_DURATION: 				int		= 5; //Длительность анимации поднятия в кадрах
		public static const CELL_ANIM_UP_FUNCTION:      			Function = Regular.easeOut; //Функция описания движения поднятия
		public static const CELL_ANIM_DOWN_FUNCTION: 				Function = Regular.easeIn; // -- опускания
		//ДОСКА
		public static const BOARD_BORDER_WIDTH:						Number	= 0; //Толщина рамки
		public static const BOARD_DEFAULT_COLOR:					uint	= 0xEEEEEE; //Стандартный цвет фона
		public static const BOARD_DEFAULT_BORDER_COLOR:				uint	= 0x444444; //Стандартный цвет рамки
		public static const BOARD_HIGHLIGHT_COLOR:					uint	= 0x44FF44; //Цвет подсветки доски при указывании перенаправления
		public static const BOARD_CELL_SPACES:						Number	= 2; //Отступы между клетками
		public static const BOARD_COLS:				    			int	    = 3; //Столбцов
		public static const BOARD_ROWS:				    			int 	= 3; //Строк
		public static const BOARD_SIZE_OFFSET:						Number	= 0; //Дополнительно к размеру доски
		public static const BOARD_BLINKER_SIZE:						int		= 10; //Размер мигалки 
		public static const BOARD_BLINKER_ANIM_DURATION:			int		= 20; //Длительность анимации мигалки
		public static const BOARD_HIGHLIGHT_SIZE:					int		= 20; //Величина, на которую изменяется размер фона доски при подсветке
		public static const BOARD_HIGHLIGHT_ANIM_DURATION:			Number	= 0.8; //Длительность анимации подсветки
		//ИГРОВОЕ ПОЛЕ
		public static const GF_BOARD_SPACES:						Number	= -10; //Отступы между досками
		public static const GF_COLS:                    			int		= 3; //Столбцов
		public static const GF_ROWS:                    			int		= 3; //Строк
		
		public static const OPPONENT_CELLS_COLOR:					uint	= 0xDC143C; //Цвет клеток противника
		public static const PLAYER_CELLS_COLOR:						uint	= 0x34C924; //Цвет своих клеток
		public static const COMMON_CELLS_COLOR: 					uint	= 0x93088A; //Цвет ячеек на общей доске
		
		public static const BACKGROUND_GRADIENT_COLORS: 			Array	= [0xEEEEEE, 0x42AAFF]; //Цвета градиента фона
		public static const BACKGROUND_FIGURES_COUNT:				int		= 6; //Сколько анимированных фигурок (X/O) будет на фоне
		public static const BACKGROUND_FIGURES_MAX_SIZE:			Number	= 150; //Максимальный размер анимированных фигурок на фоне
		public static const BACKGROUND_FIGURES_MIN_SIZE:			Number	= 20; //Минимальный --
		public static const BACKGROUND_FIGURES_MAX_ANIM_DURATION:	Number	= 15; //Максимальное время анимации фигурок на фоне (в секундах)
		public static const BACKGROUND_FIGURES_MIN_ANIM_DURATION:	Number	= 7; //Минимальное --
		public static const BACKGROUND_FIGURES_MAX_ALPHA:			Number	= 0.6; //Максимальная прозрачность фигурок на фоне
		public static const BACKGROUND_FIGURES_MIN_ALPHA:			Number	= 0.1; //Минимальная --
		
		public static const MSG_VIEWER_SHADOW_ALPHA:				Number	= 0.5; //Прозрачность затенения при отображении сообщения
		public static const MSG_VIEWER_COLORS:						Array	= [0x1560BD, 0x34C924, 0xCD5C5C, 0xDF73FF, 0xEFD334]; //Цвета переливания окна сообщений
		public static const MSG_VIEWER_COLORS_ANIM_DURATION:		Number	= 5; //Длительность анимации переливания цвета окна сообщений (в секундах)
		public static const MSG_VIEWER_COLOR_ANIM_FUNCTION:			Function = Regular.easeInOut;
		public static const MSG_VIEWER_OPENCLOSE_ANIM_DURATION:		Number	= 1; //Длительность анимации открытия окна сообщений
		public static const MSG_VIEWER_MSGBOX_START_HEIGHT:			Number	= 5; //Начальная высота контейнера с сообщением
		public static const MSG_VIEWER_MSGBOX_HEIGHT:				Number	= 300; //Конечная высота --
		
		public static const CHAT_WIN_BACKGROUND_COLOR:				uint	= 0xDDDDDD; //Цвет фона окна чата
		public static const CHAT_WIN_ALPHA:							Number	= 0.5; //Прозрачность окна чата
		
		public static function drawCellShape(color: uint = 0xFFFFFF, cellSize:int = ShapeManager.CELL_SIZE): Shape {
			//Рисует фон клетки с рамкой
			var shape: Shape = new Shape();
			var borderShadeAlpha:Number = ShapeManager.CELL_BORDER_SHADE_ALPHA;
			var borderSize:int = ShapeManager.CELL_BORDER_SIZE;
			with (shape.graphics) {
				beginFill(color);
				drawRect(0, 0, cellSize, cellSize);
				beginFill(0, borderShadeAlpha);
				drawRect(0, 0, cellSize, cellSize);
				beginFill(color);
				drawRect(borderSize, borderSize, cellSize - borderSize * 2, cellSize - borderSize * 2);
			}
			
			return shape;
		}
		
		public static function HexToRGB(value: uint): Object {	
			var rgb: Object = new Object();
			rgb.r = (value >> 16) & 0xFF;
			rgb.g = (value >> 8) & 0xFF;
			rgb.b = value & 0xFF;
			return rgb;
		}
		
		public static function RGBToHex(r: int, g: int, b: int): uint {
			var hex:uint = r << 16 | g << 8 | b;
			return hex;
		}
		
	   /**
		* Складывает цвет color с цветом offset поканально.
		* @param color Изначальный цвет
		* @param offset Прибавляемый цвет (может быть отрицательным)
		* @usage colorShift(0xDDAA00, 0x111111); //Вернет 0xCC9900
		* @author Chr0niX
		* */
		public static function colorShift(color: uint, offset: int): uint {
			var c: Object = HexToRGB(color);
			var o: Object = HexToRGB(Math.abs(offset));
			if (offset < 0) {
				o.r = - o.r;
				o.g = - o.g;
				o.b = - o.b;
			}
			var r: int = c.r + o.r;
			var g: int = c.g + o.g;
			var b: int = c.b + o.b;
			
			if (r > 255) r = 255;
				else if (r < 0) r = 0;
			if (g > 255) g = 255;
				else if (g < 0) g = 0;
			if (b > 255) b = 255;
				else if (b < 0) b = 0;
			
			return RGBToHex(r, g, b);
		}
		
		public static function drawShadowSprite(color: uint = CELL_SHADOW_COLOR, width:Number = CELL_SIZE, height:Number = CELL_SIZE): Sprite {
			//Рисует тень клетки
			var sprite: Sprite = new Sprite();
			var cellUpOffset: int = -ShapeManager.CELL_UP_OFFSET;
			
			with (sprite.graphics) {
				beginFill(color);
				//Dark Side
				lineTo(cellUpOffset, -cellUpOffset);
				lineTo(cellUpOffset, height - cellUpOffset);
				lineTo(0, height);
				lineTo(width, height);
				lineTo(width + cellUpOffset, height - cellUpOffset);
				lineTo(cellUpOffset, height - cellUpOffset);
				lineTo(0, height);
				lineTo(0, 0);
				//Light Side
				beginFill(0, 0.4);
				moveTo(0, height);
				lineTo(width, height);
				lineTo(width + cellUpOffset, height - cellUpOffset);
				lineTo(cellUpOffset, height - cellUpOffset);
				lineTo(0, height);
			}
			
			return sprite;
		}
		
		public static function drawBoardShape(color: uint = ShapeManager.BOARD_DEFAULT_COLOR): Shape {
			//Рисует фон доски с рамкой
			var shape: Shape = new Shape();
			var cellSize:int = ShapeManager.CELL_SIZE;
			var cellSpaces:Number = ShapeManager.BOARD_CELL_SPACES;
			var borderWidth:Number = ShapeManager.BOARD_BORDER_WIDTH;
			var sizeOffset:Number = ShapeManager.BOARD_SIZE_OFFSET;
			var rows:int = ShapeManager.BOARD_ROWS;
			var cols:int = ShapeManager.BOARD_COLS;
			var width:Number = cellSize * rows + cellSpaces * (rows + 1) + sizeOffset;
			var height:Number = cellSize * cols + cellSpaces * (cols + 1) + sizeOffset;
			
			with (shape.graphics) {
				beginFill(ShapeManager.BOARD_DEFAULT_BORDER_COLOR);
				drawRect(0, 0, width, height);
				beginFill(color);
				drawRect(borderWidth, borderWidth, width - borderWidth * 2, height - borderWidth * 2);
			}
			
			return shape;
		}
		
		public static function drawBlinkerShape(color: uint, size:int = ShapeManager.CELL_SIZE): Sprite {
			//Рисует мигалку клетки
			var sprite: Sprite = new Sprite();
			with (sprite.graphics) {
				beginFill(color);
				drawRect(0, 0, size, size);
			}
			return sprite;
		}
		
		public static function drawBlinkerMask(): Sprite {
			//Рисует маску мигалки
			var sprite: Sprite = new Sprite();
			var blinkerSize:int = ShapeManager.BOARD_BLINKER_SIZE;
			var cellSize:int = ShapeManager.CELL_SIZE;
			with (sprite.graphics) {
				beginFill(0xFF00FF);
				drawRect( -blinkerSize, -blinkerSize, cellSize + blinkerSize, blinkerSize / 2);
				drawRect(cellSize - blinkerSize / 2 , -blinkerSize / 2, blinkerSize / 2, cellSize + blinkerSize / 2);
				drawRect( -blinkerSize, -blinkerSize / 2, blinkerSize / 2, cellSize);
				drawRect( -blinkerSize, cellSize - blinkerSize / 2, cellSize + blinkerSize / 2, blinkerSize / 2);
			}
			return sprite;
		}
		
		public static function drawBackgroundGradient(width: Number, height: Number): Shape {
			var shape: Shape = new Shape();
			var matrix: Matrix = new Matrix();
			matrix.createGradientBox(height, height, Math.PI / 8);
			with (shape.graphics) {
				beginGradientFill(GradientType.LINEAR, ShapeManager.BACKGROUND_GRADIENT_COLORS, [1, 1], [64, 255], matrix);
				drawRect(0, 0, height, width);
				
			}
			shape.y += height;
			shape.rotation = -90;
			return shape;
		}
		
		public static function drawXShape(color: uint = 0xFFFFFF): Shape {
			var shape: Shape = new Shape();
			var commands: Vector.<int> = new Vector.<int>(13, true);
			var coords: Vector.<Number> = new Vector.<Number>(26, true);
			var width:Number = 30;
			var height:Number = 30;
			for (var i:int = 0; i < commands.length; i++) {
				commands[i] = GraphicsPathCommand.LINE_TO;
			}
			coords = Vector.<Number>([
				width + width / 3, 0,
				width * 2, height,
				width * 3 - width / 3, 0,
				width * 4, 0,
				width * 3, height / 2 + height, //x: + width / 2
				width * 4, height * 3,
				width * 3 -  width / 3, height * 3,
				width * 2, height * 2,
				width +  width / 3, height * 3,
				0, height * 3,
				width, height / 2 + height,
				0, 0
			]);
			shape.graphics.beginFill(color);
			shape.graphics.drawPath(commands, coords);
			return shape;
		}
		
		public static function drawOShape(color: uint = 0xFFFFFF): Shape {
			var shape: Shape = new Shape();
			var radius:Number = 50;
			with (shape.graphics) {
				beginFill(color);
				drawCircle(radius, radius, radius);
				drawCircle(radius, radius, radius / 2);
			}
			return shape;
		}
		
		public static function drawMask(width: int, height: int): Sprite {
			var sprite: Sprite = new Sprite();
			with (sprite.graphics) {
				beginFill(0xFF00FF);
				drawRect(0, 0, width, height);
			}
			return sprite;
		}
		
		public static function drawRectShape(classType: Class, width: int, height: int, color: uint, 
		borderWidth: Number = NaN, borderColor: uint = 0, borderAlpha: Number = 1): DisplayObject {
			var shape:* = new classType();
			with (shape.graphics) {
				lineStyle(borderWidth, borderColor, borderAlpha);
				beginFill(color);
				drawRect(0, 0, width, height);
			}
			return shape;
		}
		
		public static function drawSuperButtonShape(width: int, height: int, color: uint, bevelSize: int = 2): Shape {
			var shape: Shape = new Shape();
			var colorOffset: uint = 0x222222; //Разница цвета для эффекта Bevel and Emboss
			with (shape.graphics) {
				//Эффект выпуклости
				beginFill(colorShift(color, colorOffset));
				drawRect(0, 0, width, height);
				beginFill(colorShift(color, -colorOffset));
				moveTo(0, height);
				lineTo(0 + bevelSize, height - bevelSize);
				lineTo(width - bevelSize, height - bevelSize);
				lineTo(width - bevelSize, bevelSize);
				lineTo(width, 0);
				lineTo(width, height);
				lineTo(0, height);
				//Сама кнопка
				beginFill(color);
				drawRect(bevelSize, bevelSize, width - bevelSize * 2, height - bevelSize * 2);
			}
			return shape;
		}
		
	}
	
}