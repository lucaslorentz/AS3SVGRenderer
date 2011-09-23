package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.SVGElement;
	import com.lorentz.SVG.display.base.SVGTextContainer;
	import com.lorentz.SVG.utils.DisplayUtils;
	import com.lorentz.SVG.utils.SVGUtil;
	
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
		
		protected override function render():void {
			super.render();
			
			while(_content.numChildren > 0)
				_content.removeChildAt(0);
			
			if(this.numTextElements == 0)
				return;
						
			textContainer = new Sprite();
			_content.addChild(textContainer);
			
			textFlow = new TextFlow();
			textFlow.textAlign = TextAlign.LEFT;

			var textAnchor:String = finalStyle.getPropertyValue("text-anchor");
			
			var startTx:Number = getUserUnit(svgX, SVGUtil.WIDTH);
			var startTy:Number = getUserUnit(svgY, SVGUtil.HEIGHT);
			
			currentX = startTx;
			currentY = startTy;
						
			var fillMask:Sprite = new Sprite();
			textContainer.addChild(fillMask);
			
			for(var i:int = 0; i < this.numTextElements; i++){
				var textElement:Object = this.getTextElementAt(i);
				
				if(textElement is String){
					var createdText:Object = createTextSprite( textElement as String, textFlow );
					
					var textSprite:Sprite = createdText.sprite;
					textSprite.x = currentX;
					textSprite.y = currentY - createdText.height;
					
					fillMask.addChild(textSprite);
					
					currentX += createdText.xOffset;
				} else if(textElement is SVGTSpan) {
					var tspan:SVGTSpan = textElement as SVGTSpan;
															
					if(tspan.hasOwnFill())
						textContainer.addChild(tspan);
					else
						fillMask.addChild(tspan);
					
					tspan.invalidateRender();
					tspan.validate();
				}				
			}
			
			textFlow.interactionManager = document.allowTextSelection ? new SelectionManager() : null;
			textFlow.flowComposer.updateAllControllers();

			if(textAnchor == "middle")
				textContainer.x -= (currentX - startTx)/2;
			else if(textAnchor == "end")
				textContainer.x -= (currentX - startTx);

			var bounds:Rectangle = DisplayUtils.safeGetBounds(fillMask, textContainer);
			var fill:Sprite = new Sprite();
			beginFill(fill.graphics);
			fill.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
			fill.mask = fillMask;
			fillMask.cacheAsBitmap = true;
			fill.cacheAsBitmap = true;
			textContainer.addChildAt(fill, 0);
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGText = super.clone(deep) as SVGText;
			c.svgX = svgX;
			c.svgY = svgY;
			
			return c;
		}
	}
}