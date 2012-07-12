package com.lorentz.SVG.text
{
	import com.lorentz.SVG.data.text.SVGTextToDraw;
	import com.lorentz.SVG.data.text.SVGDrawnText;
	import com.lorentz.SVG.display.base.SVGTextContainer;

	public interface ISVGTextDrawer
	{
		function start():void;
		
		function drawText(data:SVGTextToDraw):SVGDrawnText;
		
		function end():void;
	}
}