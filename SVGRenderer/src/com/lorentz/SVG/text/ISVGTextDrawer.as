package com.lorentz.SVG.text
{
	import com.lorentz.SVG.data.text.SVGTextFormat;
	import com.lorentz.SVG.data.text.SVGDrawnText;
	import com.lorentz.SVG.display.base.SVGTextContainer;

	public interface ISVGTextDrawer
	{
		function start():void;
		
		function drawText(element:SVGTextContainer, text:String, svgFormat:SVGTextFormat):SVGDrawnText;
		
		function end():void;
	}
}