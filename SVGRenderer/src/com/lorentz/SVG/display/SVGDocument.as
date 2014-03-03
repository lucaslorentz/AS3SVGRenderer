package com.lorentz.SVG.display {
	import com.lorentz.SVG.data.style.StyleDeclaration;
	import com.lorentz.SVG.display.base.SVGContainer;
	import com.lorentz.SVG.display.base.SVGElement;
	import com.lorentz.SVG.events.SVGEvent;
	import com.lorentz.SVG.parser.AsyncSVGParser;
	import com.lorentz.SVG.svg_internal;
	import com.lorentz.SVG.text.FTESVGTextDrawer;
	import com.lorentz.SVG.text.ISVGTextDrawer;
	import com.lorentz.SVG.utils.ICloneable;
	import com.lorentz.SVG.utils.SVGUtil;
	import com.lorentz.SVG.utils.StringUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	[Event(name="invalidate", type="com.lorentz.SVG.events.SVGEvent")]
	
	[Event(name="syncValidated", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="asyncValidated", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="validated", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="rendered", type="com.lorentz.SVG.events.SVGEvent")]
	
	[Event(name="parseStart", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="parseComplete", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="elementAdded", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="elementRemoved", type="com.lorentz.SVG.events.SVGEvent")]
	
	public class SVGDocument extends SVGContainer {
		private var _urlLoader:URLLoader;
		
		private var _parser:AsyncSVGParser;
		private var _parsing:Boolean = false;
						
		private var _definitions:Object = {};
		private var _stylesDeclarations:Object = {};
		private var _firstValidationAfterParse:Boolean = false;
		
		private var _defaultBaseUrl:String;
		
		private var _availableWidth:Number = 500;
		private var _availableHeight:Number = 500;
		
		/**
		 *  Computed base URL considering the svg path, is null when the svg was not loaded by the library
		 *  That property is used to load svg references, but it can be overriden using the property baseURL
		 */
		public function get defaultBaseUrl():String {
			return _defaultBaseUrl;
		}
		
		/**
		 * Url used as a base url to search referenced files on svg. 
		 */		
		public var baseURL:String;
		
		/**
		 * Determines that the document should validate rendering during parse.
		 * Set to true if you want to progressively show the SVG while it is parsing.
		 * Set to false to improve speed and show it only after parse is complete.
		 */		
		public var validateWhileParsing:Boolean = true;

		/**
		 * Determines if the document should force validation after parse, or should wait the document be on stage.  
		 */		
		public var validateAfterParse:Boolean = true;
		
		/**
		 * Determines if the document should parse the XML synchronous, without spanning processing on multiple frames
		 */
		public var forceSynchronousParse: Boolean = false;
		
		/**
		 * Default value for attribute fontStyle on SVGDocuments, and also is used an embedded font is missing, and missingFontAction on svgDocument is USE_DEFAULT.
		 */		
		public var defaultFontName:String = "Verdana";
		
		/**
		 * Determines if the document should use embedded 
		 */		
		public var useEmbeddedFonts:Boolean = true;
		
		/**
		 * Function that is called before sending svgTextToDraw to TextDrawer, allowing you to change texts formats with your own rule.
		 * The function can alter any property on textFormat
		 * Function parameters: function(textFormat:SVGTextFormat):void
		 * Example: Change all texts inside an svg to a specific embedded font
		 */		
		public var textDrawingInterceptor:Function;
		
		/**
		 * Object used to draw texts 
		 */		
		public var textDrawer:ISVGTextDrawer = new FTESVGTextDrawer();
		
		/*
		* Set to autmaticly align the topLeft of the rendered svg content to the svgDocument origin. 
		*/
		public var autoAlign:Boolean = false;
		
		public function SVGDocument(){			
			super("document");
		}
				
		public function load(urlOrUrlRequest:Object):void {
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
			
			_defaultBaseUrl = urlRequest.url.match(/^([^?]*\/)/g)[0]
			
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			_urlLoader.addEventListener(Event.COMPLETE, urlLoader_completeHandler, false, 0, true);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoader_ioErrorHandler, false, 0, true);
			_urlLoader.load(urlRequest);
		}
		
		private function urlLoader_completeHandler(e:Event):void {
			if(e.currentTarget != _urlLoader)
				return;
			
			var svgString:String = String(_urlLoader.data);
			parseInternal(svgString);
			_urlLoader = null;
		}
		
		private function urlLoader_ioErrorHandler(e:IOErrorEvent):void {
			if(e.currentTarget != _urlLoader)
				return;
			
			trace(e.text);
			_urlLoader = null;
		}
		
		public function parse(xmlOrXmlString:Object):void {
			_defaultBaseUrl = null;
			parseInternal(xmlOrXmlString);
		}
		
		private function parseInternal(xmlOrXmlString:Object):void {
			var xml:XML;
			
			if(xmlOrXmlString is String)
			{
				var xmlString:String = SVGUtil.processXMLEntities(String(xmlOrXmlString));
				
				var oldXMLIgnoreWhitespace:Boolean = XML.ignoreWhitespace;
				XML.ignoreWhitespace = false;
				xml = new XML(xmlString);
				XML.ignoreWhitespace = oldXMLIgnoreWhitespace; 
			}
			else if(xmlOrXmlString is XML)
				xml = xmlOrXmlString as XML;
			else
				throw new Error("Invalid param 'xmlOrXmlString'.");	
			
			parseXML(xml);
		}
						
		private function parseXML(svg:XML):void {			
			clear();
						
			if(_parsing)
				_parser.cancel();
						
			_parsing = true;
			
			if(hasEventListener(SVGEvent.PARSE_START))
				dispatchEvent( new SVGEvent( SVGEvent.PARSE_START ) );
			
			_parser = new AsyncSVGParser(this, svg);
			_parser.addEventListener(Event.COMPLETE, parser_completeHandler);
			_parser.parse(forceSynchronousParse);
		}

		
		protected function parser_completeHandler(e:Event):void {
			_parsing = false;
			_parser = null;
			
			if(hasEventListener(SVGEvent.PARSE_COMPLETE))
				dispatchEvent( new SVGEvent( SVGEvent.PARSE_COMPLETE ) );
			
			_firstValidationAfterParse = true;
			
			if(validateAfterParse)
				validate();
		}
		
		override protected function onValidated():void {
			super.onValidated();
			
			if(_firstValidationAfterParse)
			{
				_firstValidationAfterParse = false;
				if(hasEventListener(SVGEvent.RENDERED))
					dispatchEvent( new SVGEvent( SVGEvent.RENDERED ) );
			}
		}
		
		public function clear():void {
			id = null;
			svgClass = null;
			svgClipPath = null;
			svgMask = null;
			svgTransform = null;
			
			_stylesDeclarations = {};
			
			style.clear();
			
			for(var id:String in _definitions)
				removeDefinition(id);

			while(numElements > 0)
				removeElementAt(0);
			
			while(content.numChildren > 0)
				content.removeChildAt(0);
				
			content.scaleX = 1;
			content.scaleY = 1;
		}
		
		public function listStyleDeclarations():Vector.<String> {
			var selectorsList:Vector.<String> = new Vector.<String>();
			for(var id:String in _stylesDeclarations)
				selectorsList.push(id);
			return selectorsList;
		}
		
		public function addStyleDeclaration(selector:String, styleDeclaration:StyleDeclaration):void {
			_stylesDeclarations[selector] = styleDeclaration;
		}
		
		public function getStyleDeclaration(selector:String):StyleDeclaration {
			return _stylesDeclarations[selector];
		}
		
		public function removeStyleDeclaration(selector:String):StyleDeclaration {
			var value:StyleDeclaration = _stylesDeclarations[selector];
			delete _stylesDeclarations[selector];
			return value;
		}
		
		public function listDefinitions():Vector.<String> {
			var definitionsList:Vector.<String> = new Vector.<String>();
			for(var id:String in _definitions)
				definitionsList.push(id);
			return definitionsList;
		}
		
		public function addDefinition(id:String, object:Object):void {
			if(!_definitions[id]){
				_definitions[id] = object;
			}
		}
		
		public function hasDefinition(id:String):Boolean {
			return _definitions[id] != null;
		}
				
		public function getDefinition(id:String):Object {
			return _definitions[id];
		}
		
		public function getDefinitionClone(id:String):Object {
			var object:Object = _definitions[id];
			
			if(object is ICloneable)
				return (object as ICloneable).clone();

			return object;
		}
		
		public function removeDefinition(id:String):void {
			if(_definitions[id])
				_definitions[id] = null;
		}
		
		svg_internal function onElementAdded(element:SVGElement):void {
			if(hasEventListener(SVGEvent.ELEMENT_ADDED))
				dispatchEvent( new SVGEvent( SVGEvent.ELEMENT_ADDED, element ));
		}
		
		svg_internal function onElementRemoved(element:SVGElement):void {
			if(hasEventListener(SVGEvent.ELEMENT_REMOVED))
				dispatchEvent( new SVGEvent( SVGEvent.ELEMENT_REMOVED, element ));
		}

		public function resolveURL(url:String):String
		{
			var baseUrlFinal:String = baseURL || defaultBaseUrl;
			
			if (url != null && !isHttpURL(url) && baseUrlFinal)
			{
				if (url.indexOf("./") == 0)
					url = url.substring(2);

				if (isHttpURL(baseUrlFinal))
				{
					var slashPos:Number;
	
					if (url.charAt(0) == '/')
					{
						// non-relative path, "/dev/foo.bar".
						slashPos = baseUrlFinal.indexOf("/", 8);
						if (slashPos == -1)
							slashPos = baseUrlFinal.length;
					}
					else
					{
						// relative path, "dev/foo.bar".
						slashPos = baseUrlFinal.lastIndexOf("/") + 1;
						if (slashPos <= 8)
						{
							baseUrlFinal += "/";
							slashPos = baseUrlFinal.length;
						}
					}
	
					if (slashPos > 0)
						url = baseUrlFinal.substring(0, slashPos) + url;
				} else {
					url = StringUtil.rtrim(baseUrlFinal, "/") + "/" + url;
				}
			}
	
			return url;
		}
	
		public static function isHttpURL(url:String):Boolean
		{
			return url != null &&
				   (url.indexOf("http://") == 0 ||
					url.indexOf("https://") == 0);
		}
		
		override public function validate():void {
			super.validate();
			if(this.numInvalidElements > 0)
				queueValidation();
		}
		
		override protected function get numInvalidElements():int {
			return super.numInvalidElements;
		}

		override protected function set numInvalidElements(value:int):void {
			if(super.numInvalidElements == 0 && value > 0)
				queueValidation();

			super.numInvalidElements = value;
		}
		
		private var _validationQueued:Boolean
		protected function queueValidation():void {
			if(!_validationQueued){
				_validationQueued = false;
				
				if (stage != null) {
					stage.addEventListener(Event.ENTER_FRAME, validateCaller, false, 0, true);
					stage.addEventListener(Event.RENDER, validateCaller, false, 0, true);
					stage.invalidate();
				} else {
					addEventListener(Event.ADDED_TO_STAGE, validateCaller, false, 0, true);
				}
			}
		}
		
		protected function validateCaller(e:Event):void {
			_validationQueued = false;
			
			if(_parsing && !validateWhileParsing){
				queueValidation();
				return;
			}
			
			if (e.type == Event.ADDED_TO_STAGE) {
				removeEventListener(Event.ADDED_TO_STAGE, validateCaller);
			} else {
					e.target.removeEventListener(Event.ENTER_FRAME, validateCaller, false);
					e.target.removeEventListener(Event.RENDER, validateCaller, false);
					if (stage == null) {
						// received render, but the stage is not available, so we will listen for addedToStage again:
						addEventListener(Event.ADDED_TO_STAGE, validateCaller, false, 0, true);
						return;
					}
			}
			
			validate();
		}
		
		
		override protected function onPartialyValidated():void {
			super.onPartialyValidated();
			
			if(autoAlign)
			{
				var bounds:Rectangle = content.getBounds(content);
				content.x = -bounds.left;
				content.y = -bounds.top;
			} else {
				content.x = 0;
				content.y = 0;
			}
		}
		
		public function get availableWidth():Number {
			return _availableWidth;
		}
		public function set availableWidth(value:Number):void {
			_availableWidth = value;
		}
		
		public function get availableHeight():Number {
			return _availableHeight;
		}
		public function set availableHeight(value:Number):void {
			_availableHeight = value;
		}
		
		override public function clone():Object {
			var c:SVGDocument = super.clone() as SVGDocument;
			c.availableWidth = availableWidth;
			c.availableHeight = availableHeight;
			c._defaultBaseUrl = _defaultBaseUrl;
			c.baseURL = baseURL;
			c.validateWhileParsing = validateWhileParsing;
			c.validateAfterParse = validateAfterParse;
			c.defaultFontName = defaultFontName;
			c.useEmbeddedFonts = useEmbeddedFonts;
			c.textDrawingInterceptor = textDrawingInterceptor;
			c.textDrawer = textDrawer;
			
			for each(var id:String in listDefinitions()){
				var object:Object = getDefinition(id);
				if(object is ICloneable)
					c.addDefinition(id, (object as ICloneable).clone());
			}
			
			for each(var selector:String in listStyleDeclarations()){
				var style:StyleDeclaration = getStyleDeclaration(selector);
				c.addStyleDeclaration(selector, style.clone() as StyleDeclaration);
			}
			
			return c;
		}
	}
}