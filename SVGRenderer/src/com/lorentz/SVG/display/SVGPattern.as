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
		private var _finalSvgX:String;
		private var _finalSvgY:String;
		private var _finalSvgWidth:String;
		private var _finalSvgHeight:String;
		private var _finalPatternTransform:String;
		private var _svgHrefChanged:Boolean = false;
		private var _svgHref:String;
		private var _patternWithChildren:SVGPattern;
		
		public function get svgHref():String {
			return _svgHref;
		}
		public function set svgHref(value:String):void {			
			_svgHref = value;
			_svgHrefChanged = true;
			invalidateProperties();
		}
		
		public function SVGPattern(){
			super("pattern");
		}
		
		public function get svgX():String {
			return getAttribute("x") as String;
		}
		public function set svgX(value:String):void {
			setAttribute("x", value);
			invalidateProperties();
		}
		
		public function get svgY():String {
			return getAttribute("y") as String;
		}
		public function set svgY(value:String):void {
			setAttribute("y", value);
			invalidateProperties();
		}
		
		public function get svgWidth():String {
			return getAttribute("width") as String;
		}
		public function set svgWidth(value:String):void {
			setAttribute("width", value);
			invalidateProperties();
		}
		
		public function get svgHeight():String {
			return getAttribute("height") as String;
		}
		public function set svgHeight(value:String):void {
			setAttribute("height", value);
			invalidateProperties();
		}

		public function get patternTransform():String {
			return getAttribute("patternTransform") as String;
		}
		public function set patternTransform(value:String):void {
			setAttribute("patternTransform", value);
			invalidateProperties();
		}
		
		public function get svgViewBox():Rectangle {
			return getAttribute("viewBox") as Rectangle;
		}
		public function set svgViewBox(value:Rectangle):void {
			setAttribute("viewBox", value);
			invalidateProperties();
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if (_patternWithChildren && _patternWithChildren != this)
			{
				detachElement(_patternWithChildren);
				_patternWithChildren = null;
			}
			
			_finalSvgX = svgX;
			_finalSvgY = svgY;
			_finalSvgWidth = svgWidth;
			_finalSvgHeight = svgHeight;
			_finalPatternTransform = patternTransform;
			_patternWithChildren = this;
			
			if (svgHref)
			{
				var refPattern:SVGPattern = this;
				
				while (refPattern.svgHref)
				{
					refPattern = document.getDefinition(StringUtil.ltrim(refPattern.svgHref, "#")) as SVGPattern;
					
					if (!refPattern)
						break;
					
					if (_patternWithChildren.numElements == 0)
						_patternWithChildren = refPattern;
					if (!_finalSvgX) _finalSvgX = refPattern.svgX;
					if (!_finalSvgY) _finalSvgY = refPattern.svgY;
					if (!_finalSvgWidth) _finalSvgWidth = refPattern.svgWidth;
					if (!_finalSvgHeight) _finalSvgHeight = refPattern.svgHeight;
					if (!_finalPatternTransform) _finalPatternTransform = refPattern.patternTransform;
				}
			}
			
			if (_patternWithChildren && _patternWithChildren != this)
			{
				_patternWithChildren = _patternWithChildren.clone() as SVGPattern;
				attachElement(_patternWithChildren);
			}
		}
		
		public function beginFill(graphics:Graphics):void {			
			var x:Number = 0;
			if(_finalSvgX)
				x = getViewPortUserUnit(_finalSvgX, SVGUtil.WIDTH);
			
			var y:Number = 0;
			if(_finalSvgY)
				y = getViewPortUserUnit(_finalSvgY, SVGUtil.HEIGHT);
			
			var w:Number = 0;
			if(_finalSvgWidth)
				w = getViewPortUserUnit(_finalSvgWidth, SVGUtil.WIDTH);
			
			var h:Number = 0;
			if(_finalSvgHeight)
				h = getViewPortUserUnit(_finalSvgHeight, SVGUtil.HEIGHT);
			
			var patternMat:Matrix = new Matrix();
			patternMat.translate(x, y);
			if (_finalPatternTransform)
				patternMat.concat(SVGParserCommon.parseTransformation(_finalPatternTransform));
			
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
			var content:Sprite = _patternWithChildren.content;

			spriteToRender.addChild(contentParent);
			contentParent.addChild(content);
			
			content.transform.matrix = new Matrix();
			
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
			
			_patternWithChildren.addChild(content);
		}
		
		override public function clone():Object {
			var c:SVGPattern = super.clone() as SVGPattern;
			c.svgX = svgX;
			c.svgY = svgY;
			c.svgWidth = svgWidth;
			c.svgHeight = svgHeight;
			c.patternTransform = patternTransform;
			c.svgHref = svgHref;
			return c;
		}
	}
}