package com.lorentz.SVG.display {
	import flash.display.Sprite;
	
	import com.lorentz.SVG.SVGUtil;
	
	public class SVGRect extends SVGShape {	
		public function SVGRect(){
			super();
		}
		
		public var svgX:String;
		public var svgY:String;
		public var svgWidth:String;
		public var svgHeight:String;
		public var svgRx:String;
		public var svgRy:String;
		
		public function get isRound():Boolean {
			return (svgRx != null || svgRy != null);
		}
		
		override protected function render():void {
			var _x:Number = getUserUnit(svgX, SVGUtil.WIDTH);
			var _y:Number = getUserUnit(svgY, SVGUtil.HEIGHT);
			var _width:Number = getUserUnit(svgWidth, SVGUtil.WIDTH);
			var _height:Number = getUserUnit(svgHeight, SVGUtil.HEIGHT);

			_content.graphics.clear();
			beginFill();
			lineStyle();
			
			if(isRound) {
				var rx:Number = getUserUnit(svgRx, SVGUtil.WIDTH);
				var ry:Number = getUserUnit(svgRy, SVGUtil.HEIGHT);
				_content.graphics.drawRoundRect(_x, _y, _width, _height, rx, ry);
			} else {
				_content.graphics.drawRect(_x, _y, _width, _height);
			}
			
			_content.graphics.endFill();
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGRect = super.clone(deep) as SVGRect;
			c.svgX = svgX;
			c.svgY = svgY;
			c.svgWidth = svgWidth;
			c.svgHeight = svgHeight;
			c.svgRx = svgRx;
			c.svgRy = svgRy;
			return c;
		}
	}
}