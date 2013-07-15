package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.SVGContainer;
	import com.lorentz.SVG.display.base.SVGElement;
	import com.lorentz.SVG.parser.SVGParserCommon;
	import com.lorentz.SVG.utils.StringUtil;
	import com.lorentz.SVG.utils.SVGUtil;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
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
			
		public function beginFill(graphics:Graphics):void {			
			content.scaleX = content.scaleY = 1;
			
			var finalSvgX:String = svgX;
			var finalSvgY:String = svgY;
			var finalSvgWidth:String = svgWidth;
			var finalSvgHeight:String = svgHeight;
			var finalPatternTransform:String = patternTransform;
			
			if (originalPatternHref)
			{
				var originalPattern:SVGPattern = this;
				
				while (originalPattern.originalPatternHref)
				{
					originalPattern = document.getDefinition(StringUtil.ltrim(originalPattern.originalPatternHref, "#")) as SVGPattern;
					
					if (!originalPattern)
						break;
					
					if (!finalSvgX) finalSvgX = originalPattern.svgX;
					if (!finalSvgY) finalSvgY = originalPattern.svgY;
					if (!finalSvgWidth) finalSvgWidth = originalPattern.svgWidth;
					if (!finalSvgHeight) finalSvgHeight = originalPattern.svgHeight;
					if (!finalPatternTransform) finalPatternTransform = originalPattern.patternTransform;
				}
				
			}
			
			var _x:Number = 0;
			if(finalSvgX)
				_x = getViewPortUserUnit(finalSvgX, SVGUtil.WIDTH);
			
			var _y:Number = 0;
			if(finalSvgY)
				_y = getViewPortUserUnit(finalSvgY, SVGUtil.HEIGHT);
			
			var w:Number = 0;
			if(finalSvgWidth)
				w = getViewPortUserUnit(finalSvgWidth, SVGUtil.WIDTH);
			
			var h:Number = 0;
			if(finalSvgHeight)
				h = getViewPortUserUnit(finalSvgHeight, SVGUtil.HEIGHT);
			
			if (content.width > 0 && content.height > 0)
			{
				content.scaleX = w / content.width;
				content.scaleY = h / content.height;
			}
			
			if(w == 0 || h == 0)
				return;
				
			var rc:Rectangle = content.getBounds(content);
			content.x = -rc.x;
			content.y = -rc.y;
				
			var transformMatrix:Matrix = null;
			if (finalPatternTransform)
				transformMatrix = SVGParserCommon.parseTransformation(finalPatternTransform);

			var bd:BitmapData = new BitmapData(w, h, true, 0);
			bd.draw(this, null, null, null, null, true);
			
			graphics.beginBitmapFill(bd, transformMatrix, true, true);
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