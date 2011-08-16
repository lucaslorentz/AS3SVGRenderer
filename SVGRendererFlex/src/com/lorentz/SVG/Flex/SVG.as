package com.lorentz.SVG.Flex
{
	import com.lorentz.SVG.display.SVGDocument;
	import com.lorentz.SVG.events.SVGEvent;
	import com.lorentz.SVG.utils.DisplayUtils;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import mx.core.UIComponent;

	public class SVG extends UIComponent
	{		
		private var _svgDocument:SVGDocument;
		private var _sourceInvalid:Boolean = false;
		private var _urlLoader:URLLoader;
		private var _urlLoaderURL:String;
		private var _isLoading:Boolean = false;
		
		override protected function createChildren():void {
			super.createChildren();
			
			_svgDocument = new SVGDocument();
			_svgDocument.addEventListener(SVGEvent.VALIDATED, svgDocument_validatedHandler, false, 0, true);
			this.addChild(_svgDocument);
		}
		
		public function get svgDocument():SVGDocument {
			return _svgDocument;
		}
		
		private var _source:Object;
		[Bindable]
		public function get source():Object {
			return _source;
		}
		public function set source(value:Object):void {
			_source = value;
			_sourceInvalid = true;
			invalidateProperties();
		}
		
		private var _baseURL:Object;
		[Bindable]
		public function get baseURL():Object {
			return _baseURL;
		}
		public function set baseURL(value:Object):void {
			_baseURL = value;
		}
		
		private var _defaultFontName:String = "Verdana";
		[Bindable]
		public function get defaultFontName():String {
			return _defaultFontName;
		}
		public function set defaultFontName(value:String):void {
			_defaultFontName = value;
		}
		
		private var _validateWhileParsing:Boolean = false;
		[Bindable]
		public function get validateWhileParsing():Boolean {
			return _validateWhileParsing;
		}
		public function set validateWhileParsing(value:Boolean):void {
			_validateWhileParsing = value;
		}
		
		private var _allowTextSelection:Boolean = true;
		[Bindable]
		public function get allowTextSelection():Boolean {
			return _allowTextSelection;
		}
		public function set allowTextSelection(value:Boolean):void {
			
			_allowTextSelection = value;
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
						
			if(_sourceInvalid){
				_sourceInvalid = false;
				
				if((_source is String && !isXML(String(_source))) || _source is URLRequest)
				{
					this.load(_source);
				}
				else if(_source is String || _source is XML)
				{
					this.parse(_source, "");
				}
			}
		}
		
		private function isXML(str:String):Boolean {
			//Check if root node exist
			return /<(\S*).*<\/\1>\s*$/sg.test(str);
		}
		
		private function parse(xmlOrXmlString:Object, defaultBaseURL:String):void {
			//Set baseURL and defaultFont
			_svgDocument.defaultFont = _defaultFontName;
			_svgDocument.baseURL = _baseURL == null ? defaultBaseURL : String(_baseURL);
			_svgDocument.validateWhileParsing = _validateWhileParsing;
			_svgDocument.allowTextSelection = _allowTextSelection;

			this._svgDocument.parse(xmlOrXmlString);
		}
		
		private function clear():void {
			if(_isLoading)
			{
				_urlLoader.close();
				_urlLoader = null;
				_urlLoaderURL = "";
			}
			
			_svgDocument.clear();
		}
		
		private function load(urlOrUrlRequest:Object):void {			
			var urlRequest:URLRequest;
			
			if(urlOrUrlRequest is URLRequest)
				urlRequest = urlOrUrlRequest as URLRequest;
			else if(urlOrUrlRequest is String)
				urlRequest = new URLRequest(String(urlOrUrlRequest));
			else
				throw new Error("Invalid param 'urlOrUrlRequest'.");
						
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			_urlLoader.addEventListener(Event.COMPLETE, urlLoader_completeHandler, false, 0, true);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoader_ioErrorHandler, false, 0, true);
			_urlLoader.load(urlRequest);
			
			_isLoading = true;
			_urlLoaderURL = urlRequest.url;
		}
		
		private function urlLoader_completeHandler(e:Event):void {
			var defaultBaseURL:String = _urlLoaderURL.match(/^([^?]*\/)/g)[0]
			var svgString:String = String(_urlLoader.data);
			this.parse(svgString, defaultBaseURL);
			_urlLoader = null;
			_urlLoaderURL = "";
			_isLoading = false;
		}
		
		private function urlLoader_ioErrorHandler(e:IOErrorEvent):void {
			trace(e.text);
			_urlLoader = null;
			_urlLoaderURL = "";
			_isLoading = false;
		}
		
		private function svgDocument_validatedHandler(e:SVGEvent):void {
			this.invalidateSize();
		}
		
		override protected function measure():void {
			if(_svgDocument.scrollRect != null){
				this.measuredWidth = _svgDocument.scrollRect.width;
				this.measuredHeight = _svgDocument.scrollRect.height;
			} else {
				var bounds:Rectangle = DisplayUtils.safeGetBounds(_svgDocument, this);
				this.measuredWidth = bounds.left + _svgDocument.width;
				this.measuredHeight = bounds.top + _svgDocument.height;
			}
		}
	}
}