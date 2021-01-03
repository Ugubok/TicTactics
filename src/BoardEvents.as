package {
	
	import flash.events.Event;
	
	public class BoardEvents extends Event {
		
		public static const ON_CELL_CLICK: String = 'onCellClick';
		public static const ON_CELL_UP_COMPLETE: String = 'onCellUpComplete';
		
		public var cell: Cell;
		
		public function BoardEvents(type: String) {
			super(type, true);
		}
		
		public override function clone(): Event {
			var e: BoardEvents = new BoardEvents(type);
			if(e.cell != null) e.cell = cell;
			return e;
		}
		
		public override function toString(): String {
			return formatToString("BoardEvents", "type", "bubbles", "cancelable", "eventPhase", "cell");
		}
	}
	
}