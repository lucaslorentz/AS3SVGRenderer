package com.lorentz.SVG.text
{
	import com.lorentz.SVG.data.text.SVGDrawnText;
	import com.lorentz.SVG.data.text.SVGTextToDraw;
	
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.TextBaseline;
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
			
			var baseLinePosition:Number = 0;
			var textBaseLine:String = getTextBaseLine(data);
			if(textBaseLine)
				baseLinePosition = textLine.getBaselinePosition(textBaseLine);
			
			return new SVGDrawnText(textLine, textLine.width, 0, -baseLinePosition);
		}
		
		public function end():void {
		}
		
		private function getTextBaseLine(svgFormat:SVGTextToDraw):String {
			switch(svgFormat.baselineShift.toLowerCase()){
				case "sub" :
					return TextBaseline.DESCENT
				case "super" :
					return TextBaseline.ASCENT;
			}
			
			return null;
		}
	}
}