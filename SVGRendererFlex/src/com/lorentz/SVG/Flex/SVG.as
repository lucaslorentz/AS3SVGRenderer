package com.lorentz.SVG.Flex
{
	import com.lorentz.SVG.display.SVGDocument;
	import com.lorentz.SVG.events.SVGEvent;
	import com.lorentz.SVG.utils.DisplayUtils;
	import com.lorentz.processing.ProcessExecutor;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import mx.core.UIComponent;
	import mx.managers.ISystemManager;

	[Event(name="parseStart", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="parseComplete", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="elementAdded", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="elementRemoved", type="com.lorentz.SVG.events.SVGEvent")]
	
	[Mixin]
	public class SVG extends UIComponent
	{
		public static function init(systemManager:ISystemManager):void
		{
			ProcessExecutor.instance.initialize(systemManager.stage);
		}
		
		public function get percentFrameProcessingTime():Number {
			return ProcessExecutor.instance.percentFrameProcessingTime;
		}
		public function set percentFrameProcessingTime(value:Number):void {
			ProcessExecutor.instance.percentFrameProcessingTime = value;
		}
		
		private var _svgDocument:SVGDocument;
		private var _sourceInvalid:Boolean = false;
		private var _urlLoader:URLLoader;
		private var _urlLoaderURL:String;
		
		private static const CLONED_EVENTS:Vector.<String> = new <String>[
			SVGEvent.PARSE_START,
			SVGEvent.PARSE_COMPLETE,
			SVGEvent.RENDERED,
			SVGEvent.ELEMENT_ADDED,
			SVGEvent.ELEMENT_REMOVED,
			SVGEvent.INVALIDATE,
			SVGEvent.SYNC_VALIDATED,
			SVGEvent.ASYNC_VALIDATED,
			SVGEvent.VALIDATED
		];
		
		public function SVG():void {
			_svgDocument = new SVGDocument();
			_svgDocument.addEventListener(SVGEvent.VALIDATED, svgDocument_validatedHandler, false, 0, true);
			
			for each (var eventType:String in CLONED_EVENTS)
			{
				_svgDocument.addEventListener(eventType, cloneAndRedispatchEvent);
			}
			
			this.addChild(_svgDocument);
			
			super();
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
		
		[Bindable]
		/**
		 * @default true
		 **/
		public function get validateWhileParsing():Boolean {
			return _svgDocument.validateWhileParsing;
		}
		public function set validateWhileParsing(value:Boolean):void {
			_svgDocument.validateWhileParsing = value;
		}
		
		[Bindable]
		/**
		 * @default true
		 **/
		public function get textDrawerClass():Class {
			return _svgDocument.textDrawerClass;
		}
		public function set textDrawerClass(value:Class):void {
			_svgDocument.textDrawerClass = value;
		}
		
		[Bindable]
		public function get defaultFontName():String {
			return _svgDocument.defaultFontName;
		}
		public function set defaultFontName(value:String):void {
			_svgDocument.defaultFontName = value;
		}
		
		[Bindable]
		/**
		 * Function that is called before sending svgTextFormat to TextDrawer, allowing you to change texts formats with your own rule.
		 * The function can alter any property on textFormat
		 * Function parameters: function(textFormat:SVGTextFormat):void
		 * Example: Change all texts inside an svg to a specific embedded font
		 */
		public function get changeTextFormatFunction():Function {
			return _svgDocument.changeTextFormatFunction;
		}
		public function set changeTextFormatFunction(value:Function):void {
			_svgDocument.changeTextFormatFunction = value;
		}
		
		[Bindable]
		[Inspectable(defaultValue="false")]
		/**
		 * Determines if the document should use embedded fonts or not 
		 */		
		public function get useEmbeddedFonts():Boolean {
			return _svgDocument.useEmbeddedFonts;
		}
		public function set useEmbeddedFonts(value:Boolean):void {
			_svgDocument.useEmbeddedFonts = value;
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
		
		private function cloneAndRedispatchEvent(e:SVGEvent):void
		{
			dispatchEvent(e.clone());
		}
		
		private function isXML(str:String):Boolean {
			//Check if root node exist
			return str.match(/<(\w*).*<\/\1>/sig).length > 0;
		}
		
		private function parse(xmlOrXmlString:Object, defaultBaseURL:String):void {
			//Set baseURL and defaultFont
			_svgDocument.baseURL = _baseURL == null ? defaultBaseURL : String(_baseURL);

			this._svgDocument.parse(xmlOrXmlString);
		}
		
		private function load(urlOrUrlRequest:Object):void {
			if(_urlLoader != null){
				try {
					_urlLoader.close();
				} catch (e:Error) { }
				_urlLoader = null;
			}
			
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
			
			_urlLoaderURL = urlRequest.url;
		}
		
		private function urlLoader_completeHandler(e:Event):void {
			if(e.currentTarget != _urlLoader)
				return;
			
			var defaultBaseURL:String = _urlLoaderURL.match(/^([^?]*\/)/g)[0]
			var svgString:String = String(_urlLoader.data);
			this.parse(svgString, defaultBaseURL);
			_urlLoader = null;
			_urlLoaderURL = "";
		}
		
		private function urlLoader_ioErrorHandler(e:IOErrorEvent):void {
			if(e.currentTarget != _urlLoader)
				return;
			
			trace(e.text);
			_urlLoader = null;
			_urlLoaderURL = "";
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