package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.ISVGViewPort;
	import com.lorentz.SVG.utils.Base64AsyncDecoder;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import com.lorentz.SVG.display.base.SVGElement;

	public class SVGImage extends SVGElement implements ISVGViewPort {
		include "includes/SVGViewPortProperties.as"
		
		private var _svgHrefChanged:Boolean = false;
		private var _svgHref:String;
		public function get svgHref():String {
			return _svgHref;
		}
		public function set svgHref(value:String):void {
			if(_svgHref != value){
				_svgHref = value;
				_svgHrefChanged = true;
				invalidateProperties();
			}
		}
		
		protected var _loader:Loader;
		
		protected var _base64AsyncDecoder:Base64AsyncDecoder;

		public function SVGImage() {
			super("image");
		}
				
		public function loadURL(url:String):void {
			if(_loader != null){
				_content.removeChild(_loader);
				_loader = null;
			}
			
			if(url!=null){
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
				_loader.load(new URLRequest(url));
				_content.addChild(_loader);
			}
		}
		
		//Thanks to youzi530, for coding base64 embed image support
		public function loadBase64(content:String):void
		{
			var base64String:String = content.replace(/^data:[a-z\/]*;base64,/, '');
			
			_base64AsyncDecoder = new Base64AsyncDecoder(base64String);
			_base64AsyncDecoder.addEventListener(Base64AsyncDecoder.COMPLETE, base64AsyncDecoder_completeHandler);
			_base64AsyncDecoder.addEventListener(Base64AsyncDecoder.ERROR, base64AsyncDecoder_errorHandler);
			_base64AsyncDecoder.decode();
		}
		
		private function base64AsyncDecoder_completeHandler(e:Event):void {
			loadBytes(_base64AsyncDecoder.bytes);
			_base64AsyncDecoder = null;
		}
		
		private function base64AsyncDecoder_errorHandler(e:Event):void {
			trace(_base64AsyncDecoder.errorMessage);
			_base64AsyncDecoder = null;
		}
		
		public function loadBytes(byteArray:ByteArray):void {
			if(_loader!=null){
				_content.removeChild(_loader);
				_loader = null;
			}
			
			if(byteArray!=null){
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
				_loader.loadBytes(byteArray);
				_content.addChild(_loader);
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();

			if(_svgHrefChanged)
			{
				_svgHrefChanged = false;
				
				if(svgHref != null && svgHref != ""){
					if(svgHref.match(/^data:[a-z\/]*;base64,/)){
						loadBase64(svgHref);
						beginASyncValidation("loadImage");
					} else {
						loadURL(document.resolveURL(svgHref));
						beginASyncValidation("loadImage");
					}
				}
			}
		}
		
		private function loadComplete(event:Event):void {
			if(_loader.content is Bitmap)
				(_loader.content as Bitmap).smoothing = true;
				
			updateViewPort();
			
			endASyncValidation("loadImage");
		}
		
		private function loadError(e:IOErrorEvent):void {
			trace("Failed to load image");
			updateViewPort();
			
			endASyncValidation("loadImage");
		}
		
		override protected function getViewPortContentBox():Rectangle {
			if(_loader == null || _loader.content == null)
				return null;
			
			return new Rectangle(0, 0, _loader.content.width, _loader.content.height);
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGImage = super.clone(deep) as SVGImage;
			c.svgHref = svgHref;
			return c;
		}
	}
}