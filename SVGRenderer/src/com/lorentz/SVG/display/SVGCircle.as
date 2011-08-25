package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.SVGShape;
	import com.lorentz.SVG.drawing.IDrawer;
	import com.lorentz.SVG.utils.SVGUtil;
	
	import flash.display.Graphics;
	import com.lorentz.SVG.display.base.SVGElement;
	
	public class SVGCircle extends SVGShape {	
		public function SVGCircle(){
			super("circle");
		}
		
		private var _svgCx:String;
		public function get svgCx():String {
			return _svgCx;
		}
		public function set svgCx(value:String):void {
			if(_svgCx != value){
				_svgCx = value;
				invalidateRender();
			}
		}
		
		private var _svgCy:String;
		public function get svgCy():String {
			return _svgCy;
		}
		public function set svgCy(value:String):void {
			if(_svgCy != value){
				_svgCy = value;
				invalidateRender();
			}
		}
		
		private var _svgR:String;
		public function get svgR():String {
			return _svgR;
		}
		public function set svgR(value:String):void {
			_svgR = value;
			invalidateRender();
		}
		
		private var _cxUnits:Number;
		private var _cyUnits:Number;
		private var _rUnits:Number;
		
		override protected function render():void {
			_cxUnits = getUserUnit(svgCx, SVGUtil.WIDTH);
			_cyUnits = getUserUnit(svgCy, SVGUtil.HEIGHT);
			_rUnits = getUserUnit(svgR, SVGUtil.WIDTH); //Its based on width?
			
			super.render();
		}
		
		override protected function draw(drawer:IDrawer):void {
			drawer.moveTo(_cxUnits + _rUnits, _cyUnits);
			drawer.arcTo(_rUnits, _rUnits, 0, true, false, _cxUnits - _rUnits, _cyUnits);
			drawer.arcTo(_rUnits, _rUnits, 0, true, false, _cxUnits + _rUnits, _cyUnits);
		}
		
		override protected function drawToGraphics(graphics:Graphics):void {
			graphics.drawCircle(_cxUnits, _cyUnits, _rUnits);
		}
		
		override protected function get hasDrawToGraphics():Boolean {
			return true;
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGCircle = super.clone(deep) as SVGCircle;
			c.svgCx = svgCx;
			c.svgCy = svgCy;
			c.svgR = svgR;
			return c;
		}
	}
}