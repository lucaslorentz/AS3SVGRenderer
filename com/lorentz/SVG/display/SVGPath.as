package com.lorentz.SVG.display {
	import flash.display.Sprite;
	
	import com.lorentz.SVG.PathRenderer;
	import com.lorentz.SVG.PathCommand;
	
	public class SVGPath extends SVGShape {	
		public function SVGPath(){
			super();
		}
		
		public var path:Array = [];
		
		override protected function render():void {
			var winding:String = _finalStyle["fill-rule"] == null ? "nonzero" : _finalStyle["fill-rule"];
			
			var renderer:PathRenderer = new PathRenderer(path);
			
			_content.graphics.clear();
			beginFill();
			lineStyle();
			renderer.render(_content, winding);
			_content.graphics.endFill();
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGPath = super.clone(deep) as SVGPath;

			for each(var command:PathCommand in path){
				c.path.push(command.clone());
			}
			
			return c;
		}
	}
}