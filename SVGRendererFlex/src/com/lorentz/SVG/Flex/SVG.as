package com.lorentz.SVG.Flex
{
	import com.lorentz.SVG.display.SVGDisplayEvent;
	import com.lorentz.SVG.display.SVGDocument;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
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
			
			this._svgDocument = new SVGDocument();
			this._svgDocument.addEventListener(SVGDisplayEvent.VALIDATED, svgDocument_validatedHandler, false, 0, true);
			this.addChild(_svgDocument);
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
			invalidateProperties();
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
			//Remove xml header, processing instructions, comments
			var withoutExtra:String = str.replace(/(?:(?:<\?(?:.|\s)+?\?>)|(?:<!(?:.|\s)+?>)|(?:^<!--(?:.|\s)+?-->))*/g, "");
			
			//Check if root node exist
			return /^\s*<([^\s]*)(?:.|\s)*?<\/\1>\s*$/g.test(withoutExtra);
		}
		
		private function parse(xmlOrXmlString:Object, defaultBaseURL:String):void {
			var xml:XML;
			
			if(xmlOrXmlString is String)
			{
				var oldXMLIgnoreWhitespace:Boolean = XML.ignoreWhitespace;
				XML.ignoreWhitespace = false;
				xml = new XML(xmlOrXmlString);
				XML.ignoreWhitespace = oldXMLIgnoreWhitespace; 
			}
			else if(xmlOrXmlString is XML)
				xml = xmlOrXmlString as XML;
			else
				throw new Error("Invalid param 'xmlOrXmlString'.");
			
			//Set baseURL			
			_svgDocument.baseURL = _baseURL == null ? defaultBaseURL : String(_baseURL);			

			this._svgDocument.parse(xml);
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
		
		private function svgDocument_validatedHandler(e:SVGDisplayEvent):void {
			this.invalidateSize();
		}
		
		override protected function measure():void {
			this.measuredWidth = _svgDocument.width;
			this.measuredHeight = _svgDocument.height;
		}
	}
}