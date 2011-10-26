package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.SVGElement;
	import com.lorentz.SVG.display.base.SVGTextContainer;
	import com.lorentz.SVG.utils.DisplayUtils;
	import com.lorentz.SVG.utils.SVGUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextAlign;
	
	public class SVGText extends SVGTextContainer {		
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
		
		public function SVGText(){
			super("text");
		}
		
		public var currentX:Number = 0;
		public var currentY:Number = 0;
		public var textFlow:TextFlow;
		public var textContainer:Sprite;
		
		private var _renderObjects:Vector.<DisplayObject>;
		private var _start:Number = 0;
		private var _end:Number = 0;
				
		protected override function render():void {
			super.render();
			
			while(_content.numChildren > 0)
				_content.removeChildAt(0);
			
			if(this.numTextElements == 0)
				return;
						
			textContainer = _content
			
			textFlow = new TextFlow();
			textFlow.textAlign = TextAlign.START;
			
			var direction:String = getDirectionFromStyles() || "lr";
			var textDirection:String = direction;
			
			currentX = getUserUnit(svgX, SVGUtil.WIDTH);
			currentY = getUserUnit(svgY, SVGUtil.HEIGHT);
					
			_start = currentX;
			_renderObjects = new Vector.<DisplayObject>();
			
			var fillTextsSprite:Sprite;
			
			if(hasComplexFill)
			{
				fillTextsSprite = new Sprite();
				textContainer.addChild(fillTextsSprite);
			} else {
				fillTextsSprite = textContainer;
			}
			
			for(var i:int = 0; i < numTextElements; i++){
				var textElement:Object = getTextElementAt(i);
				
				if(textElement is String){
					var createdText:Object = createTextSprite( textElement as String, textFlow );
					
					var textSprite:DisplayObject = createdText.sprite;
					
					if((createdText.direction || direction) == "lr"){
						textSprite.x = currentX;
						textSprite.y = currentY - createdText.ascent;
						currentX += createdText.width;
					} else {
						textSprite.x = currentX - createdText.width;
						textSprite.y = currentY - createdText.ascent;
						currentX -= createdText.width;
					}
								
					if(createdText.direction)	
						textDirection = createdText.direction;
					
					fillTextsSprite.addChild(textSprite);
					_renderObjects.push(textSprite);
				} else if(textElement is SVGTSpan) {
					var tspan:SVGTSpan = textElement as SVGTSpan;
															
					if(tspan.hasOwnFill()) {
						textContainer.addChild(tspan);
					} else
						fillTextsSprite.addChild(tspan);
					
					tspan.invalidateRender();
					tspan.validate();
					
					_renderObjects.push(tspan);
				}
			}
			
			_end = currentX;
			
			doAnchorAlign(textDirection);
			
			textFlow.interactionManager = document.allowTextSelection ? new SelectionManager() : null;
			textFlow.flowComposer.updateAllControllers();

			if(hasComplexFill && fillTextsSprite.numChildren > 0){
				var bounds:Rectangle = DisplayUtils.safeGetBounds(fillTextsSprite, _content);
				bounds.inflate(2, 2);
				var fill:Sprite = new Sprite();
				beginFill(fill.graphics);
				fill.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
				fill.mask = fillTextsSprite;
				fillTextsSprite.cacheAsBitmap = true;
				fill.cacheAsBitmap = true;
				textContainer.addChildAt(fill, 0);
				
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
			var c:SVGText = super.clone(deep) as SVGText;
			c.svgX = svgX;
			c.svgY = svgY;
			
			return c;
		}
	}
}