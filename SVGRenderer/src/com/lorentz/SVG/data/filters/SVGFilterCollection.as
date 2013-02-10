package com.lorentz.SVG.data.filters
{
	import com.lorentz.SVG.utils.ICloneable;
	
	import flash.filters.BitmapFilter;

	public class SVGFilterCollection implements ICloneable
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
		
		public function clone():Object
		{
			var c:SVGFilterCollection = new SVGFilterCollection();
			for(var i:int = 0; i < svgFilters.length; i++){
				c.svgFilters.push(svgFilters[i].clone());
			}
			return c;
		}
	}
}