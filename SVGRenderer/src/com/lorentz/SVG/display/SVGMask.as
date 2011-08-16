package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.SVGContainer;
	
	public class SVGMask extends SVGContainer implements ISVGViewBox {
		include "includes/SVGViewBoxProperties.as"
		
		public function SVGMask(){
			super("mask");
		}
	}
}