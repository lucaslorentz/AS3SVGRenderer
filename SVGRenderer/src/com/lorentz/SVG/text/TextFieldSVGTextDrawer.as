package com.lorentz.SVG.text
{
	import com.lorentz.SVG.data.text.SVGDrawnText;
	import com.lorentz.SVG.data.text.SVGTextFormat;
	import com.lorentz.SVG.display.base.SVGTextContainer;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;

	public class TextFieldSVGTextDrawer implements ISVGTextDrawer
	{
		public function start():void
		{
		}
		
		public function drawText(element:SVGTextContainer, text:String, svgFormat:SVGTextFormat):SVGDrawnText
		{
			var textField:TextField = new TextField();
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.text = text;
			textField.embedFonts = svgFormat.useEmbeddedFonts;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = svgFormat.fontFamily;
			textFormat.size = svgFormat.fontSize;
			textFormat.bold = svgFormat.fontWeight == "bold";
			textFormat.italic = svgFormat.fontStyle == "italic";
			textFormat.color = svgFormat.color;
			textField.setTextFormat(textFormat);
			
			var lineMetrics:TextLineMetrics = textField.getLineMetrics(0);
			
			return new SVGDrawnText(textField, textField.textWidth, 2, lineMetrics.ascent + 2);
		}
		
		public function end():void
		{	
		}		
	}
}