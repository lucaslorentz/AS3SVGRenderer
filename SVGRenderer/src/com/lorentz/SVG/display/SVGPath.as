package com.lorentz.SVG.display {
	import com.lorentz.SVG.data.path.SVGPathCommand;
	import com.lorentz.SVG.display.base.SVGShape;
	import com.lorentz.SVG.drawing.IDrawer;
	import com.lorentz.SVG.drawing.SVGPathRenderer;
	import com.lorentz.SVG.drawing.SVGPathRenderer;
	
	public class SVGPath extends SVGShape {	
		public function SVGPath(){
			super("path");
		}
		
		private var _path:Vector.<SVGPathCommand>;
		public function get path():Vector.<SVGPathCommand> {
			return _path;
		}
		public function set path(value:Vector.<SVGPathCommand>):void {
			_path = value;
			invalidateRender();
		}
		
		private var _pathRenderer:SVGPathRenderer;
		private var _pathRenderer2:com.lorentz.SVG.drawing.SVGPathRenderer;
		
		override protected function render():void {
			_pathRenderer = new SVGPathRenderer(path); 
			super.render();
			_pathRenderer = null;
		}
		
		override protected function draw(drawer:IDrawer):void {
			_pathRenderer.render(drawer);
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGPath = super.clone(deep) as SVGPath;

			var pathCopy:Vector.<SVGPathCommand> = new Vector.<SVGPathCommand>();
			for each(var command:SVGPathCommand in path){
				pathCopy.push(command.clone());
			}
			c.path = pathCopy;
			
			return c;
		}
	}
}