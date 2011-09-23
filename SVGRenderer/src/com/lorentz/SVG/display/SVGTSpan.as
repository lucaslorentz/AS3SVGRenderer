package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.SVGTextContainer;
	import com.lorentz.SVG.svg_internal;
	import com.lorentz.SVG.utils.DisplayUtils;
	import com.lorentz.SVG.utils.SVGUtil;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import com.lorentz.SVG.display.base.SVGElement;
	
	use namespace svg_internal;
	
	public class SVGTSpan extends SVGTextContainer {	
		private var _svgX:String;
		public function get svgX():String {
			return _svgX;
		}
		public function set svgX(value:String):void {
			if(_svgX != value){
				_svgX = value;
				invalidateRender();
			}
		}
		
		private var _svgY:String;
		public function get svgY():String {
			return _svgY;
		}
		public function set svgY(value:String):void {
			if(_svgY != value){
				_svgY = value;
				invalidateRender();
			}
		}
		
		private var _svgDx:String;
		public function get svgDx():String {
			return _svgDx;
		}
		public function set svgDx(value:String):void {
			if(_svgDx != value){
				_svgDx = value;
				invalidateRender();
			}
		}
		
		private var _svgDy:String;
		public function get svgDy():String {
			return _svgDy;
		}
		public function set svgDy(value:String):void {
			if(_svgDy != value){
				_svgDy = value;
				invalidateRender();
			}
		}

		public function SVGTSpan(){
			super("tspan");
		}

		public function hasOwnFill():Boolean {
			return style.getPropertyValue("fill") != null && style.getPropertyValue("fill") != "" && style.getPropertyValue("fill") != "none";
		}
		
		override protected function render():void {
			super.render();
			
			while(_content.numChildren > 0)
				_content.removeChildAt(0);
						
			if(svgX)
				textOwner.currentX = getUserUnit(svgX, SVGUtil.WIDTH);
			if(svgY)
				textOwner.currentY = getUserUnit(svgY, SVGUtil.HEIGHT);
			
			if(svgDx)
				textOwner.currentX += getUserUnit(svgDx, SVGUtil.WIDTH);
			if(svgDy)
				textOwner.currentY += getUserUnit(svgDy, SVGUtil.HEIGHT);
						
			var fillMask:Sprite = new Sprite();
			_content.addChild(fillMask);
			
			for(var i:int = 0; i < this.numTextElements; i++){
				var textElement:Object = this.getTextElementAt(i);
				if(textElement is String){
					var createdText:Object = createTextSprite( textElement as String, textOwner.textFlow );
					
					var textSprite:Sprite = createdText.sprite;
					textSprite.x = textOwner.currentX;
					textSprite.y = textOwner.currentY - createdText.height;
					
					fillMask.addChild(textSprite);
					
					textOwner.currentX += createdText.xOffset;
				} else if(textElement is SVGTSpan) {
					var tspan:SVGTSpan = textElement as SVGTSpan;
										
					if(tspan.hasOwnFill())
						textOwner.textContainer.addChild(tspan);
					else
						fillMask.addChild(tspan);
					
					tspan.invalidateRender();
					tspan.validate();
				}				
			}
						
			var bounds:Rectangle = DisplayUtils.safeGetBounds(fillMask, _content);
			var fill:Sprite = new Sprite();
			beginFill(fill.graphics);
			fill.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
			fill.mask = fillMask;
			fillMask.cacheAsBitmap = true;
			fill.cacheAsBitmap = true;
			_content.addChildAt(fill, 0);
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGTSpan = super.clone(deep) as SVGTSpan;
			c.svgX = svgX;
			c.svgY = svgY;
			c.svgDx = svgDx;
			c.svgDy = svgDy;
			return c;
		}
	}
}