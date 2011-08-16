package com.lorentz.SVG.display.base {
	import flash.geom.Rectangle;
	
	public interface ISVGViewPort extends ISVGPreserveAspectRatio {
		function get svgX():String;
		function set svgX(value:String):void;
		
		function get svgY():String;
		function set svgY(value:String):void;
		
		function get svgWidth():String;
		function set svgWidth(value:String):void;
		
		function get svgHeight():String;
		function set svgHeight(value:String):void;
		
		function get svgOverflow():String;
		function set svgOverflow(value:String):void;
		
		function get viewPortWidth():Number;
		function get viewPortHeight():Number;
	}
}