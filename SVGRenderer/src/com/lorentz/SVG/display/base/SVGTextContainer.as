package com.lorentz.SVG.display.base
{
	import com.lorentz.SVG.display.SVGText;
	import com.lorentz.SVG.svg_internal;
	import com.lorentz.SVG.utils.SVGColorUtils;
	import com.lorentz.SVG.utils.TextUtils;
	
	import flash.text.engine.FontWeight;
	
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextLayoutFormat;

	use namespace svg_internal;

	public class SVGTextContainer extends SVGGraphicsElement
	{
		public function SVGTextContainer(tagName:String) {
			super(tagName);
			
			if(this is SVGText)
				_textOwner = this as SVGText;
		}
		
		private var _textOwner:SVGText;
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
		
		protected function createTextSprite(text:String, textFlow:TextFlow):Object {
			var format:TextLayoutFormat = new TextLayoutFormat();
			
			format.fontSize = getFontSize(finalStyle.getPropertyValue("font-size") || "medium");
			format.fontFamily = String(finalStyle.getPropertyValue("font-family") || document.defaultFontName);
			format.fontWeight = finalStyle.getPropertyValue("font-weight") == "bold" ? FontWeight.BOLD : FontWeight.NORMAL;
			format.fontLookup = document.fontLookup;
			
			if(!hasComplexFill)
				format.color = getFillColor();
			
			var textObject:Object = TextUtils.createTextSprite(text, textFlow, format);
			
			if(!hasComplexFill){
				if(hasFill)
					textObject.sprite.alpha = getFillOpacity();
				else
					textObject.sprite.alpha = 0;
			}
			
			return textObject;
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