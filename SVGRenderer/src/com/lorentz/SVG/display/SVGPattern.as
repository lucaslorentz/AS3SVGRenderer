package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.SVGContainer;
	import com.lorentz.SVG.display.base.SVGElement;
	import com.lorentz.SVG.parser.SVGParserCommon;
	import com.lorentz.SVG.utils.StringUtil;
	import com.lorentz.SVG.utils.SVGUtil;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
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
			content.transform.matrix = new Matrix();
			
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
			
			var x:Number = 0;
			if(finalSvgX)
				x = getViewPortUserUnit(finalSvgX, SVGUtil.WIDTH);
			
			var y:Number = 0;
			if(finalSvgY)
				y = getViewPortUserUnit(finalSvgY, SVGUtil.HEIGHT);
			
			var w:Number = 0;
			if(finalSvgWidth)
				w = getViewPortUserUnit(finalSvgWidth, SVGUtil.WIDTH);
			
			var h:Number = 0;
			if(finalSvgHeight)
				h = getViewPortUserUnit(finalSvgHeight, SVGUtil.HEIGHT);
			
			var patternMat:Matrix = new Matrix();
			patternMat.translate(x, y);
			if (finalPatternTransform)
				patternMat.concat(SVGParserCommon.parseTransformation(finalPatternTransform));
			
			var patScaleX:Number = Math.sqrt(patternMat.a * patternMat.a + patternMat.c * patternMat.c);
			var patScaleY:Number = Math.sqrt(patternMat.b * patternMat.b + patternMat.d * patternMat.d);
			var patScale:Number = Math.max(patScaleX, patScaleY);
			
			var bitmapW:int = Math.round(w * patScale);
			var bitmapH:int = Math.round(h * patScale);
			
			if (bitmapW == 0 || bitmapH == 0)
				return;
			
			var bd:BitmapData = new BitmapData(bitmapW, bitmapH, true, 0);
			
			var drawMatrix:Matrix = new Matrix();
			drawMatrix.scale(patScale, patScale);
			
			bd.draw(content, drawMatrix, null, null, null, true);

			drawMatrix.invert();
			drawMatrix.concat(patternMat);
			
			graphics.beginBitmapFill(bd, drawMatrix, true, true);
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