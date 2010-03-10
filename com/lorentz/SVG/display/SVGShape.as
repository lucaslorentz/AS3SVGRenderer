package com.lorentz.SVG.display {
	import flash.display.Sprite;
	
	import com.lorentz.SVG.SVGUtil;
	
	public class SVGShape extends SVGElement {	
		public function SVGShape(){
			super();
			mouseChildren = false;
			_validateFunctions.push(render);
		}

		protected function render():void {
		}
	}
}