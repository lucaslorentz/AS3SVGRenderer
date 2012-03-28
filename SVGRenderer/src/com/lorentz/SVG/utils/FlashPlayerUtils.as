package com.lorentz.SVG.utils
{
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	import flash.utils.describeType;

	public class FlashPlayerUtils
	{
		private static var _supportsCubicCurves:Object = null;
		public static function get supportsCubicCurves():Boolean {
			if(_supportsCubicCurves == null)
				_supportsCubicCurves = graphicsHasCubicCurveToMethod() && graphicsPathCommandHasCubicCurveToConstant();
			
			return _supportsCubicCurves;
		}
		
		private static function graphicsHasCubicCurveToMethod():Boolean {
			return describeType(Graphics).factory.method.(@name == "cubicCurveTo").length() > 0;
		}
		
		private static function graphicsPathCommandHasCubicCurveToConstant():Boolean {
			return "CUBIC_CURVE_TO" in GraphicsPathCommand;
		}
	}
}