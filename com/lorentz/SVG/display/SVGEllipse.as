package com.lorentz.SVG.display {
	import flash.display.Sprite;
	
	import com.lorentz.SVG.SVGUtil;
	
	public class SVGEllipse extends SVGShape {	
		public function SVGEllipse(){
			super();
		}
		
		public var svgCx:String;
		public var svgCy:String;
		public var svgRx:String;
		public var svgRy:String;
		
		override protected function render():void {		
			var cx:Number = getUserUnit(svgCx, SVGUtil.WIDTH);
			var cy:Number = getUserUnit(svgCy, SVGUtil.HEIGHT);
			var rx:Number = getUserUnit(svgRx, SVGUtil.WIDTH);
			var ry:Number = getUserUnit(svgRy, SVGUtil.HEIGHT);
			
			_content.graphics.clear();
			beginFill();
			lineStyle();
			_content.graphics.drawEllipse(cx-rx, cy-ry, rx*2, ry*2);
			_content.graphics.endFill();
			_content.graphics.lineStyle();
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGEllipse = super.clone(deep) as SVGEllipse;
			c.svgCx = svgCx;
			c.svgCy = svgCy;
			c.svgRx = svgRx;
			c.svgRy = svgRy;
			return c;
		}
	}
}