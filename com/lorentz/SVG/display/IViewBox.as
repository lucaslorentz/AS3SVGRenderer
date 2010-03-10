package com.lorentz.SVG.display {
	import flash.geom.Rectangle;
	
	public interface IViewBox {
		function get viewBox():Rectangle;
		function set viewBox(value:Rectangle):void;
	}
}