package com.lorentz.SVG.data.path
{
	public class SVGLineToVerticalCommand extends SVGPathCommand
	{
		public var y:Number = 0;
		
		public var absolute:Boolean = false;
		
		public function SVGLineToVerticalCommand(absolute:Boolean, y:Number = 0)
		{
			super();
			this.absolute = absolute;
			this.y = y;
		}
		
		override public function get type():String {
			return absolute ? "V" : "v";
		}
		
		override public function clone():SVGPathCommand {
			var copy:SVGLineToVerticalCommand = new SVGLineToVerticalCommand(absolute);
			copy.y = y;
			return copy;
		}
	}
}