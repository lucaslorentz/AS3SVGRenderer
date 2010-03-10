package com.lorentz.SVG.display {
	import flash.geom.Rectangle;
	
	public interface IViewPort {
		function get svgX():String;
		function set svgX(value:String):void;
		
		function get svgY():String;
		function set svgY(value:String):void;
		
		function get svgWidth():String;
		function set svgWidth(value:String):void;
		
		function get svgHeight():String;
		function set svgHeight(value:String):void;
		
		function get svgPreserveAspectRatio():String;
		function set svgPreserveAspectRatio(value:String):void;
	}
}