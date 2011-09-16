package com.lorentz.SVG.display {
	import com.lorentz.SVG.data.path.SVGPathCommand;
	import com.lorentz.SVG.display.base.SVGElement;
	import com.lorentz.SVG.display.base.SVGShape;
	import com.lorentz.SVG.drawing.IDrawer;
	import com.lorentz.SVG.drawing.SVGPathRenderer;
	import com.lorentz.SVG.parser.SVGParserCommon;

	
	public class SVGPath extends SVGShape {
		private var _invalidPathFlag:Boolean = false;
		private var _pathRenderer:SVGPathRenderer;
		
		public function SVGPath(){
			super("path");
		}
		
		public function get svgPath():String {
			return getAttribute("path");
		}
		public function set svgPath(value:String):void {
			setAttribute("path", value);
		}
		
		private var _path:Vector.<SVGPathCommand>;
		public function get path():Vector.<SVGPathCommand> {
			return _path;
		}
		public function set path(value:Vector.<SVGPathCommand>):void {
			_path = value;
			invalidateRender();
		}
		
		override protected function onAttributeChanged(attributeName:String, oldValue:String, newValue:String):void {
			super.onAttributeChanged(attributeName, oldValue, newValue);
			
			switch(attributeName){
				case "path" :
					_invalidPathFlag = true;
					invalidateProperties();
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_invalidPathFlag)
			{
				_invalidPathFlag = false;
				path = SVGParserCommon.parsePathData(svgPath); 
			}
		}
		
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