package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.SVGContainer;
	import com.lorentz.SVG.display.base.SVGElement;
	import com.lorentz.SVG.parser.SVGParserCommon;
	import com.lorentz.SVG.utils.StringUtil;
	import com.lorentz.SVG.utils.SVGUtil;
	import flash.display.Graphics;
	import flash.display.Sprite;
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
			
			var spriteToRender:Sprite = new Sprite;
			var contentParent:Sprite = new Sprite;
			spriteToRender.addChild(contentParent);
			contentParent.addChild(content);
			
			contentParent.scaleX = contentParent.scaleY = patScale;
			
			var bounds:Rectangle = content.getBounds(content);
			var x0:Number = Math.floor(bounds.left / w) * w;
			var x1:Number = Math.floor(bounds.right / w) * w;
			var y0:Number = Math.floor(bounds.top / h) * h;
			var y1:Number = Math.floor(bounds.bottom / h) * h;

			for (var drawY:Number = -y1; drawY <= -y0; drawY += h)
				for (var drawX:Number = -x1; drawX <= -x0; drawX += w)
				{
					content.x = drawX;
					content.y = drawY;
					bd.draw(spriteToRender, null, null, null, null, true);
				}

			var mat:Matrix = contentParent.transform.matrix.clone();
			mat.invert();
			mat.concat(patternMat);
			
			graphics.beginBitmapFill(bd, mat, true, true);
			
			content.transform.matrix = new Matrix();
			addChild(content);
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