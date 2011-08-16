package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.ISVGViewPort;
	import com.lorentz.SVG.display.base.SVGContainer;
	
	public class SVG extends SVGContainer implements ISVGViewPort, ISVGViewBox  {
		include "includes/SVGViewBoxProperties.as"
		include "includes/SVGViewPortProperties.as"
		
		public function SVG(){
			super("svg");
		}
	}
}