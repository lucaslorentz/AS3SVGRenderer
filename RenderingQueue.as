package {
	import flash.events.Event;
	import flash.display.Stage;
	import com.lorentz.SVG.SVGLoader;
	
	public class RenderingQueue {
		protected var _stage:Stage;
		
		public function RenderingQueue(stage:Stage):void {
			_stage = stage;
		}
		
		protected var _queueArray:Array = [];
		
		public function queue(svg:SVGLoader):void {
			if(_queueArray.length==0)
				_stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				
			_queueArray.push(svg);
		}
		
		public function unqueue(svg:SVGLoader):void {
			var i:int = _queueArray.indexOf(svg);
			_queueArray.splice(i, 1);
		}
		
		private function enterFrameHandler(e:Event):void {
			if(_queueArray.length>0){
				var svgLoader:SVGLoader = _queueArray.shift();
				svgLoader.render();
			} else {
				_stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
	}
}