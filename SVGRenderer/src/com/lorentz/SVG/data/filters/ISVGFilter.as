package com.lorentz.SVG.data.filters
{
	import com.lorentz.SVG.utils.ICloneable;
	
	import flash.filters.BitmapFilter;

	public interface ISVGFilter extends ICloneable
	{
		function getFlashFilter():BitmapFilter;
	}
}