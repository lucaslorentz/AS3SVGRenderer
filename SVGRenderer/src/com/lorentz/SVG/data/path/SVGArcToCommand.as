package com.lorentz.SVG.data.path
{
	public class SVGArcToCommand extends SVGPathCommand
	{
		public var rx:Number = 0;
		public var ry:Number = 0;
		public var xAxisRotation:Number = 0;
		
		public var largeArc:Boolean = false;
		public var sweep:Boolean = false;
		
		public var x:Number = 0;
		public var y:Number = 0;
		
		public var absolute:Boolean = false;
		
		public function SVGArcToCommand(absolute:Boolean = false, rx:Number = 0, ry:Number = 0, xAxisRotation:Number = 0, largeArc:Boolean = false, sweep:Boolean = false, x:Number = 0, y:Number = 0)
		{
			super();
			this.absolute = absolute;
			this.rx = rx;
			this.ry = ry;
			this.xAxisRotation = xAxisRotation;
			this.largeArc = largeArc;
			this.sweep = sweep;
			this.x = x;
			this.y = y;
		}
		
		override public function get type():String {
			return absolute ? "A" : "a";
		}
		
		override public function clone():SVGPathCommand {
			var copy:SVGArcToCommand = new SVGArcToCommand(absolute);
			copy.rx = rx;
			copy.ry = ry;
			copy.xAxisRotation = xAxisRotation;
			copy.largeArc = largeArc;
			copy.sweep = sweep;
			copy.x = x;
			copy.y = y;
			return copy;
		}
	}
}