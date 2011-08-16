package com.lorentz.SVG.data.path
{
	public class SVGCurveToQuadraticSmoothCommand extends SVGPathCommand
	{
		public var x:Number = 0;
		public var y:Number = 0;
		
		public var absolute:Boolean = false;
		
		public function SVGCurveToQuadraticSmoothCommand(absolute:Boolean, x:Number = 0, y:Number = 0)
		{
			super();
			this.absolute = absolute;
			this.x = x;
			this.y = y;
		}
		
		override public function get type():String {
			return absolute ? "T" : "t";
		}
		
		override public function clone():SVGPathCommand {
			var copy:SVGCurveToQuadraticSmoothCommand = new SVGCurveToQuadraticSmoothCommand(absolute);
			copy.x = x;
			copy.y = y;
			return copy;
		}
	}
}