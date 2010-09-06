package {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.text.TextField;

	import com.lorentz.SVG.*;
	import com.lorentz.SVG.display.SVGDocument;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import fl.controls.List;
	import fl.events.ListEvent;
	import fl.data.DataProvider;
	
	import flash.events.MouseEvent;
	
	import flash.utils.getTimer;

	public class testDisplay extends Sprite {
		import flash.net.URLLoader;
		import flash.net.URLRequest;
		
		public function testDisplay() {
			var array_itens:Array = new Array(
				"svgFiles/viewbox.svg",
				"svgFiles/viewbox2.svg",
				"svgFiles/simple_link.svg",
				"svgFiles/text01.svg",
				"svgFiles/tspan01.svg",
				"svgFiles/tspan02.svg",
				"svgFiles/Units.svg",
				"svgFiles/lingrad01.svg",
				"svgFiles/arcs01.svg",
				"svgFiles/arcs02.svg",
				"svgFiles/butterfly.svg",
				"svgFiles/circles1.svg",
				"svgFiles/ellipse1.svg",
				"svgFiles/ellipse2.svg",
				"svgFiles/gradiente.svg",
				"svgFiles/gradiente_linear.svg",
				"svgFiles/gradients1.svg",
				"svgFiles/gradients2.svg",
				"svgFiles/line1.svg",
				"svgFiles/lion.svg",
				"svgFiles/path1.svg",
				"svgFiles/path2.svg",
				"svgFiles/paths1.svg",
				"svgFiles/paths2.svg",
				"svgFiles/paths3.svg",
				"svgFiles/polygons1.svg",
				"svgFiles/quadbezier1.svg",
				"svgFiles/rect1.svg",
				"svgFiles/rect2.svg",
				"svgFiles/rect4.svg",
				"svgFiles/skew1.svg",
				"svgFiles/tiger.svg",
				"svgFiles/toucan.svg",
				"svgFiles/image.svg",
				"svgFiles/image2.svg"
				);

			lista.dataProvider = new DataProvider(array_itens);
			lista.addEventListener(fl.events.ListEvent.ITEM_CLICK, on_item_click);
		}
		
		private function on_item_click(e:ListEvent){
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, xmlComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load( new URLRequest(e.item.data));
			
			information.text = "";
			if(shp!=null && shp.parent!=null)
				this.removeChild(shp);
				
			information.text = "Loading";
			
			stage.removeEventListener(MouseEvent.CLICK, traceClick);
		}
		private function onError(e:IOErrorEvent){
			information.text = "Cannot load the file";
		}
		
		private var shp:SVGDocument;
		private function xmlComplete(e:Event) {
			information.text = "Rendering";
			
			XML.ignoreWhitespace = false;
			var svg:XML = new XML(e.target.data);
			XML.ignoreWhitespace = true;
			
			var i:Number = getTimer();
			shp = new SVGDocument();
			shp.baseURL = "svgFiles/"
			shp.parse(svg);
			var f:Number = getTimer();
			
			information.text = "Time elapsed: "+Number(f-i).toString();

			this.addChildAt(shp, 0);
			
			//Add the listener to find problems
			stage.addEventListener(MouseEvent.CLICK, traceClick);
		}
		function traceClick(e:MouseEvent):void {
			if(shp.contains(e.target as DisplayObject)){
				trace(e.target.name);
			}
		}
	}
}