package {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import flash.text.TextField;

	import com.lorentz.SVG.display.*;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import fl.controls.List;
	import fl.events.ListEvent;
	import fl.data.DataProvider;
	
	import flash.events.MouseEvent;
	
	import flash.utils.getTimer;

	public class changeFillDisplay extends Sprite {
		import flash.net.URLLoader;
		import flash.net.URLRequest;
		
		private var shp:SVGDocument;
		
		public function changeFillDisplay() {
			var array_itens:Array = new Array(
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
				"svgFiles/toucan.svg"
				);

			lista.dataProvider = new DataProvider(array_itens);
			lista.addEventListener(fl.events.ListEvent.ITEM_CLICK, on_item_click);
			
			shp = new SVGDocument();
			shp.addEventListener(SVGDisplayEvent.ELEMENT_ADDED, elementAdded);
			shp.addEventListener(SVGDisplayEvent.ELEMENT_REMOVED, elementRemoved);
			this.addChildAt(shp, 0);
		}
				
		private function on_item_click(e:ListEvent){
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, xmlComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load( new URLRequest(e.item.data));
				
			information.text = "Loading";
		}
		
		private function onError(e:IOErrorEvent){
			information.text = "Cannot load the file";
		}
		
		private function xmlComplete(e:Event) {
			information.text = "Rendering";
			
			XML.ignoreWhitespace = false;
			var svg:XML = new XML(e.target.data);
			XML.ignoreWhitespace = true;
			
			var i:Number = getTimer();
			shp.parse(svg);
			var f:Number = getTimer();
			
			information.text = "Time elapsed: "+Number(f-i).toString();
		}
		
		protected function elementAdded(e:SVGDisplayEvent):void {
			var element:SVGElement = e.target as SVGElement;
			if(element is SVGShape){
				element.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
			}
		}
		
		protected function elementRemoved(e:SVGDisplayEvent):void {
			var element:SVGElement = e.target as SVGElement;
			if(element is SVGShape){
				element.removeEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
			}
		}
		
		protected function clickHandler(e:MouseEvent):void {
			var element:SVGElement = e.target as SVGElement;
			if(element!=null)
				element.setStyle("fill", "#"+colorPickerFill.hexValue);
		}
	}
}