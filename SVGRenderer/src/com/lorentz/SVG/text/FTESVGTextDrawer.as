package com.lorentz.SVG.text
{
	import com.lorentz.SVG.data.text.SVGDrawnText;
	import com.lorentz.SVG.data.text.SVGTextToDraw;
	import com.lorentz.SVG.utils.TextUtils;
	
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;

	public class FTESVGTextDrawer implements ISVGTextDrawer
	{	
		public function start():void {
		}
		
		public function drawText(data:SVGTextToDraw):SVGDrawnText {
			var fontDescription:FontDescription = new FontDescription();
			fontDescription.fontLookup = data.useEmbeddedFonts ? FontLookup.EMBEDDED_CFF : FontLookup.DEVICE;
			fontDescription.fontName = data.fontFamily;
			fontDescription.fontWeight = data.fontWeight == "bold" ? FontWeight.BOLD : FontWeight.NORMAL;
			fontDescription.fontPosture = data.fontStyle == "italic" ? FontPosture.ITALIC : FontPosture.NORMAL;
			
			var elementFormat:ElementFormat = new ElementFormat(fontDescription);
			elementFormat.fontSize = data.fontSize;
			elementFormat.color = data.color;
			elementFormat.trackingRight = Math.round(data.letterSpacing);
			
			var textBlock:TextBlock = new TextBlock(new TextElement(data.text, elementFormat));
			var textLine:TextLine = textBlock.createTextLine(null);
			
			var baseLineShift:Number = 0;
			switch(data.baselineShift.toLowerCase())
			{
				case "super" :
					baseLineShift = Math.abs(elementFormat.getFontMetrics().superscriptOffset || TextUtils.SUPERSCRIPT_OFFSET) * data.parentFontSize;
					break;
				case "sub" :
					baseLineShift = -Math.abs(elementFormat.getFontMetrics().subscriptOffset || TextUtils.SUBSCRIPT_OFFSET) * data.parentFontSize;
					break;
			}
			
			return new SVGDrawnText(textLine, textLine.width, 0, 0, baseLineShift);
		}
		
		public function end():void {
		}
	}
}