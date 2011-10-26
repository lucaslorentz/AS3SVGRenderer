package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.SVGElement;
	import com.lorentz.SVG.display.base.SVGTextContainer;
	import com.lorentz.SVG.svg_internal;
	import com.lorentz.SVG.utils.DisplayUtils;
	import com.lorentz.SVG.utils.SVGUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
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
		
		private var _renderObjects:Vector.<DisplayObject>;
		private var _start:Number = 0;
		private var _end:Number = 0;
		private var _endDirection:String;
				
		override protected function render():void {
			super.render();
			
			while(_content.numChildren > 0)
				_content.removeChildAt(0);
			
			var direction:String = getDirectionFromStyles() || "lr";
			var textDirection:String = direction;
						
			if(svgX)
				textOwner.currentX = getUserUnit(svgX, SVGUtil.WIDTH);
			if(svgY)
				textOwner.currentY = getUserUnit(svgY, SVGUtil.HEIGHT);
			
			_start = textOwner.currentX;
			_renderObjects = new Vector.<DisplayObject>();
			
			if(svgDx)
				textOwner.currentX += getUserUnit(svgDx, SVGUtil.WIDTH);
			if(svgDy)
				textOwner.currentY += getUserUnit(svgDy, SVGUtil.HEIGHT);
						
			var fillTextsSprite:Sprite;
			
			if(hasComplexFill)
			{
				fillTextsSprite = new Sprite();
				_content.addChild(fillTextsSprite);
			} else {
				fillTextsSprite = _content;				
			}
			
			for(var i:int = 0; i < numTextElements; i++){
				var textElement:Object = getTextElementAt(i);
				if(textElement is String){
					var createdText:Object = createTextSprite( textElement as String, textOwner.textFlow );
					
					var textSprite:DisplayObject = createdText.sprite;
					
					if((createdText.direction || direction) == "lr"){
						textSprite.x = textOwner.currentX;
						textSprite.y = textOwner.currentY - createdText.ascent;
						textOwner.currentX += createdText.width;
					} else {
						textSprite.x = textOwner.currentX - createdText.width;
						textSprite.y = textOwner.currentY - createdText.ascent;
						textOwner.currentX -= createdText.width;
					}

					if(createdText.direction)	
						textDirection = createdText.direction;
					
					fillTextsSprite.addChild(textSprite);
					_renderObjects.push(textSprite);
				} else if(textElement is SVGTSpan) {
					var tspan:SVGTSpan = textElement as SVGTSpan;
										
					if(tspan.hasOwnFill()){
						textOwner.textContainer.addChild(tspan);
					}else
						fillTextsSprite.addChild(tspan);
					
					tspan.invalidateRender();
					tspan.validate();
					
					_renderObjects.push(tspan);
				}				
			}
			
			_end = textOwner.currentX;
						
			if(svgX)
				doAnchorAlign(textDirection);
						
			if(hasComplexFill && fillTextsSprite.numChildren > 0){
				var bounds:Rectangle = DisplayUtils.safeGetBounds(fillTextsSprite, _content);
				bounds.inflate(2, 2);
				var fill:Sprite = new Sprite();
				beginFill(fill.graphics);
				fill.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
				fill.mask = fillTextsSprite;
				fillTextsSprite.cacheAsBitmap = true;
				fill.cacheAsBitmap = true;
				_content.addChildAt(fill, 0);
				
				_renderObjects.push(fill);
			}
		}
		
		public function doAnchorAlign(direction:String):void {
			var textAnchor:String = finalStyle.getPropertyValue("text-anchor") || "start";
			
			var anchorX:Number = getUserUnit(svgX, SVGUtil.WIDTH);
			
			var offsetX:Number = 0;
			
			if(direction == "lr"){
				if(textAnchor == "start")
					offsetX += anchorX  - _start;
				if(textAnchor == "middle")
					offsetX += anchorX  - (_end + _start)/2;
				else if(textAnchor == "end")
					offsetX += anchorX  - _end;
			} else {
				if(textAnchor == "start")
					offsetX += anchorX  - _end;
				if(textAnchor == "middle")
					offsetX += anchorX  - (_end + _start)/2;
				else if(textAnchor == "end")
					offsetX += anchorX  - _start;
			}
			
			offsetRenderObjects(offsetX);
		}
		
		public function offsetRenderObjects(offsetX:Number):void {
			for each(var children:DisplayObject in _renderObjects)
			{
				if(children is SVGTSpan){
					var tspan:SVGTSpan = children as SVGTSpan;
					if(!tspan.svgX)
						tspan.offsetRenderObjects(offsetX);
				} else {
					children.x += offsetX;
				}
			}
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