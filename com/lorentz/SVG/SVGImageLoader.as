/* Author: Lucas Lorentz Lara - 25/09/2008
*/

package com.lorentz.SVG{
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.Bitmap;
	
	import flash.events.Event;	
	import flash.events.IOErrorEvent;
	
	import flash.net.URLRequest;
	
	import flash.utils.ByteArray;

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
				
		public function loadURL(url:String):void {
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
		
		//Thanks to youzi530, for coding base64 embed image support
		public function loadBase64(content:String):void
		{
			var decoder:Base64Decoder = new Base64Decoder();
			var byteArray:ByteArray;
			
			var base64String:String = content;
			
			base64String = base64String.replace(/^data:[a-z\/]*;base64,/, '');
			
			decoder.decode(base64String);
			byteArray = decoder.flush();
			
			loadBytes(byteArray);
		}
		
		public function loadBytes(byteArray:ByteArray):void {
			if(_loader!=null){
				removeChild(_loader);
				_loader = null;
			}
			
			if(byteArray!=null){
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
				_loader.loadBytes(byteArray);
				this.addChild(_loader);
			}
		}
		
		private function loadComplete(event:Event):void {
			if(_loader.content is Bitmap)
				(_loader.content as Bitmap).smoothing = true;
				
			_originalWidth = _loader.content.width;
			_originalHeight = _loader.content.height;

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