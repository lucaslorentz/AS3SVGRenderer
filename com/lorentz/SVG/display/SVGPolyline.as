package com.lorentz.SVG.display {
	import flash.display.Sprite;
	import com.lorentz.SVG.SVGUtil;
	
	public class SVGPolyline extends SVGShape {	
		public function SVGPolyline(){
			super();
		}
		
		public var points:Array = [];
		
		override protected function render():void {			
			var isPolygon = false;
			
			_content.graphics.clear();
			
            if(isPolygon) {
				beginFill();
            }
			
            lineStyle();
			
			if(points.length>2){
	            _content.graphics.moveTo(Number(points[0]), Number(points[1]));
				
				var index:int = 2;
	            while(index < points.length) {
            		_content.graphics.lineTo(Number(points[index]), Number(points[index+1]));
            		index+=2;
           		}
				
				if(isPolygon) {
	           	    _content.graphics.lineTo(Number(points[0]), Number(points[1]));
	            	_content.graphics.endFill();
            	}
			}

            _content.graphics.lineStyle();
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGPolyline = super.clone(deep) as SVGPolyline;
			c.points = SVGUtil.cloneArray(points);
			return c;
		}
	}
}