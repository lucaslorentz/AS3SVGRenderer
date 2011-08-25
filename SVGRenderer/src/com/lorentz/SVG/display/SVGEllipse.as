package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.SVGShape;
	import com.lorentz.SVG.drawing.IDrawer;
	import com.lorentz.SVG.utils.SVGUtil;
	
	import flash.display.Graphics;
	import com.lorentz.SVG.display.base.SVGElement;
	
	public class SVGEllipse extends SVGShape {	
		public function SVGEllipse(){
			super("ellipse");
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
		
		private var _svgRx:String;
		public function get svgRx():String {
			return _svgRx;
		}
		public function set svgRx(value:String):void {
			_svgRx = value;
			invalidateRender();
		}
		
		private var _svgRy:String;
		public function get svgRy():String {
			return _svgRy;
		}
		public function set svgRy(value:String):void {
			_svgRy = value;
			invalidateRender();
		}
		
		private var _cxUnits:Number;
		private var _cyUnits:Number;
		private var _rxUnits:Number;
		private var _ryUnits:Number;
		
		override protected function render():void {
			_cxUnits = getUserUnit(svgCx, SVGUtil.WIDTH);
			_cyUnits = getUserUnit(svgCy, SVGUtil.HEIGHT);
			_rxUnits = getUserUnit(svgRx, SVGUtil.WIDTH);
			_ryUnits = getUserUnit(svgRy, SVGUtil.HEIGHT);
			
			super.render();
		}
		
		override protected function draw(drawer:IDrawer):void {
			drawer.moveTo(_cxUnits + _rxUnits, _cyUnits);
			drawer.arcTo(_rxUnits, _ryUnits, 0, true, false, _cxUnits - _rxUnits, _cyUnits);
			drawer.arcTo(_rxUnits, _ryUnits, 0, true, false, _cxUnits + _rxUnits, _cyUnits);
		}
		
		override protected function drawToGraphics(graphics:Graphics):void {
			graphics.drawEllipse(_cxUnits-_rxUnits, _cyUnits-_ryUnits, _rxUnits*2, _ryUnits*2);
		}
		
		override protected function get hasDrawToGraphics():Boolean {
			return true;
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGEllipse = super.clone(deep) as SVGEllipse;
			c.svgCx = svgCx;
			c.svgCy = svgCy;
			c.svgRx = svgRx;
			c.svgRy = svgRy;
			return c;
		}
	}
}