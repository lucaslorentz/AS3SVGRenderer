package com.lorentz.SVG.text
{
	import com.lorentz.SVG.data.text.SVGDrawnText;
	import com.lorentz.SVG.data.text.SVGTextFormat;
	import com.lorentz.SVG.display.base.SVGTextContainer;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.FontType;
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
		
		public function drawText(element:SVGTextContainer, text:String, svgFormat:SVGTextFormat):SVGDrawnText {
			var fontDescription:FontDescription = new FontDescription();
			fontDescription.fontLookup = svgFormat.useEmbeddedFonts ? FontLookup.EMBEDDED_CFF : FontLookup.DEVICE;
			fontDescription.fontName = svgFormat.fontFamily;
			fontDescription.fontWeight = svgFormat.fontWeight == "bold" ? FontWeight.BOLD : FontWeight.NORMAL;
			fontDescription.fontPosture = svgFormat.fontStyle == "italic" ? FontPosture.ITALIC : FontPosture.NORMAL;
			
			var elementFormat:ElementFormat = new ElementFormat(fontDescription);
			elementFormat.fontSize = svgFormat.fontSize;
			elementFormat.color = svgFormat.color;
			
			var textBlock:TextBlock = new TextBlock(new TextElement(text, elementFormat));
			
			var sprite:Sprite = new Sprite();
			var textLine:TextLine = textBlock.createTextLine(null);
			sprite.addChild(textLine);
			
			var lastAtomIndex:int = textLine.atomCount - 1;
			
			// Don't consider the size of the PARAGRAPH_SEPARATOR Atom,
			// It will always be the last atom because the current text is always the last text of the paragraph
			var char:String;
			while(true){
				char = text.charAt(lastAtomIndex);
				if(char.charCodeAt() == 8233 || char == "\n"){
					lastAtomIndex--;
				} else
					break;
			}
			
			var lastAtomBounds:Rectangle = textLine.getAtomBounds(lastAtomIndex);
			
			return new SVGDrawnText(sprite, lastAtomBounds.right, 0, 0);
		}
		
		public function end():void {
		}
	}
}