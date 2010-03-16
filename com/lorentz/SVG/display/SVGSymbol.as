package com.lorentz.SVG.display {
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import com.lorentz.SVG.SVGUtil;
	
	public class SVGSymbol extends SVGG implements IViewBox {	
		include "includes/ViewBoxProperties.as"
		
		protected var _svgPreserveAspectRatio:String;
		public function get svgPreserveAspectRatio():String {
			return _svgPreserveAspectRatio;
		}
		public function set svgPreserveAspectRatio(value:String):void {
			_svgPreserveAspectRatio = value;
		}
		
		public function SVGSymbol(){
			super();
		}
	}
}