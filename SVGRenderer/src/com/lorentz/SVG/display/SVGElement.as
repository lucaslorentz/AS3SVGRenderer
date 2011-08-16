package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.ISVGPreserveAspectRatio;
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.ISVGViewPort;
	import com.lorentz.SVG.events.SVGEvent;
	import com.lorentz.SVG.svg_internal;
	import com.lorentz.SVG.utils.MathUtils;
	import com.lorentz.SVG.utils.SVGUtil;
	import com.lorentz.SVG.utils.SVGViewPortUtils;
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	use namespace svg_internal;
	
	[Event(name="invalidate", type="com.lorentz.SVG.events.SVGEvent")]
	
	[Event(name="syncValidated", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="asyncValidated", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="validated", type="com.lorentz.SVG.events.SVGEvent")]
	
	public class SVGElement extends Sprite {
		protected var _content:Sprite;
		private var _mask:SVGElement;
		
		protected var _viewPortElement:ISVGViewPort;
		private var _currentFontSize:Number = Number.NaN;
		
		private var _type:String;
		private var _id:String;
		
		private var _svgClass:String;
		private var _svgClipPathChanged:Boolean = false;
		private var _svgClipPath:String;
		private var _svgMaskChanged:Boolean = false;
		private var _svgMask:String;
		private var _svgTransform:Matrix;
		protected var _styles:Object = {}; //Styles set to this element
		protected var _finalStyles:Object; //After inherit styles
		private var _parentElement:SVGElement;
		private var _document:SVGDocument;
		private var _numInvalidElements:int = 0;
		private var _numRunningAsyncValidations:int = 0;
		private var _invalidFlag:Boolean = false;
		private var _invalidStyleFlag:Boolean = false;
		private var _invalidPropertiesFlag:Boolean = false;
		private var _invalidTransformFlag:Boolean = false;
		private var runningAsyncValidations:Object = {};
		private var _displayChanged:Boolean = false;
		private var _opacityChanged:Boolean = false;
		
		public function SVGElement(tagName:String){
			_type = tagName;
			initialize();
		}
		
		protected function initialize():void {			
			_content = new Sprite();
			addChild(_content);
		}
				
		public function get type():String {
			return _type;
		}
		
		public function get id():String {
			return _id;
		}
		public function set id(value:String):void {
			_id = value;
		}

		public function get svgClass():String {
			return _svgClass;
		}
		public function set svgClass(value:String):void {
			_svgClass = value;
			invalidateStyle(true);
		}

		public function get svgClipPath():String {
			return _svgClipPath;
		}
		public function set svgClipPath(value:String):void {
			_svgClipPath = value;
			_svgClipPathChanged = true;
			invalidateProperties();
		}
		
		public function get svgMask():String {
			return _svgMask;
		}
		public function set svgMask(value:String):void {
			_svgMask = value;
			_svgMaskChanged = true;
			invalidateProperties();
		}
		
		public function get svgTransform():Matrix {
			return _svgTransform;
		}
		public function set svgTransform(value:Matrix):void {
			_svgTransform = value;
			_invalidTransformFlag = true;
			invalidateProperties();
		}
		
		/////////////////////////////
		// Stores a list of elements that are attached to this element
		/////////////////////////////
		private var _elementsAttached:Vector.<SVGElement> = new Vector.<SVGElement>();
		protected function attachElement(element:SVGElement):void {
			if(_elementsAttached.indexOf(element) == -1){
				_elementsAttached.push(element);
				element.svg_internal::setParentElement(this);
			}
		}
		protected function detachElement(element:SVGElement):void {
			var index:int = _elementsAttached.indexOf(element);
			if(index != -1){
				_elementsAttached.splice(index, 1);
				element.svg_internal::setParentElement(null);
			}
		}
		
		///////////////////////////////////////
		// Style manipulation
		///////////////////////////////////////
		public function getStyle(name:String):Object {
			return _styles[name];
		}
		public function getFinalStyle(name:String):Object {
			return _finalStyles(name);
		}
		public function setStyle(name:String, value:String):void {
			_styles[name] = value;
			invalidateStyle(true);
		}
		public function clearStyle(name:String):void {
			delete _styles[name];
			invalidateStyle(true);
		}
		public function getStyles():Object {
			return SVGUtil.cloneObject(_styles);
		}
		public function getFinalStyles():Object {
			return SVGUtil.cloneObject(_finalStyles);
		}
		public function setStyles(objectStyles:Object):void {
			for(var p:String in objectStyles)
				_styles[p] = objectStyles[p];
			invalidateStyle(true);
		}
		public function clearStyles():void {
			_styles = {};
			invalidateStyle(true);
		}
		///////////////////////////////////////
								
		public function get parentElement():SVGElement {
			return _parentElement;
		}
		
		svg_internal function setParentElement(value:SVGElement):void {
			if(_parentElement != value){
				if(_parentElement != null) {
					_parentElement.numInvalidElements -= _numInvalidElements;
					_parentElement.numRunningAsyncValidations -= _numRunningAsyncValidations;
				}
				
				_parentElement = value;
				
				if(_parentElement != null) {
					_parentElement.numInvalidElements += _numInvalidElements;
					_parentElement.numRunningAsyncValidations += _numRunningAsyncValidations;
				}
				
				setSVGDocument(_parentElement != null ? parentElement.document : null);
					
				invalidateStyle();
			}
		}
		
		public function get document():SVGDocument {
			return _document;
		}
		public function setSVGDocument(value:SVGDocument):void {
			if(_document != value){
				if(_document)
					_document.onElementRemoved(this);
				
				_document = value;
				
				if(_document)
					_document.onElementAdded(this);
				
				invalidateStyle(true);
				
				for each(var element:SVGElement in _elementsAttached){
					element.setSVGDocument(value);
				}
			}
		}
		
		protected function get numInvalidElements():int {
			return _numInvalidElements;
		}
		protected function set numInvalidElements(value:int):void {
			var d:int = value - _numInvalidElements;
			_numInvalidElements = value;
			if(_parentElement != null)
				_parentElement.numInvalidElements += d;
				
			if(_numInvalidElements == 0 && d != 0){
				dispatchEvent(new SVGEvent(SVGEvent.SYNC_VALIDATED));
				if(_numRunningAsyncValidations == 0)
					dispatchEvent(new SVGEvent(SVGEvent.VALIDATED));
			}
		}
		
		protected function get numRunningAsyncValidations():int {
			return _numRunningAsyncValidations;
		}
		protected function set numRunningAsyncValidations(value:int):void {
			var d:int = value - _numRunningAsyncValidations;
			_numRunningAsyncValidations = value;
			if(_parentElement != null)
				_parentElement.numRunningAsyncValidations += d;
				
			if(_numRunningAsyncValidations == 0 && d != 0) {
				dispatchEvent(new SVGEvent(SVGEvent.ASYNC_VALIDATED));
				if(_numInvalidElements == 0)
					dispatchEvent(new SVGEvent(SVGEvent.VALIDATED));
			}
		}
				
		private function invalidate():void {
			if(!_invalidFlag){											
				_invalidFlag = true;
								
				numInvalidElements += 1;
					
				dispatchEvent(new SVGEvent(SVGEvent.INVALIDATE));
			}
		}
		
		public function invalidateStyle(recursive:Boolean = true):void {
			if(!_invalidStyleFlag){
				_invalidStyleFlag = true;
				invalidate();
			}
			if(recursive) {
				for each(var element:SVGElement in _elementsAttached){
					element.invalidateStyle(recursive);
				}
			}
		}
		
		public function invalidateProperties():void {
			if(!_invalidPropertiesFlag){
				_invalidPropertiesFlag = true;
				invalidate();
			}
		}

		public function validate():void {
			if(_invalidStyleFlag)
				updateStyles();
				
			updateViewPortElement();
			updateCurrentFontSize();
			
			if(_invalidPropertiesFlag)
				commitProperties();

			if(_invalidFlag){
				_invalidFlag = false;
				numInvalidElements -= 1;
			}
			
			if(numInvalidElements > 0) {
				for each(var element:SVGElement in _elementsAttached){
					element.validate();
				}
			}
			
			if(this is ISVGViewPort)
				updateViewPort();
		}
		
		public function beginASyncValidation(validationId:String):void {
			if(runningAsyncValidations[validationId] == null){
				runningAsyncValidations[validationId] = true;
				numRunningAsyncValidations++;
			}
		}
		
		public function endASyncValidation(validationId:String):void {
			if(runningAsyncValidations[validationId] != null){
				numRunningAsyncValidations--;
				delete runningAsyncValidations[validationId];
			}
		}

		protected function updateStyles():void {
			_invalidStyleFlag = false;
			
			var oldFinalStyles:Object = _finalStyles || {};
			
			if(_parentElement){
				_finalStyles = _parentElement.getFinalStyles(); //Inherits parent style
			} else {
				_finalStyles = {};
			}

			if(document.styles[_type] != null){ //Merge with elements styles
				_finalStyles = SVGUtil.mergeObjects(_finalStyles, document.styles[_type]);
			}
			
			if(svgClass){ //Merge with classes styles
				for each(var className:String in svgClass.split(" "))
					_finalStyles = SVGUtil.mergeObjects(_finalStyles, document.styles["."+className]);
			}

			if(_styles) //Merge all styles with the style attribute
				_finalStyles = SVGUtil.mergeObjects(_finalStyles, _styles);
			
			//Check for changed styles
			var styleName:String;
			
			for(styleName in oldFinalStyles){
				if(oldFinalStyles[styleName] != _finalStyles[styleName])
					onStyleChanged(styleName, oldFinalStyles[styleName], _finalStyles[styleName]);
			}
			for(styleName in _finalStyles){
				if(!(styleName in oldFinalStyles))
					onStyleChanged(styleName, oldFinalStyles[styleName], _finalStyles[styleName]);
			}
		}
		
		protected function onStyleChanged(styleName:String, oldValue:String, newValue:String):void {
			switch(styleName){
				case "display" :
					_displayChanged = true;
					invalidateProperties();
					break;
				case "opacity" :
					_opacityChanged = true;
					invalidateProperties();
					break;
			}
		}
				
		private function computeTransformMatrix():Matrix {
			var mat:Matrix = null;
			
			if(this.transform.matrix){
				mat = this.transform.matrix;
				mat.identity();
			} else {
				mat = new Matrix();
			}
			
			mat.scale(scaleX, scaleY);
			mat.rotate(MathUtils.radiusToDegress(rotation));
			mat.translate(x, y);
			
			if(svgTransform != null)
				mat.concat(svgTransform);
			
			return mat;
		}
		
		protected function updateViewPortElement():void {			
			if(this is ISVGViewPort)
				_viewPortElement = this as ISVGViewPort;
			else if(_parentElement != null)
				_viewPortElement = _parentElement._viewPortElement;
			else
				_viewPortElement = null;
		}
		
		protected function updateCurrentFontSize():void {
			if(_finalStyles["font-size"])
				_currentFontSize = getUserUnit(_finalStyles["font-size"], SVGUtil.HEIGHT);
			else
				_currentFontSize = Number.NaN;
		}
		
		protected function commitProperties():void {
			_invalidPropertiesFlag = false;
			
			if(_invalidTransformFlag){
				_invalidTransformFlag = false;
				this.transform.matrix = computeTransformMatrix();
			}
			
			if(_svgClipPathChanged){
				_svgClipPathChanged = false;
				if(_mask != null) { //Clear mask
					_content.mask = null;
					_content.cacheAsBitmap = false;
					removeChild(_mask);
					detachElement(_mask);
					_mask = null;
				}
					
				if(svgClipPath != null && svgClipPath != "" && svgClipPath != "none"){ //Apply Clip Path
					var clipPathId:String = SVGUtil.extractUrlId(svgClipPath);

					_mask = document.getDefinitionClone(clipPathId);
					attachElement(_mask);
					addChild(_mask);
					_content.mask = _mask;
				}
			}
			
			if(_svgMaskChanged){
				_svgMaskChanged = false;
				if(_mask != null) { //Clear mask
					_content.mask = null;
					_content.cacheAsBitmap = false;
					removeChild(_mask);
					detachElement(_mask);
					_mask = null;
				}
				
				if(svgMask != null && svgMask!="" && svgMask!="none"){ //Apply Clip Path
					var maskId:String = SVGUtil.extractUrlId(svgMask);
					
					_mask = document.getDefinitionClone(maskId);
					attachElement(_mask);
					_mask.cacheAsBitmap = true;
					_content.cacheAsBitmap = true;
					addChild(_mask);
					_content.mask = _mask;
				}
			}	
			
			if(_displayChanged){
				_displayChanged = false;
				visible = _finalStyles["display"] != "none" && _finalStyles["visibility"] != "hidden";
			}
			
			if(_opacityChanged){
				_opacityChanged = false;
				_content.alpha = Number(_finalStyles["opacity"] || 1);
			}
			
			if(this is ISVGViewPort)
				updateViewPortSize();
		}

		protected function getFontSize(s:String):Number{
			var viewPortWidth:Number = 0;
			var viewPortHeight:Number = 0;
			
			if(_viewPortElement != null)
			{
				viewPortWidth = _viewPortElement.viewPortWidth;
				viewPortHeight = _viewPortElement.viewPortHeight;
			}
			
			return SVGUtil.getFontSize(s, _currentFontSize, viewPortWidth, viewPortHeight);
		}
		
		protected function getUserUnit(s:String, viewPortReference:String):Number {
			var viewPortWidth:Number = 0;
			var viewPortHeight:Number = 0;
			
			if(_viewPortElement != null)
			{
				viewPortWidth = _viewPortElement.viewPortWidth;
				viewPortHeight = _viewPortElement.viewPortHeight;
			}
			
			return SVGUtil.getUserUnit(s, _currentFontSize, viewPortWidth, viewPortHeight, viewPortReference);
		}
		
		public function clone(deep:Boolean = true):SVGElement {
			var clazz:Class = getDefinitionByName(getQualifiedClassName(this)) as Class;
			
			var copy:SVGElement = new clazz();
					
			copy.svgClass = svgClass;
			copy.svgClipPath = svgClipPath;
			copy.svgMask = svgMask;
			copy.setStyles(_styles);
			
			copy.svgTransform = svgTransform;
			
			if(this is ISVGViewBox)
				(copy as ISVGViewBox).svgViewBox = (this as ISVGViewBox).svgViewBox;
			
			if(this is ISVGPreserveAspectRatio)
				(copy as ISVGPreserveAspectRatio).svgPreserveAspectRatio = (this as ISVGPreserveAspectRatio).svgPreserveAspectRatio;
			
			if(this is ISVGViewPort){
				var thisViewPort:ISVGViewPort = this as ISVGViewPort;
				var cViewPort:ISVGViewPort = copy as ISVGViewPort;
				
				cViewPort.svgX = thisViewPort.svgX;
				cViewPort.svgY = thisViewPort.svgY;
				cViewPort.svgWidth = thisViewPort.svgWidth;
				cViewPort.svgHeight = thisViewPort.svgHeight;
				cViewPort.svgOverflow = thisViewPort.svgOverflow;
			}
			
			return copy;
		}
		
		
			
		/////////////////////////////////////////////////
		// ViewPort
		/////////////////////////////////////////////////
		private var _viewPortWidth:Number;
		public function get viewPortWidth():Number {
			return _viewPortWidth;
		}
		private var _viewPortHeight:Number;
		public function get viewPortHeight():Number {
			return _viewPortHeight;
		}
		
		protected function updateViewPortSize():void {
			var viewPort:ISVGViewPort = this as ISVGViewPort;
			
			if(viewPort == null)
				throw new Error("Element '"+type+"' isn't a viewPort.");
			
			if(this is ISVGViewBox && (this as ISVGViewBox).svgViewBox != null){
				_viewPortWidth = (this as ISVGViewBox).svgViewBox.width;
				_viewPortHeight = (this as ISVGViewBox).svgViewBox.height;
			} else {
				if(viewPort.svgWidth)
					_viewPortWidth = getUserUnit(viewPort.svgWidth, SVGUtil.WIDTH);
				if(viewPort.svgHeight)
					_viewPortHeight = getUserUnit(viewPort.svgHeight, SVGUtil.HEIGHT);
			}
		}
		
		protected function getViewPortContentBox():Rectangle {
			return null;
		}
		
		protected function updateViewPort():void {
			var viewPort:ISVGViewPort = this as ISVGViewPort;
			
			if(viewPort == null)
				throw new Error("Element '"+type+"' isn't a viewPort.");
		
			this.scrollRect = null;
			_content.scaleX = 1;
			_content.scaleY = 1;
			_content.x = 0;
			_content.y = 0;
			
			var box:Rectangle;
			if(this is ISVGViewBox)
				box = (this as ISVGViewBox).svgViewBox;
			else
				box = getViewPortContentBox();
			
			if(box != null && viewPort.svgWidth != null && viewPort.svgHeight != null) {
				var x:Number = viewPort.svgX ? getUserUnit(viewPort.svgX, SVGUtil.WIDTH) : 0;
				var y:Number = viewPort.svgY ? getUserUnit(viewPort.svgY, SVGUtil.HEIGHT) : 0;				
				var w:Number = getUserUnit(viewPort.svgWidth, SVGUtil.WIDTH);
				var h:Number = getUserUnit(viewPort.svgHeight, SVGUtil.HEIGHT);
				var viewPortBox:Rectangle = new Rectangle(x, y, w, h);
				
				var parts:Array = /(?:(defer)\s+)?(\w*)(?:\s+(meet|slice))?/gi.exec(String(viewPort.svgPreserveAspectRatio || "").toLowerCase());					
				var defer:Boolean = parts[1] != undefined;
				var align:String = parts[2] || "xmidymid";
				var meetOrSlice:String = parts[3] || "meet";
				
				var viewPortContentMetrics:Object = SVGViewPortUtils.getContentMetrics(viewPortBox, box, align, meetOrSlice);
					
				if(meetOrSlice == "slice"){
					this.scrollRect = viewPortBox;
				}
				
				_content.scaleX = viewPortContentMetrics.contentScaleX;
				_content.scaleY = viewPortContentMetrics.contentScaleY;
				_content.x = viewPortContentMetrics.contentX;
				_content.y = viewPortContentMetrics.contentY;
			}
		}
	}
}