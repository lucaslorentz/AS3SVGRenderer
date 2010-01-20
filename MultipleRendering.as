package {
	import flash.display.MovieClip;
	import com.lorentz.SVG.SVGLoader;
	import com.lorentz.SVG.SVGEvent;
	import flash.net.URLRequest;
	import flash.events.Event;

	public class MultipleRendering extends MovieClip {
		protected var array_itens:Array = new Array(
				"tests/text01.svg",
				"tests/tspan01.svg",
				"tests/tspan02.svg",
				"tests/Units.svg",
				"tests/lingrad01.svg",
				"tests/arcs01.svg",
				"tests/arcs02.svg",
				"tests/butterfly.svg",
				"tests/circles1.svg",
				"tests/ellipse1.svg",
				"tests/ellipse2.svg",
				"tests/gradiente.svg",
				"tests/gradiente_linear.svg",
				"tests/gradients1.svg",
				"tests/gradients2.svg",
				"tests/line1.svg",
				"tests/lion.svg",
				"tests/path1.svg",
				"tests/path2.svg",
				"tests/paths1.svg",
				"tests/paths2.svg",
				"tests/paths3.svg",
				"tests/polygons1.svg",
				"tests/quadbezier1.svg",
				"tests/rect1.svg",
				"tests/rect2.svg",
				"tests/rect4.svg",
				"tests/skew1.svg",
				"tests/tiger.svg",
				"tests/toucan.svg",
				"tests/image.svg"
				);
		
		protected var svgQueue:RenderingQueue;
				
		public function MultipleRendering(){
			svgQueue = new RenderingQueue(stage);
			
			for each(var file:String in array_itens){
				var svg:SVGLoader = new SVGLoader();
				svg.load(new URLRequest(file), false);
				svg.addEventListener(SVGEvent.LOAD_COMPLETE, svgLoadCompleteHandler);
				this.addChild(svg);
			}
		}
		
		private function svgLoadCompleteHandler(e:SVGEvent):void {
			var svgLoader:SVGLoader = e.target as SVGLoader;
			svgQueue.queue(svgLoader);
		}
	}
}