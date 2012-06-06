package com.lorentz.SVG.data.filters
{
	import flash.filters.BitmapFilter;

	public class SVGFilterCollection
	{
		public var svgFilters:Vector.<ISVGFilter> = new Vector.<ISVGFilter>();
		
		public function getFlashFilters():Array {
			var flashFilters:Array = [];
			for each(var svgFilter:ISVGFilter in svgFilters){
				var flashFilter:BitmapFilter = svgFilter.getFlashFilter();
				if(flashFilter)
					flashFilters.push(flashFilter);
			}
			return flashFilters;
		}
	}
}