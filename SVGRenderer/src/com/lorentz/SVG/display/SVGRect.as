package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.SVGShape;
	import com.lorentz.SVG.drawing.IDrawer;
	import com.lorentz.SVG.utils.SVGUtil;
	import com.lorentz.SVG.display.base.SVGElement;
	
	public class SVGRect extends SVGShape {
		private var _xUnits:Number;
		private var _yUnits:Number;
		private var _widthUnits:Number;
		private var _heightUnits:Number;
		private var _rxUnits:Number;
		private var _ryUnits:Number;
		
		public function SVGRect(){
			super("rect");
		}
		
		private var _svgX:String;
		public function get svgX():String {
			return _svgX;
		}
		public function set svgX(value:String):void {
			if(_svgX != value){
				_svgX = value;
				invalidateRender();
			}
		}
		
		private var _svgY:String;
		public function get svgY():String {
			return _svgY;
		}
		public function set svgY(value:String):void {
			if(_svgY != value){
				_svgY = value;
				invalidateRender();
			}
		}
		
		private var _svgWidth:String;
		public function get svgWidth():String {
			return _svgWidth;
		}
		public function set svgWidth(value:String):void {
			if(_svgWidth != value){
				_svgWidth = value;
				invalidateRender();
			}
		}

		private var _svgHeight:String;
		public function get svgHeight():String {
			return _svgHeight;
		}
		public function set svgHeight(value:String):void {
			if(_svgHeight != value){
				_svgHeight = value;
				invalidateRender();
			}
		}
	
		private var _svgRx:String;
		public function get svgRx():String {
			return _svgRx;
		}
		public function set svgRx(value:String):void {
			if(_svgRx != value){
				_svgRx = value;
				invalidateRender();
			}
		}

		private var _svgRy:String;
		public function get svgRy():String {
			return _svgRy;
		}

		public function set svgRy(value:String):void {
			if(_svgRy != value){
				_svgRy = value;
				invalidateRender();
			}
		}

		override protected function beforeDraw():void {
			super.beforeDraw();
			
			_xUnits = getViewPortUserUnit(svgX, SVGUtil.WIDTH);
			_yUnits = getViewPortUserUnit(svgY, SVGUtil.HEIGHT);
			_widthUnits = getViewPortUserUnit(svgWidth, SVGUtil.WIDTH);
			_heightUnits = getViewPortUserUnit(svgHeight, SVGUtil.HEIGHT);
			
			_rxUnits = 0;
			_ryUnits = 0;
			
			if(svgRx){
				_rxUnits = getViewPortUserUnit(svgRx, SVGUtil.WIDTH);
				if(!svgRy)
					_ryUnits = _rxUnits;
			}
			if(svgRy){
				_ryUnits = getViewPortUserUnit(svgRy, SVGUtil.HEIGHT);
				if(!svgRx)
					_rxUnits = _ryUnits;
			}
		}

		override protected function drawToDrawer(drawer:IDrawer):void {
			if(_rxUnits == 0 && _ryUnits == 0){
				drawer.moveTo(_xUnits, _yUnits);
				drawer.lineTo(_xUnits + _widthUnits, _yUnits);			
				drawer.lineTo(_xUnits + _widthUnits, _yUnits + _heightUnits);
				drawer.lineTo(_xUnits, _yUnits + _heightUnits);
				drawer.lineTo(_xUnits, _yUnits);
			} else {
				drawer.moveTo(_xUnits + _rxUnits, _yUnits);
				drawer.lineTo(_xUnits + _widthUnits - _rxUnits, _yUnits);			
				drawer.arcTo(_ryUnits, _rxUnits, 90, false, true, _xUnits + _widthUnits, _yUnits + _ryUnits); 
				drawer.lineTo(_xUnits + _widthUnits, _yUnits + _heightUnits - _ryUnits);
				drawer.arcTo(_ryUnits, _rxUnits, 90, false, true, _xUnits + _widthUnits - _rxUnits, _yUnits + _heightUnits);
				drawer.lineTo(_xUnits + _rxUnits, _yUnits + _heightUnits);
				drawer.arcTo(_ryUnits, _rxUnits, 90, false, true, _xUnits, _yUnits + _heightUnits - _ryUnits);
				drawer.lineTo(_xUnits, _yUnits + _ryUnits);
				drawer.arcTo(_ryUnits, _rxUnits, 90, false, true, _xUnits + _rxUnits, _yUnits);
			}
		}
		
		override public function clone():Object {
			var c:SVGRect = super.clone() as SVGRect;
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