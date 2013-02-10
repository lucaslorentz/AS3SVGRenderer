package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.SVGShape;
	import com.lorentz.SVG.drawing.IDrawer;
	import com.lorentz.SVG.utils.SVGUtil;
	
	import flash.display.Graphics;
	import com.lorentz.SVG.display.base.SVGElement;
	
	public class SVGCircle extends SVGShape {
		private var _cxUnits:Number;
		private var _cyUnits:Number;
		private var _rUnits:Number;
		
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
		
		override protected function beforeDraw():void {
			super.beforeDraw();
		
			_cxUnits = getViewPortUserUnit(svgCx, SVGUtil.WIDTH);
			_cyUnits = getViewPortUserUnit(svgCy, SVGUtil.HEIGHT);
			_rUnits = getViewPortUserUnit(svgR, SVGUtil.WIDTH); //Its based on width?
		}
		
		override protected function drawToDrawer(drawer:IDrawer):void {
			drawer.moveTo(_cxUnits + _rUnits, _cyUnits);
			drawer.arcTo(_rUnits, _rUnits, 0, true, false, _cxUnits - _rUnits, _cyUnits);
			drawer.arcTo(_rUnits, _rUnits, 0, true, false, _cxUnits + _rUnits, _cyUnits);
		}
		
		override protected function drawDirectlyToGraphics(graphics:Graphics):void {
			graphics.drawCircle(_cxUnits, _cyUnits, _rUnits);
		}
		
		override protected function get hasDrawDirectlyToGraphics():Boolean {
			return true;
		}
		
		override public function clone():Object {
			var c:SVGCircle = super.clone() as SVGCircle;
			c.svgCx = svgCx;
			c.svgCy = svgCy;
			c.svgR = svgR;
			return c;
		}
	}
}