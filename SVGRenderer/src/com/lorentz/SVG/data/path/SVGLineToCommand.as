package com.lorentz.SVG.data.path
{
	public class SVGLineToCommand extends SVGPathCommand
	{
		public var x:Number = 0;
		public var y:Number = 0;
		
		public var absolute:Boolean = false;
		
		public function SVGLineToCommand(absolute:Boolean, x:Number = 0, y:Number = 0)
		{
			super();
			this.absolute = absolute;
			this.x = x;
			this.y = y;
		}
		
		override public function get type():String {
			return absolute ? "L" : "l";
		}
		
		override public function clone():SVGPathCommand {
			var copy:SVGLineToCommand = new SVGLineToCommand(absolute);
			copy.x = x;
			copy.y = y;
			return copy;
		}
	}
}