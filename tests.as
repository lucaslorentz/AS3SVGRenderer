package {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.text.TextField;

	import com.lorentz.SVG.*;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import fl.controls.List;
	import fl.events.ListEvent;
	import fl.data.DataProvider;
	
	import flash.events.MouseEvent;

	public class tests extends Sprite {
		import flash.net.URLLoader;
		import flash.net.URLRequest;
		
		public function tests() {
			var array_itens:Array = new Array(
				"text01.svg",
				"tspan01.svg",
				"Units.svg",
				"lingrad01.svg",
				"arcs01.svg",
				"arcs02.svg",
				"butterfly.svg",
				"circles1.svg",
				"ellipse1.svg",
				"ellipse2.svg",
				"gradiente.svg",
				"gradiente_linear.svg",
				"gradients1.svg",
				"gradients2.svg",
				"line1.svg",
				"lion.svg",
				"path1.svg",
				"path2.svg",
				"paths1.svg",
				"paths2.svg",
				"paths3.svg",
				"polygons1.svg",
				"quadbezier1.svg",
				"rect1.svg",
				"rect2.svg",
				"rect4.svg",
				"skew1.svg",
				"tiger.svg",
				"toucan.svg"
				);

			lista.dataProvider = new DataProvider(array_itens);
			lista.addEventListener(fl.events.ListEvent.ITEM_CLICK, on_item_click);
		}
		
		private function on_item_click(e:ListEvent){
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, xmlComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load( new URLRequest("tests/"+e.item.data));
			
			information.text = "";
			if(shp!=null && shp.parent!=null)
				this.removeChild(shp);
				
			information.text = "Loading";
			
			stage.removeEventListener(MouseEvent.CLICK, traceClick);
		}
		private function onError(e:IOErrorEvent){
			information.text = "Cannot load the file";
		}
		
		private var shp:Sprite;
		private function xmlComplete(e:Event) {
			information.text = "Rendering";
			var svg:XML = new XML(e.target.data);
			import flash.utils.getTimer;
			var i:Number = getTimer();
			shp = new SVGRenderer(svg);
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