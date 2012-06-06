package com.lorentz.SVG.data.filters
{
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;

	public class SVGGaussianBlur implements ISVGFilter
	{
		public var stdDeviationX:Number = 0;
		public var stdDeviationY:Number = 0;
		
		public function getFlashFilter():BitmapFilter
		{
			return new BlurFilter(stdDeviationX, stdDeviationY, BitmapFilterQuality.HIGH);
		}
		
	}
}