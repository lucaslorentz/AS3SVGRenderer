package com.lorentz.SVG.display {
	import flash.display.Sprite;
	
	import com.lorentz.SVG.SVGUtil;
	
	public class SVGCircle extends SVGShape {	
		public function SVGCircle(){
			super();
		}
		
		public var svgCx:String;
		public var svgCy:String;
		public var svgR:String;
		
		override protected function render():void {		
			var cx:Number = getUserUnit(svgCx, SVGUtil.WIDTH);
			var cy:Number = getUserUnit(svgCy, SVGUtil.HEIGHT);
			var r:Number = getUserUnit(svgR, SVGUtil.WIDTH); //Its based on width?
			
			_content.graphics.clear();
			beginFill();
			lineStyle();
			_content.graphics.drawCircle(cx, cy, r);
			_content.graphics.endFill();
			_content.graphics.lineStyle();
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGCircle = super.clone(deep) as SVGCircle;
			c.svgCx = svgCx;
			c.svgCy = svgCy;
			c.svgR = svgR;
			return c;
		}
	}
}