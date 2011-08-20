package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.SVGShape;
	import com.lorentz.SVG.drawing.IDrawer;
	import com.lorentz.SVG.utils.SVGUtil;
	
	import flash.display.Graphics;
	import com.lorentz.SVG.display.base.SVGElement;
	
	public class SVGLine extends SVGShape {	
		public function SVGLine(){
			super("line");
		}
		
		private var _svgX1:String;
		public function get svgX1():String {
			return _svgX1;
		}
		public function set svgX1(value:String):void {
			if(_svgX1 != value){
				_svgX1 = value;
				invalidateRender();
			}
		}

		private var _svgX2:String;
		public function get svgX2():String {
			return _svgX2;
		}
		public function set svgX2(value:String):void {
			if(_svgX2 != value){
				_svgX2 = value;
				invalidateRender();
			}
		}

		private var _svgY1:String;
		public function get svgY1():String {
			return _svgY1;
		}

		public function set svgY1(value:String):void {
			if(_svgY1 != value){
				_svgY1 = value;
				invalidateRender();
			}
		}

		private var _svgY2:String;
		public function get svgY2():String {
			return _svgY2;
		}

		public function set svgY2(value:String):void {
			if(_svgY2 != value){
				_svgY2 = value;
				invalidateRender();
			}
		}
		
		override protected function get hasFill():Boolean {
			return false;
		}

		private var _x1Units:Number;
		private var _y1Units:Number;
		private var _x2Units:Number;
		private var _y2Units:Number;
		
		override protected function render():void {
			_x1Units = getUserUnit(svgX1, SVGUtil.WIDTH);
			_y1Units = getUserUnit(svgY1, SVGUtil.HEIGHT);
			_x2Units = getUserUnit(svgX2, SVGUtil.WIDTH);
			_y2Units = getUserUnit(svgY2, SVGUtil.HEIGHT);
			
			super.render();
		}
		
		override protected function draw(drawer:IDrawer):void {			
			drawer.moveTo(_x1Units, _y1Units);
			drawer.lineTo(_x2Units, _y2Units);
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGLine = super.clone(deep) as SVGLine;
			c.svgX1 = svgX1;
			c.svgX2 = svgX2;
			c.svgY1 = svgY1;
			c.svgY2 = svgY2;
			return c;
		}
	}
}