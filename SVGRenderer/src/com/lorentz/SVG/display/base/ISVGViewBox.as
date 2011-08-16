package com.lorentz.SVG.display.base {
	import flash.geom.Rectangle;
	
	public interface ISVGViewBox {
		function get svgViewBox():Rectangle;
		function set svgViewBox(value:Rectangle):void;
	}
}