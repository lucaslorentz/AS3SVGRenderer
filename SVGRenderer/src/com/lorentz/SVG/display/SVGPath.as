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
		private var _path:Vector.<SVGPathCommand>;
		
		public function SVGPath(){
			super("path");
		}
		
		public function get svgPath():String {
			return getAttribute("path") as String;
		}
		public function set svgPath(value:String):void {
			setAttribute("path", value);
		}
		
		public function get path():Vector.<SVGPathCommand> {
			return _path;
		}
		public function set path(value:Vector.<SVGPathCommand>):void {
			_path = value;
			_pathRenderer = null;
			invalidateRender();
		}
		
		override protected function onAttributeChanged(attributeName:String, oldValue:Object, newValue:Object):void {
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
		
		override protected function beforeDraw():void {
			super.beforeDraw();
			_pathRenderer = new SVGPathRenderer(path); 
		}
		
		override protected function drawToDrawer(drawer:IDrawer):void {
			_pathRenderer.render(drawer);
		}
		
		override public function clone():Object {
			var c:SVGPath = super.clone() as SVGPath;

			var pathCopy:Vector.<SVGPathCommand> = new Vector.<SVGPathCommand>();
			for each(var command:SVGPathCommand in path){
				pathCopy.push(command.clone());
			}
			c.path = pathCopy;
			
			return c;
		}
	}
}