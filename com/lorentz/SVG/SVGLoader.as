/* Author: Lucas Lorentz Lara - 25/09/2008
*/

package com.lorentz.SVG{
	import flash.display.Sprite;

	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import flash.events.Event;
	
	import flash.events.IOErrorEvent;

	public class SVGLoader extends Sprite {
		protected static var version:String='1.1';

		protected var _svgXML:XML;
		protected var _svgSprite:SVGRenderer;
		protected var _render:Boolean = true;

		public function SVGLoader() {
		}

		public function load(url:URLRequest, render:Boolean = true) {
			_render = render;
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, fileLoadCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, fileLoadErrorHandler);
			loader.load( url);
		}
		
		private function fileLoadCompleteHandler(e:Event) {
			XML.ignoreWhitespace = false;
			_svgXML = new XML(e.target.data);
			XML.ignoreWhitespace = true;
			dispatchEvent(new SVGEvent(SVGEvent.LOAD_COMPLETE));
			if(_render)
				render();
		}
		
		private function fileLoadErrorHandler(e:IOErrorEvent):void {
			dispatchEvent(e);
		}
		
		public function render():void {
			if(_svgSprite!=null)
				this.removeChild(_svgSprite);
				
			_svgSprite = new SVGRenderer(_svgXML, false);
			_svgSprite.addEventListener(SVGEvent.PRE_RENDER_ELEMENT, triggerEvent);
			_svgSprite.addEventListener(SVGEvent.POS_RENDER_ELEMENT, triggerEvent);
			this.addChild(_svgSprite);
			_svgSprite.render();
			
			dispatchEvent(new SVGEvent(SVGEvent.RENDER_COMPLETE));
		}
		
		protected function triggerEvent(e:Event):void {
			dispatchEvent(e);
		}
	}
}