package com.lorentz.SVG.display {
	import flash.display.Sprite;
	
	import com.lorentz.SVG.SVGUtil;
	
	public class SVGLine extends SVGShape {	
		public function SVGLine(){
			super();
		}
		
		public var svgX1:String;
		public var svgX2:String;
		public var svgY1:String;
		public var svgY2:String;
		
		override protected function render():void {		
			var x1:Number = getUserUnit(svgX1, SVGUtil.WIDTH);
			var y1:Number = getUserUnit(svgY1, SVGUtil.HEIGHT);
			var x2:Number = getUserUnit(svgX2, SVGUtil.WIDTH);
			var y2:Number = getUserUnit(svgY2, SVGUtil.HEIGHT);
			
			_content.graphics.clear();
			lineStyle();
			_content.graphics.moveTo(x1, y1);
			_content.graphics.lineTo(x2, y2);
			_content.graphics.lineStyle();
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGLine = super.clone(deep) as SVGLine;
			c.svgX1 = svgX1;
			c.svgX2 = svgX2;
			c.svgY1 = svgY1;
			c.svgY2 = svgY2;
			return c;
		}
	}
}