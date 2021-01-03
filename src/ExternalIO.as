package  {
	
	import flash.external.ExternalInterface;
	
	public class ExternalIO extends ExternalInterface {
		
		private var gm: GraphicsManager;
		
		public function ExternalIO(gm: GraphicsManager) {
			super();
			
			this.gm = gm;
			addCallback("clickCell", clickCell);
		}
		
		private function clickCell(coord: Object): String {
			try {
				var board: Board = gm.gameField.getBoardByCoord(coord.board.x, coord.board.y);
				var event: BoardEvents = new BoardEvents(BoardEvents.ON_CELL_CLICK);
				event.cell = board.getCellByCoord(coord.cell.x, coord.cell.y);
				board.dispatchEvent(event);
				return "OK";
			} catch (e: Error) {
				return e.name + ' ' + e.message;
			}
		}
		
	}

}