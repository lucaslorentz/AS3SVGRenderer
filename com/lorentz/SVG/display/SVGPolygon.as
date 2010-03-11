package com.lorentz.SVG.display {
	import flash.display.Sprite;
	import com.lorentz.SVG.SVGUtil;
	
	public class SVGPolygon extends SVGShape {	
		public function SVGPolygon(){
			super();
		}
		
		public var points:Array = [];
		
		override protected function render():void {
			var isPolygon = true;
			
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
			var c:SVGPolygon = super.clone(deep) as SVGPolygon;
			c.points = SVGUtil.cloneArray(points);
			return c;
		}
	}
}