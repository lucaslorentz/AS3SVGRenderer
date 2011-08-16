package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.SVGContainer;
	import com.lorentz.SVG.utils.SVGUtil;
	
	import flash.display.BitmapData;
	
	public class SVGPattern extends SVGContainer implements ISVGViewBox {
		include "includes/SVGViewBoxProperties.as"
		
		public var svgX:String;
		public var svgY:String;
		public var svgWidth:String;
		public var svgHeight:String;
		
		public function SVGPattern(){
			super("pattern");
		}
			
		public function getBitmap():BitmapData {
			validate();
			
			_content.scaleX = _content.scaleY = 1;
			
			var _x:Number = getUserUnit(svgX, SVGUtil.WIDTH);
			var _y:Number = getUserUnit(svgY, SVGUtil.HEIGHT);
			
			var w:Number = getUserUnit(svgWidth, SVGUtil.WIDTH);
			var h:Number = getUserUnit(svgHeight, SVGUtil.HEIGHT);
			
			_content.scaleX = w/_content.width;
			_content.scaleY = h/_content.height;
				
			var bd:BitmapData = new BitmapData(w, h);
			bd.draw(this, null, null, null, null, true);
			return bd;
		}
	}
}