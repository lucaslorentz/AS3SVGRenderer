package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.ISVGPreserveAspectRatio;
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.SVGContainer;
	
	public class SVGSymbol extends SVGContainer implements ISVGViewBox, ISVGPreserveAspectRatio {	
		include "includes/SVGPreserveAspectRatio.as"
		include "includes/SVGViewBoxProperties.as"
		
		public function SVGSymbol(){
			super("symbol");
		}
	}
}