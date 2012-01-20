package com.lorentz.SVG.display.base
{
	import com.lorentz.SVG.data.text.SVGDrawnText;
	import com.lorentz.SVG.data.text.SVGTextFormat;
	import com.lorentz.SVG.display.SVGText;
	import com.lorentz.SVG.svg_internal;
	import com.lorentz.SVG.text.ISVGTextDrawer;
	import com.lorentz.SVG.utils.SVGColorUtils;
	import com.lorentz.SVG.utils.SVGUtil;
	import com.lorentz.SVG.utils.TextUtils;
	
	import flash.display.DisplayObject;
	import flash.text.Font;
	import flash.text.FontType;

	use namespace svg_internal;

	public class SVGTextContainer extends SVGGraphicsElement
	{
		private var _svgX:String;
		private var _svgY:String;
		private var _textOwner:SVGText;
		protected var _renderObjects:Vector.<DisplayObject>;
		
		public function SVGTextContainer(tagName:String) {
			super(tagName);
			
			if(this is SVGText)
				_textOwner = this as SVGText;
		}
		
		public function get svgX():String {
			return _svgX;
		}
		public function set svgX(value:String):void {
			if(_svgX != value){
				_svgX = value;
				invalidateRender();
			}
		}
		
		public function get svgY():String {
			return _svgY;
		}
		public function set svgY(value:String):void {
			if(_svgY != value){
				_svgY = value;
				invalidateRender();
			}
		}
		
		protected function get textOwner():SVGText {
			return _textOwner;
		}
		
		override svg_internal function setParentElement(value:SVGElement):void {
			super.svg_internal::setParentElement(value);
			
			if(!(this is SVGText)){
				var element:SVGElement = value;
				while(!(element is SVGText) && element != null)
					element = element.parentElement;
				_textOwner = element as SVGText;
			}
		}
		
		private var _textElements:Vector.<Object> = new Vector.<Object>();
		public function addTextElement(element:Object):void {
			addTextElementAt(element, numTextElements);
		}
		
		public function addTextElementAt(element:Object, index:int):void {
			_textElements.splice(index, 0, element);
			
			if(element is SVGElement)
				attachElement(element as SVGElement);
			
			invalidateRender();
		}
		
		public function getTextElementAt(index:int):Object {
			return _textElements[index];
		}
		
		public function get numTextElements():int {
			return _textElements.length;
		}
		
		public function removeTextElementAt(index:int):void {
			if(index < 0 || index >= numTextElements)
				return;
						
			var element:Object = _textElements[index];
			if(element is SVGElement)
				detachElement(element as SVGElement);
			
			invalidateRender();
		}
		
		override public function invalidateRender():void {
			super.invalidateRender();
			
			if(textOwner && textOwner != this)
				textOwner.invalidateRender();
		}
		
		override protected function onStyleChanged(styleName:String, oldValue:String, newValue:String):void {
			super.onStyleChanged(styleName, oldValue, newValue);
			
			switch(styleName){
				case "font-size" :
				case "font-family" :
				case "font-weight" :
					invalidateRender();
					break;
			}
		}
		
		protected function createTextSprite(text:String, textDrawer:ISVGTextDrawer):SVGDrawnText {
			//Gest last bidiLevel considering overrides
			var direction:String = TextUtils.getParagraphDirection(text);
			
			//Patch text adding direction chars, this will ensure spaces around texts will work properly
			if(direction == "rl")
				text = String.fromCharCode(0x200F) + text + String.fromCharCode(0x200F);
			else if(direction == "lr")
				text = String.fromCharCode(0x200E) + text + String.fromCharCode(0x200E);

			//Setup text format, to pass to the TextDrawer
			var format:SVGTextFormat = new SVGTextFormat();
			
			format.useEmbeddedFonts = document.useEmbeddedFonts;
			format.fontSize = getFontSize(finalStyle.getPropertyValue("font-size") || "medium");
			format.fontFamily = String(finalStyle.getPropertyValue("font-family") || document.defaultFontName);
			format.fontWeight = finalStyle.getPropertyValue("font-weight") || "normal";
			format.fontStyle = finalStyle.getPropertyValue("font-style") || "normal";
			
			if(document.changeTextFormatFunction != null)
				document.changeTextFormatFunction(format);
			
			//If need to draw in right color, pass color inside format
			if(!hasComplexFill)
				format.color = getFillColor();
			
			//Use configured textDrawer to draw text on a displayObject
			var drawnText:SVGDrawnText = textDrawer.drawText(this, text, format);

			//Change drawnText alpha if needed
			if(!hasComplexFill){
				if(hasFill)
					drawnText.displayObject.alpha = getFillOpacity();
				else
					drawnText.displayObject.alpha = 0;
			}
			
			//Adds direction to drawnTextInformation
			drawnText.direction = direction;
			
			return drawnText;
		}
		
		protected function get hasComplexFill():Boolean {
			var fill:String = finalStyle.getPropertyValue("fill");
			return fill && fill.indexOf("url") != -1;
		}
		
		private function getFillColor():uint {
			var fill:String = finalStyle.getPropertyValue("fill");
			
			if(fill == null || fill.indexOf("url") > -1)
				return 0x000000;
			else
				return SVGColorUtils.parseToUint(fill);
		}
		
		private function getFillOpacity():Number {
			return Number(finalStyle.getPropertyValue("fill-opacity") || 1);
		}
		
		protected function getDirectionFromStyles():String {
			var direction:String = finalStyle.getPropertyValue("direction");
			
			if(direction){
				switch(direction){
					case "ltr" :
						return "lr";
					case "tlr" :
						return "rl";
				}
			}
			
			var writingMode:String = finalStyle.getPropertyValue("writing-mode");
			
			switch(writingMode){
				case "lr" :
				case "lr-tb" :
					return "lr";
				case "rl" :
				case "rl-tb" :
					return "rl";
				case "tb" :
				case "tb-rl" :
					return "tb";
			}
			
			return null;
		}
				
		public function doAnchorAlign(direction:String, textStartX:Number, textEndX:Number):void {
			var textAnchor:String = finalStyle.getPropertyValue("text-anchor") || "start";
			
			var anchorX:Number = getUserUnit(svgX, SVGUtil.WIDTH);
			
			var offsetX:Number = 0;
			
			if(direction == "lr"){
				if(textAnchor == "start")
					offsetX += anchorX  - textStartX;
				if(textAnchor == "middle")
					offsetX += anchorX  - (textEndX + textStartX)/2;
				else if(textAnchor == "end")
					offsetX += anchorX  - textEndX;
			} else {
				if(textAnchor == "start")
					offsetX += anchorX  - textEndX;
				if(textAnchor == "middle")
					offsetX += anchorX  - (textEndX + textStartX)/2;
				else if(textAnchor == "end")
					offsetX += anchorX  - textStartX;
			}
			
			offset(offsetX);
		}
		
		public function offset(offsetX:Number):void {
			if(_renderObjects == null)
				return;
			
			for each(var renderedText:DisplayObject in _renderObjects)
			{
				if(renderedText is SVGTextContainer){
					var textContainer:SVGTextContainer = renderedText as SVGTextContainer;
					if(!textContainer.svgX)
						textContainer.offset(offsetX);
				} else {
					renderedText.x += offsetX;
				}
			}
		}
		
		public function hasOwnFill():Boolean {
			return style.getPropertyValue("fill") != null && style.getPropertyValue("fill") != "" && style.getPropertyValue("fill") != "none";
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGTextContainer = super.clone(deep) as SVGTextContainer;

			for(var i:int = 0; i < this.numTextElements; i++){
				var textElement:Object = this.getTextElementAt(i);
				if(textElement is String)
					c.addTextElement(textElement);
				else if(textElement is SVGElement)
					c.addTextElement((textElement as SVGElement).clone());
			}
			
			return c;
		}
	}
}