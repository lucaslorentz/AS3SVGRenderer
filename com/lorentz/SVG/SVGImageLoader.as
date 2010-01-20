/* Author: Lucas Lorentz Lara - 25/09/2008
*/

package com.lorentz.SVG{
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.Bitmap;
	
	import flash.events.Event;	
	import flash.events.IOErrorEvent;
	
	import flash.net.URLRequest;

	public class SVGImageLoader extends Sprite {
		protected var _loader:Loader;
		
		protected var _originalWidth:Number;
		protected var _originalHeight:Number;
		
		protected var _width:Number;
		protected var _height:Number;

		public function SVGImageLoader() {
			_width = 100;
			_height = 100;
		}

		protected var _preserveAspectRatio:Boolean = false;
		public function get preserveAspectRatio():Boolean {
			return _preserveAspectRatio;
		}
		public function set preserveAspectRatio(value:Boolean):void {
			_preserveAspectRatio = value;
			update();
		}
		
		
		override public function get width():Number {
			return _width;
		}
		override public function set width(w:Number):void {
			_width = w;
			update();
		}
		
		override public function get height():Number {
			return _height;
		}
		override public function set height(h:Number):void {
			_height = h;
			update();
		}
				
		public function load(url:String):void {
			if(_loader!=null){
				removeChild(_loader);
				_loader = null;
			}
			
			if(url!=null){
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
				_loader.load(new URLRequest(url));
				this.addChild(_loader);
			}
		}
		
		private function loadComplete(event:Event):void {
			if(_loader.content is Bitmap)
				(_loader.content as Bitmap).smoothing = true;
				
			_originalWidth = _loader.width;
			_originalHeight = _loader.height;
			
			update();
		}
		
		private function loadError(e:IOErrorEvent):void {
			trace("Failed to load image");
		}
		
		protected function update():void {			
			if(_loader!=null){
				var x:Number = 0;
				var y:Number = 0;
				var w:Number = _width;
				var h:Number = _height;
				
				if(_preserveAspectRatio){
					var rw:Number = w / _originalWidth;
					var rh:Number = h / _originalHeight;
					if(rw>rh){
						w = rh*_originalWidth;
						x = (_width - w) / 2; 
					} else {
						h = rw*_originalHeight;
						y = (_height - h) / 2;
					}
				}
				_loader.x = x;
				_loader.y = y;
				_loader.width = w;
				_loader.height = h;
			}
		}
	}
}