package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.SVGTextContainer;
	import com.lorentz.SVG.svg_internal;
	import com.lorentz.SVG.utils.DisplayUtils;
	import com.lorentz.SVG.utils.SVGUtil;
	
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
				invalidateTextOwner();
			}
		}
		
		private var _svgY:String;
		public function get svgY():String {
			return _svgY;
		}
		public function set svgY(value:String):void {
			if(_svgY != value){
				_svgY = value;
				invalidateTextOwner();
			}
		}
		
		private var _svgDx:String;
		public function get svgDx():String {
			return _svgDx;
		}
		public function set svgDx(value:String):void {
			if(_svgDx != value){
				_svgDx = value;
				invalidateTextOwner();
			}
		}
		
		private var _svgDy:String;
		public function get svgDy():String {
			return _svgDy;
		}
		public function set svgDy(value:String):void {
			if(_svgDy != value){
				_svgDy = value;
				invalidateTextOwner();
			}
		}

		public function SVGTSpan(){
			super("tspan");
		}

		public function hasOwnFill():Boolean {
			return _styles["fill"] != null && _styles["fill"] != "" && _styles["fill"] != "none";
		}
		
		override protected function render():void {
			while(this.numChildren > 0)
				this.removeChildAt(0);
			
			if(textOwner.textFlow == null)
				return;
			
			if(svgX)
				textOwner.currentX = getUserUnit(svgX, SVGUtil.WIDTH);
			if(svgY)
				textOwner.currentY = getUserUnit(svgY, SVGUtil.HEIGHT);
			
			if(svgDx)
				textOwner.currentX += getUserUnit(svgDx, SVGUtil.WIDTH);
			if(svgDy)
				textOwner.currentY += getUserUnit(svgDy, SVGUtil.HEIGHT);
			
			var maskSprite:Sprite = new Sprite();
			this.addChild(maskSprite);
			
			var noMaskSprite:Sprite = new Sprite();
			this.addChild(noMaskSprite);
			
			for(var i:int = 0; i < this.numTextElements; i++){
				var textElement:Object = this.getTextElementAt(i);
				if(textElement is String){
					var createdText:Object = createTextSprite( textElement as String, textOwner.textFlow );
					
					var fillTextField:Sprite = createdText.sprite;
					fillTextField.x = textOwner.currentX;
					fillTextField.y = textOwner.currentY - createdText.height;
					
					maskSprite.addChild(fillTextField);
					
					textOwner.currentX += createdText.xOffset;
				} else {
					var tspan:SVGTSpan = textElement as SVGTSpan;
					
					tspan.validate();
					
					if(tspan.hasOwnFill())
						noMaskSprite.addChild(tspan);
					else
						maskSprite.addChild(tspan);
				}				
			}
			
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
			var c:SVGTSpan = super.clone(deep) as SVGTSpan;
			c.svgX = svgX;
			c.svgY = svgY;
			c.svgDx = svgDx;
			c.svgDy = svgDy;
			return c;
		}
	}
}