package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.SVGShape;
	import com.lorentz.SVG.drawing.IDrawer;
	import com.lorentz.SVG.display.base.SVGElement;
	
	public class SVGPolyline extends SVGShape {	
		public function SVGPolyline(){
			super("polyline");
		}
		
		private var _points:Vector.<String>;
		public function get points():Vector.<String> {
			return _points;
		}
		public function set points(value:Vector.<String>):void {
			_points = value;
			invalidateRender();
		}
		
		override protected function get hasFill():Boolean {
			return false;
		}
				
		override protected function draw(drawer:IDrawer):void {
			if(points.length>2){
				drawer.moveTo(Number(points[0]), Number(points[1]));
				
				var i:int = 2;
				while(i < points.length - 1)
					drawer.lineTo(Number(points[i++]), Number(points[i++]));
			}
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGPolyline = super.clone(deep) as SVGPolyline;
			c.points = points.slice();
			return c;
		}
	}
}