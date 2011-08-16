package com.lorentz.SVG.data.path
{
	public class SVGCurveToCubicCommand extends SVGPathCommand
	{
		public var x1:Number = 0;
		public var y1:Number = 0;
		public var x2:Number = 0;
		public var y2:Number = 0;
		public var x:Number = 0;
		public var y:Number = 0;
		
		public var absolute:Boolean = false;
		
		public function SVGCurveToCubicCommand(absolute:Boolean, x1:Number = 0, y1:Number = 0, x2:Number = 0, y2:Number = 0, x:Number = 0, y:Number = 0)
		{
			super();
			this.absolute = absolute;
			this.x1 = x1;
			this.y1 = y1;
			this.x2 = x2;
			this.y2 = y2;
			this.x = x;
			this.y = y;
		}
		
		override public function get type():String {
			return absolute ? "C" : "c";
		}
		
		override public function clone():SVGPathCommand {
			var copy:SVGCurveToCubicCommand = new SVGCurveToCubicCommand(absolute);
			copy.x1 = x1;
			copy.y1 = y1;
			copy.x2 = x2;
			copy.y2 = y2;
			copy.x = x;
			copy.y = y;
			return copy;
		}
	}
}