package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.SVGTextContainer;
	import com.lorentz.SVG.utils.DisplayUtils;
	import com.lorentz.SVG.utils.SVGUtil;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextAlign;
	import com.lorentz.SVG.display.base.SVGElement;
	
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
		
		protected override function render():void {
			super.render();
			
			while(_content.numChildren > 0)
				_content.removeChildAt(0);
			
			if(this.numTextElements == 0)
				return;
			
			textFlow = new TextFlow();
			textFlow.textAlign = TextAlign.LEFT;

			var textAnchor:String = _finalStyles["text-anchor"];
			
			var startTx:Number = getUserUnit(svgX, SVGUtil.WIDTH);
			var startTy:Number = getUserUnit(svgY, SVGUtil.HEIGHT);
			
			currentX = startTx;
			currentY = startTy;
			
			var maskSprite:Sprite = new Sprite();
			this.addChild(maskSprite);
			
			var noMaskSprite:Sprite = new Sprite();
			this.addChild(noMaskSprite);
			
			for(var i:int = 0; i < this.numTextElements; i++){
				var textElement:Object = this.getTextElementAt(i);
				
				if(textElement is String){
					var createdText:Object = createTextSprite( textElement as String, textFlow );
					
					var fillTextField:Sprite = createdText.sprite;
					fillTextField.x = currentX;
					fillTextField.y = currentY - createdText.height;
					
					maskSprite.addChild(fillTextField);
					
					currentX += createdText.xOffset;
				} else {
					var tspan:SVGTSpan = textElement as SVGTSpan;
					
					tspan.invalidateRender();
					tspan.validate();
										
					if(tspan.hasOwnFill())
						noMaskSprite.addChild(tspan);
					else
						maskSprite.addChild(tspan);
				}				
			}
			
			textFlow.interactionManager = document.allowTextSelection ? new SelectionManager() : null;
			textFlow.flowComposer.updateAllControllers();

			if(textAnchor == "middle")
				noMaskSprite.x = maskSprite.x -= (currentX - startTx)/2;
			else if(textAnchor == "end")
				noMaskSprite.x = maskSprite.x -= (currentX - startTx);

			var bounds:Rectangle = DisplayUtils.safeGetBounds(maskSprite, this);
			var fillRect:Sprite = new Sprite();
			beginFill(fillRect.graphics);
			fillRect.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
			fillRect.mask = maskSprite;
			maskSprite.cacheAsBitmap = true;
			fillRect.cacheAsBitmap = true;
			this.addChildAt(fillRect, 0);
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGText = super.clone(deep) as SVGText;
			c.svgX = svgX;
			c.svgY = svgY;
			
			return c;
		}
	}
}