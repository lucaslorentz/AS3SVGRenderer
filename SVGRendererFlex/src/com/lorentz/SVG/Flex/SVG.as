package com.lorentz.SVG.Flex
{
	import com.lorentz.SVG.display.SVGDocument;
	import com.lorentz.SVG.events.SVGEvent;
	import com.lorentz.SVG.text.ISVGTextDrawer;
	import com.lorentz.SVG.utils.DisplayUtils;
	import com.lorentz.processing.ProcessExecutor;

    import flash.events.Event;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;

    import flash.geom.Rectangle;
    import flash.net.URLLoader;
    import flash.net.URLRequest;

    import mx.core.UIComponent;
	import mx.managers.ISystemManager;

    import spark.core.ContentRequest;
    import spark.core.IContentLoader;

    [Event(name="invalidate", type="com.lorentz.SVG.events.SVGEvent")]
	
	[Event(name="syncValidated", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="asyncValidated", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="validated", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="rendered", type="com.lorentz.SVG.events.SVGEvent")]
	
	[Event(name="parseStart", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="parseComplete", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="elementAdded", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="elementRemoved", type="com.lorentz.SVG.events.SVGEvent")]
	
	[Mixin]
	public class SVG extends UIComponent
	{
		public static function init(systemManager:ISystemManager):void {
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
        private var loadingContent:Object;


        private static const CLONED_EVENTS:Vector.<String> = new <String>[
			SVGEvent.INVALIDATE,
			SVGEvent.SYNC_VALIDATED,
			SVGEvent.ASYNC_VALIDATED,
			SVGEvent.VALIDATED,
			SVGEvent.RENDERED,
			SVGEvent.PARSE_START,
			SVGEvent.PARSE_COMPLETE,
			SVGEvent.ELEMENT_ADDED,
			SVGEvent.ELEMENT_REMOVED
		];
		
		public function SVG():void {
			svgDocument = new SVGDocument();
			super();
		}
		
		public function get svgDocument():SVGDocument {
			return _svgDocument;
		}
		
		public function set svgDocument(value:SVGDocument):void {
			var eventType:String;
			
			if(_svgDocument){
				_svgDocument.removeEventListener(SVGEvent.VALIDATED, svgDocument_validatedHandler, false);
				
				for each (eventType in CLONED_EVENTS)
					_svgDocument.removeEventListener(eventType, cloneAndRedispatchEvent);
				
				removeChild(_svgDocument);
			}
			
			_svgDocument = value;
			
			if(_svgDocument){
				_svgDocument.addEventListener(SVGEvent.VALIDATED, svgDocument_validatedHandler, false, 0, true);			

				for each (eventType in CLONED_EVENTS)
					_svgDocument.addEventListener(eventType, cloneAndRedispatchEvent);
					
				addChild(_svgDocument);
			}
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
		
		[Bindable]
		public function get baseURL():String {
			return _svgDocument.baseURL;
		}
		public function set baseURL(value:String):void {
			_svgDocument.baseURL = value;
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
		public function get forceSynchronousParse():Boolean {
			return _svgDocument.forceSynchronousParse;
		}
		public function set forceSynchronousParse(value:Boolean):void {
			_svgDocument.forceSynchronousParse = value;
		}
		
		[Bindable]
		public function get textDrawer():ISVGTextDrawer {
			return _svgDocument.textDrawer;
		}
		public function set textDrawer(value:ISVGTextDrawer):void {
			_svgDocument.textDrawer = value;
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
		 * Function that is called before sending svgTextToDraw to TextDrawer, allowing you to change texts formats with your own rule.
		 * The function can alter any property on textFormat
		 * Function parameters: function(textFormat:SVGTextFormat):void
		 * Example: Change all texts inside an svg to a specific embedded font
		 */
		public function get textDrawingInterceptor():Function {
			return _svgDocument.textDrawingInterceptor;
		}
		public function set textDrawingInterceptor(value:Function):void {
			_svgDocument.textDrawingInterceptor = value;
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


        //----------------------------------
        //  contentLoader
        //----------------------------------

        private var _contentLoader:IContentLoader;
        private var _contentLoaderInvalid:Boolean;

        /**
         *  Optional custom url loader (e.g. cache or queue) to
         *  associate with content loader client.
         *
         *  Don't use for it ContentCache, it works with images only. Use 'https://github.com/kelegorm/URLLoaderCache'.
         *
         *  @default null
         */
        public function get contentLoader():IContentLoader {
            return _contentLoader;
        }

        public function set contentLoader(value:IContentLoader):void {
            if (value != _contentLoader) {
                _contentLoader = value;
                _contentLoaderInvalid = true;
                invalidateProperties();
            }
        }

		override protected function commitProperties():void {
			super.commitProperties();
						
			if(_sourceInvalid || _contentLoaderInvalid) {
                applySource();

				_sourceInvalid = false;
                _contentLoaderInvalid = false;
			}
		}

        private function applySource():void {
            if ((_source is String && !isXML(String(_source))) || _source is URLRequest) {
                loadExternal(_source);
            }
            else if (_source is String || _source is XML) {
                _svgDocument.parse(_source);
            }
        }

        private function loadExternal(source:Object):void {
            if (contentLoader) {
                var contentRequest:ContentRequest = contentLoader.load(source);
                if (contentRequest.complete) {
                    readSVG(contentRequest.content);
                } else {
                    loadingContent = contentRequest;
                    attachLoadingListeners();
                }

            } else {
                _svgDocument.load(source);
            }
        }

        private function attachLoadingListeners():void {
            if (loadingContent) {
                loadingContent.addEventListener(Event.COMPLETE,
                        loader_completeHandler, false, 0, true);
                loadingContent.addEventListener(IOErrorEvent.IO_ERROR,
                        loader_ioErrorHandler, false, 0, true);
                loadingContent.addEventListener(ProgressEvent.PROGRESS,
                        loader_progressHandler, false, 0, true);
                loadingContent.addEventListener(SecurityErrorEvent.SECURITY_ERROR,
                        loader_securityErrorHandler, false, 0, true);
                loadingContent.addEventListener(HTTPStatusEvent.HTTP_STATUS,
                        dispatchEvent, false, 0, true);
            }
        }

        private function loader_progressHandler(event:ProgressEvent):void {
            // nothing
        }

        private function loader_securityErrorHandler(event:SecurityErrorEvent):void {
            clearLoadingContent();
        }

        private function loader_ioErrorHandler(event:IOErrorEvent):void {
            clearLoadingContent();
        }

        private function readSVG(content:*):void {
            if (content is URLLoader) {
                _svgDocument.parse((content as URLLoader).data);
            }
        }

        private function removeLoadingListeners():void {
            if (loadingContent) {
                loadingContent.removeEventListener(Event.COMPLETE,
                        loader_completeHandler);
                loadingContent.removeEventListener(IOErrorEvent.IO_ERROR,
                        loader_ioErrorHandler);
                loadingContent.removeEventListener(ProgressEvent.PROGRESS,
                        loader_progressHandler);
                loadingContent.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,
                        loader_securityErrorHandler);
                loadingContent.removeEventListener(HTTPStatusEvent.HTTP_STATUS,
                        dispatchEvent);
            }
        }

        private function loader_completeHandler(event:Event):void {
            var loader:URLLoader = event.target.content as URLLoader;

            if (loader) {
                readSVG(loader);
            }

            dispatchEvent(event);

            // Remove any event listeners from load-event dispatcher.
            clearLoadingContent();
        }

        private function clearLoadingContent():void {
            removeLoadingListeners();
            loadingContent = null;
        }

		private function cloneAndRedispatchEvent(e:SVGEvent):void {
			dispatchEvent(e.clone());
		}
		
		private function isXML(str:String):Boolean {
			//Check if root node exist
			return str.match(/<(\w*).*<\/\1>/sig).length > 0;
		}
		
		private function svgDocument_validatedHandler(e:SVGEvent):void {
			this.invalidateSize();
		}
		
		override protected function measure():void {
			if(_svgDocument != null)
			{				
				var bounds:Rectangle = DisplayUtils.safeGetBounds(_svgDocument, this);
				this.measuredWidth = bounds.left + bounds.width;
				this.measuredHeight = bounds.top + bounds.height;
			} else {
				this.measuredWidth = 0;
				this.measuredHeight = 0;
			}
		}
	}
}