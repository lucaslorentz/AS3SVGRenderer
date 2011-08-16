package com.lorentz.SVG.data.path
{
	public class SVGLineToHorizontalCommand extends SVGPathCommand
	{
		public var x:Number = 0;
		
		public var absolute:Boolean = false;
		
		public function SVGLineToHorizontalCommand(absolute:Boolean, x:Number = 0)
		{
			super();
			this.absolute = absolute;
			this.x = x;
		}
		
		override public function get type():String {
			return absolute ? "H" : "h";
		}
		
		override public function clone():SVGPathCommand {
			var copy:SVGLineToHorizontalCommand = new SVGLineToHorizontalCommand(absolute);
			copy.x = x;
			return copy;
		}
	}
}