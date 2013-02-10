package com.lorentz.SVG.data.path
{
	public class SVGClosePathCommand extends SVGPathCommand
	{
		override public function get type():String {
			return "z";
		}
		
		override public function clone():Object {
			return new SVGClosePathCommand();
		}
	}
}