package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.SVGContainer;
	import com.lorentz.SVG.display.base.SVGElement;
	import com.lorentz.SVG.utils.StringUtil;
	import com.lorentz.SVG.utils.SVGUtil;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	public class SVGPattern extends SVGContainer implements ISVGViewBox {		
		public var svgX:String;
		public var svgY:String;
		public var svgWidth:String;
		public var svgHeight:String;
		public var patternTransform:String;
		
		public var originalPatternHref:String;
		
		public function SVGPattern(){
			super("pattern");
		}
		
		public function get svgViewBox():Rectangle {
			return getAttribute("viewBox") as Rectangle;
		}
		public function set svgViewBox(value:Rectangle):void {
			setAttribute("viewBox", value);
		}
			
		public function getBitmap():BitmapData {			
			content.scaleX = content.scaleY = 1;
			
			
			if (originalPatternHref)
			{
				var originalPattern:SVGPattern = this;
				
				while (originalPattern.originalPatternHref)
					originalPattern = document.getDefinition(StringUtil.ltrim(originalPattern.originalPatternHref, "#")) as SVGPattern;
				
				if (originalPattern)
				{
					svgX = originalPattern.svgX;
					svgY = originalPattern.svgY;
					svgWidth = originalPattern.svgWidth;
					svgHeight = originalPattern.svgHeight;
				}
			}
			
			var _x:Number = 0;
			if(svgX)
				_x = getViewPortUserUnit(svgX, SVGUtil.WIDTH);
			
			var _y:Number = 0;
			if(svgY)
				_y = getViewPortUserUnit(svgY, SVGUtil.HEIGHT);
			
			var w:Number = 0;
			if(svgWidth)
				w = getViewPortUserUnit(svgWidth, SVGUtil.WIDTH);
			
			var h:Number = 0;
			if(svgHeight)
				h = getViewPortUserUnit(svgHeight, SVGUtil.HEIGHT);
			
			content.scaleX = w / content.width;
			content.scaleY = h / content.height;
			
			if(w == 0 || h == 0)
				return null;
				
			var bd:BitmapData = new BitmapData(w, h, true, 0);
			bd.draw(this, null, null, null, null, true);
			return bd;
		}
		
		override public function clone():Object {
			var c:SVGPattern = super.clone() as SVGPattern;
			c.svgX = svgX;
			c.svgY = svgY;
			c.svgWidth = svgWidth;
			c.svgHeight = svgHeight;
			c.patternTransform = patternTransform;
			c.originalPatternHref = originalPatternHref;
			return c;
		}
	}
}