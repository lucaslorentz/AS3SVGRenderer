package com.lorentz.SVG.data.filters
{
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;

	public class SVGColorMatrix implements ISVGFilter
	{
		public var type:String;
		public var values:Array;
		
		public function getFlashFilter():BitmapFilter
		{
			return new ColorMatrixFilter(values);
		}
		
		public function clone():Object
		{
			var c:SVGColorMatrix = new SVGColorMatrix();
			c.type = type;
			c.values = values.slice();
			return c;
		}
	}
}