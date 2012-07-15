package com.lorentz.SVG.display.base {
	import com.lorentz.SVG.data.filters.SVGFilterCollection;
	import com.lorentz.SVG.data.style.StyleDeclaration;
	import com.lorentz.SVG.display.SVGDocument;
	import com.lorentz.SVG.events.SVGEvent;
	import com.lorentz.SVG.events.StyleDeclarationEvent;
	import com.lorentz.SVG.parser.SVGParserCommon;
	import com.lorentz.SVG.svg_internal;
	import com.lorentz.SVG.utils.MathUtils;
	import com.lorentz.SVG.utils.SVGUtil;
	import com.lorentz.SVG.utils.SVGViewPortUtils;
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	use namespace svg_internal;
	
	[Event(name="invalidate", type="com.lorentz.SVG.events.SVGEvent")]
	
	[Event(name="syncValidated", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="asyncValidated", type="com.lorentz.SVG.events.SVGEvent")]
	[Event(name="validated", type="com.lorentz.SVG.events.SVGEvent")]
	
	public class SVGElement extends Sprite {
		protected var content:Sprite;
		private var _mask:SVGElement;
		
		private var _currentFontSize:Number = Number.NaN;
		
		private var _type:String;
		private var _id:String;
		
		private var _svgClipPathChanged:Boolean = false;
		private var _svgMaskChanged:Boolean = false;
		private var _svgFilterChanged:Boolean = false;
		
		private var _style:StyleDeclaration;
		private var _finalStyle:StyleDeclaration;
		
		private var _parentElement:SVGElement;
		private var _viewPortElement:ISVGViewPort;
		private var _document:SVGDocument;
		private var _numInvalidElements:int = 0;
		private var _numRunningAsyncValidations:int = 0;
		private var _invalidFlag:Boolean = false;
		private var _invalidStyleFlag:Boolean = false;
		private var _invalidPropertiesFlag:Boolean = false;
		private var _invalidTransformFlag:Boolean = false;
		private var _runningAsyncValidations:Object = {};
		private var _displayChanged:Boolean = false;
		private var _opacityChanged:Boolean = false;
		private var _attributes:Object = {};
		
		public function SVGElement(tagName:String){
			_type = tagName;
			initialize();
		}
		
		protected function initialize():void {
			_style = new StyleDeclaration();
			_finalStyle = new StyleDeclaration();
			_finalStyle.addEventListener(StyleDeclarationEvent.PROPERTY_CHANGE, finalStyle_propertyChangeHandler, false, 0, true);
			
			content = new Sprite();
			addChild(content);
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
			return getAttribute("class") as String;
		}
		public function set svgClass(value:String):void {
			setAttribute("class", value);
		}
		
		public function get svgClipPath():String {
			return getAttribute("clip-path") as String;
		}
		public function set svgClipPath(value:String):void {
			setAttribute("clip-path", value);
		}
		
		public function get svgMask():String {
			return getAttribute("mask") as String;
		}
		public function set svgMask(value:String):void {
			setAttribute("mask", value);
		}
		
		public function get svgTransform():String {
			return getAttribute("transform") as String;
		}
		public function set svgTransform(value:String):void {
			setAttribute("transform", value);
		}
		
		public function getAttribute(name:String):Object {
			return _attributes[name];
		}
		
		public function setAttribute(name:String, value:Object):void {
			if(_attributes[name] != value){
				var oldValue:Object = _attributes[name];
				
				_attributes[name] = value;
				
				onAttributeChanged(name, oldValue, value);
			}
		}
		
		public function removeAttribute(name:String):void {
			delete _attributes[name];
		}
		
		public function hasAttribute(name:String):Boolean {
			return name in _attributes;
		}
		
		protected function onAttributeChanged(attributeName:String, oldValue:Object, newValue:Object):void {
			switch(attributeName){
				case "class" :
					invalidateStyle(true);
					break;
				case "clip-path" :
					_svgClipPathChanged = true;
					invalidateProperties();
					break;
				case "mask" :
					_svgMaskChanged = true;
					invalidateProperties();
					break;
				case "transform" :
					_invalidTransformFlag = true;
					invalidateProperties();
					break;
			}
		}
		
		/////////////////////////////
		// Stores a list of elements that are attached to this element
		/////////////////////////////
		private var _elementsAttached:Vector.<SVGElement> = new Vector.<SVGElement>();
		protected function attachElement(element:SVGElement):void {
			if(_elementsAttached.indexOf(element) == -1){
				_elementsAttached.push(element);
				element.setParentElement(this);
			}
		}
		protected function detachElement(element:SVGElement):void {
			var index:int = _elementsAttached.indexOf(element);
			if(index != -1){
				_elementsAttached.splice(index, 1);
				element.setParentElement(null);
			}
		}
		
		///////////////////////////////////////
		// Style manipulation
		///////////////////////////////////////
		public function get style():StyleDeclaration {
			return _style;
		}
		public function get finalStyle():StyleDeclaration {
			return _finalStyle;
		}
		///////////////////////////////////////
		
		public function get parentElement():SVGElement {
			return _parentElement;
		}
		
		protected function setParentElement(value:SVGElement):void {
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
				
				setSVGDocument(_parentElement != null ? _parentElement.document : null);
				setViewPortElement(_parentElement != null ? _parentElement.viewPortElement : null);
				
				invalidateStyle();
			}
		}		
		
		private function setSVGDocument(value:SVGDocument):void {
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
		
		private function setViewPortElement(value:ISVGViewPort):void {
			if(_viewPortElement != value){
				_viewPortElement = value;
				
				for each(var element:SVGElement in _elementsAttached){
					element.setViewPortElement(value);
				}
			}
		}
		
		public function get document():SVGDocument {
			return this is SVGDocument ? this as SVGDocument : _document;
		}
		
		public function get viewPortElement():ISVGViewPort {
			return this is ISVGViewPort ? this as ISVGViewPort : _viewPortElement;
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
				{
					dispatchEvent(new SVGEvent(SVGEvent.VALIDATED));
					onValidated();
				}
			}
		}
		
		protected function onValidated():void {
			
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
		
		protected function invalidate():void {
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
				adjustContentToViewPort();
		}
		
		public function beginASyncValidation(validationId:String):void {
			if(_runningAsyncValidations[validationId] == null){
				_runningAsyncValidations[validationId] = true;
				numRunningAsyncValidations++;
			}
		}
		
		public function endASyncValidation(validationId:String):void {
			if(_runningAsyncValidations[validationId] != null){
				numRunningAsyncValidations--;
				delete _runningAsyncValidations[validationId];
			}
		}
		
		protected function getElementToInheritStyles():SVGElement {
			return parentElement;
		}
		
		protected function updateStyles():void {
			_invalidStyleFlag = false;
			
			var newFinalStyle:StyleDeclaration = new StyleDeclaration();
			
			var inheritFrom:SVGElement = getElementToInheritStyles();
			if(inheritFrom){
				inheritFrom.finalStyle.copyStyles(newFinalStyle);
			}
			
			var typeStyle:StyleDeclaration = document.getStyleDeclaration(_type);
			if(typeStyle){ //Merge with elements styles
				typeStyle.copyStyles(newFinalStyle);
			}
			
			if(svgClass){ //Merge with classes styles
				for each(var className:String in svgClass.split(" ")){
					var classStyle:StyleDeclaration = document.getStyleDeclaration("."+className);
					if(classStyle)
						classStyle.copyStyles(newFinalStyle);
				}
			}
			
			//Merge all styles with the style attribute
			_style.copyStyles(newFinalStyle);
			
			//Apply new finalStyle
			newFinalStyle.cloneOn(_finalStyle);
		}
		
		private function finalStyle_propertyChangeHandler(e:StyleDeclarationEvent):void {
			onStyleChanged(e.propertyName, e.oldValue, e.newValue);
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
				case "filter" :
					_svgFilterChanged = true;
					invalidateProperties();
					break;
			}
		}
		
		protected function get shouldApplySvgTransform():Boolean {
			return true;
		}
		
		private function computeTransformMatrix():Matrix {
			var mat:Matrix = null;
			
			if(transform.matrix){
				mat = transform.matrix;
				mat.identity();
			} else {
				mat = new Matrix();
			}
			
			mat.scale(scaleX, scaleY);
			mat.rotate(MathUtils.radiusToDegress(rotation));
			mat.translate(x, y);
			
			if(shouldApplySvgTransform && svgTransform != null){
				var svgTransformMat:Matrix = SVGParserCommon.parseTransformation(svgTransform);
				if(svgTransformMat)
					mat.concat(svgTransformMat);
			}
			
			return mat;
		}
		
		public function get currentFontSize():Number {
			return _currentFontSize;
		}
		
		protected function updateCurrentFontSize():void {			
			_currentFontSize = Number.NaN;
			
			if(parentElement)
				_currentFontSize = parentElement.currentFontSize;
						
			var fontSize:String = finalStyle.getPropertyValue("font-size");
			if(fontSize)
				_currentFontSize = SVGUtil.getFontSize(fontSize, _currentFontSize, viewPortWidth, viewPortHeight);
			
			if(isNaN(_currentFontSize))
				_currentFontSize = SVGUtil.getFontSize("medium", currentFontSize, viewPortWidth, viewPortHeight);
		}
		
		protected function commitProperties():void {
			_invalidPropertiesFlag = false;
			
			if(_invalidTransformFlag){
				_invalidTransformFlag = false;
				transform.matrix = computeTransformMatrix();
			}
			
			if(_svgClipPathChanged){
				_svgClipPathChanged = false;
				if(_mask != null) { //Clear mask
					content.mask = null;
					content.cacheAsBitmap = false;
					removeChild(_mask);
					detachElement(_mask);
					_mask = null;
				}
				
				if(svgClipPath != null && svgClipPath != "" && svgClipPath != "none"){ //Apply Clip Path
					var clipPathId:String = SVGUtil.extractUrlId(svgClipPath);
					
					_mask = document.getElementDefinitionClone(clipPathId);
					attachElement(_mask);
					addChild(_mask);
					content.mask = _mask;
				}
			}
			
			if(_svgMaskChanged){
				_svgMaskChanged = false;
				if(_mask != null) { //Clear mask
					content.mask = null;
					content.cacheAsBitmap = false;
					removeChild(_mask);
					detachElement(_mask);
					_mask = null;
				}
				
				if(svgMask != null && svgMask!="" && svgMask!="none"){ //Apply Clip Path
					var maskId:String = SVGUtil.extractUrlId(svgMask);
					
					_mask = document.getElementDefinitionClone(maskId);
					attachElement(_mask);
					_mask.cacheAsBitmap = true;
					content.cacheAsBitmap = true;
					addChild(_mask);
					content.mask = _mask;
				}
			}
			
			if(_displayChanged){
				_displayChanged = false;
				visible = finalStyle.getPropertyValue("display") != "none" && finalStyle.getPropertyValue("visibility") != "hidden";
			}
			
			if(_opacityChanged){
				_opacityChanged = false;
				content.alpha = Number(finalStyle.getPropertyValue("opacity") || 1);
			}
			
			if(_svgFilterChanged){
				_svgFilterChanged = false;
				
				var filters:Array = [];
				
				var filterLink:String = finalStyle.getPropertyValue("filter");
				if(filterLink){
					var filterId:String = SVGUtil.extractUrlId(filterLink);
					var filterCollection:SVGFilterCollection = document.getDefinition(filterId) as SVGFilterCollection;
					if(filterCollection)
						filters = filterCollection.getFlashFilters();
				}
				
				this.filters = filters;
			}
			
			if(this is ISVGViewPort)
				updateViewPortSize();
		}
		
		protected function getViewPortUserUnit(s:String, reference:String):Number {
			var viewPortWidth:Number = 0;
			var viewPortHeight:Number = 0;
			
			if(viewPortElement != null)
			{
				viewPortWidth = viewPortElement.viewPortWidth;
				viewPortHeight = viewPortElement.viewPortHeight;
			}
			
			return SVGUtil.getUserUnit(s, _currentFontSize, viewPortWidth, viewPortHeight, reference);
		}
		
		public function clone(deep:Boolean = true):SVGElement {
			var clazz:Class = Object(this).constructor as Class;
			
			var copy:SVGElement = new clazz();
			
			copy.svgClass = svgClass;
			copy.svgClipPath = svgClipPath;
			copy.svgMask = svgMask;
			_style.cloneOn(copy.style);
			
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
					_viewPortWidth = getViewPortUserUnit(viewPort.svgWidth, SVGUtil.WIDTH);
				if(viewPort.svgHeight)
					_viewPortHeight = getViewPortUserUnit(viewPort.svgHeight, SVGUtil.HEIGHT);
			}
		}
		
		protected function getViewPortContentBox():Rectangle {
			return null;
		}
		
		protected function adjustContentToViewPort():void {
			var viewPort:ISVGViewPort = this as ISVGViewPort;
			
			if(viewPort == null)
				throw new Error("Element '"+type+"' isn't a viewPort.");
			
			scrollRect = null;
			content.scaleX = 1;
			content.scaleY = 1;
			content.x = 0;
			content.y = 0;
			
			var box:Rectangle;
			if(this is ISVGViewBox)
				box = (this as ISVGViewBox).svgViewBox;
			else
				box = getViewPortContentBox();
			
			if(box != null && viewPort.svgWidth != null && viewPort.svgHeight != null) {
				var x:Number = viewPort.svgX ? getViewPortUserUnit(viewPort.svgX, SVGUtil.WIDTH) : 0;
				var y:Number = viewPort.svgY ? getViewPortUserUnit(viewPort.svgY, SVGUtil.HEIGHT) : 0;				
				var w:Number = getViewPortUserUnit(viewPort.svgWidth, SVGUtil.WIDTH);
				var h:Number = getViewPortUserUnit(viewPort.svgHeight, SVGUtil.HEIGHT);
				
				if(viewPort.svgPreserveAspectRatio != "none"){
					var viewPortBox:Rectangle = new Rectangle(x, y, w, h);
					
					var preserveAspectRatio:Object = SVGParserCommon.parsePreserveAspectRatio(String(viewPort.svgPreserveAspectRatio || ""));
					
					var viewPortContentMetrics:Object = SVGViewPortUtils.getContentMetrics(viewPortBox, box, preserveAspectRatio.align, preserveAspectRatio.meetOrSlice);
					
					if(preserveAspectRatio.meetOrSlice == "slice"){
						this.scrollRect = viewPortBox;
					}
					
					content.scaleX = viewPortContentMetrics.contentScaleX;
					content.scaleY = viewPortContentMetrics.contentScaleY;
					content.x = viewPortContentMetrics.contentX;
					content.y = viewPortContentMetrics.contentY;
				} else {
					content.x = x;
					content.y = y;
					content.scaleX = w / content.width;
					content.scaleY = h / content.height;
				}
			}
		}
		
		/**
		 * metadata of the related SVG node as defined in the
		 * original SVG document
		 * @default null
		 **/
		public var metadata:XML;
	}
}