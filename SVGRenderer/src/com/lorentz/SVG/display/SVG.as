package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.ISVGViewPort;
	import com.lorentz.SVG.display.base.SVGContainer;
	
	import flash.geom.Rectangle;
	
	public class SVG extends SVGContainer implements ISVGViewPort, ISVGViewBox  {
		public function SVG(){
			super("svg");
		}
		
		public function get svgViewBox():Rectangle {
			return getAttribute("viewBox") as Rectangle;
		}
		public function set svgViewBox(value:Rectangle):void {
			setAttribute("viewBox", value);
		}
		
		public function get svgPreserveAspectRatio():String {
			return getAttribute("preserveAspectRatio") as String;
		}
		public function set svgPreserveAspectRatio(value:String):void {
			setAttribute("preserveAspectRatio", value);
		}
				
		public function get svgX():String {
			return getAttribute("x") as String;
		}
		public function set svgX(value:String):void {
			setAttribute("x", value);
		}
		
		public function get svgY():String {
			return getAttribute("y") as String;
		}
		public function set svgY(value:String):void {
			setAttribute("y", value);
		}
		
		public function get svgWidth():String {
			return getAttribute("width") as String;
		}
		public function set svgWidth(value:String):void {
			setAttribute("width", value);
		}
		
		public function get svgHeight():String {
			return getAttribute("height") as String;
		}
		public function set svgHeight(value:String):void {
			setAttribute("height", value);
		}
		
		public function get svgOverflow():String {
			return getAttribute("overflow") as String;
		}
		public function set svgOverflow(value:String):void {
			setAttribute("overflow", value);
		}
	}
}