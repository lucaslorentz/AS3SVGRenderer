/* Author: Lucas Lorentz Lara - 25/09/2008
*/

package com.lorentz.SVG{
	import flash.display.Sprite;

	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import flash.events.Event;

	public class SVGLoader extends Sprite {
		protected static  var version:String='1.1';

		private var _svgXML:XML=null;

		public function SVGLoader() {
		}

		public function load(url:URLRequest) {
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, svgLoadComplete);
			loader.load( url);
		}
		
		private function svgLoadComplete(e:Event) {
			_svgXML = new XML(e.target.data);
			var shp:Sprite = new SVGRenderer(_svgXML);
			shp.scaleX = 0.1;
			shp.scaleY = 0.1;

			this.addChild(shp);
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}