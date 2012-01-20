package com.lorentz.SVG.text
{
	import com.lorentz.SVG.data.text.SVGDrawnText;
	import com.lorentz.SVG.data.text.SVGTextFormat;
	import com.lorentz.SVG.display.base.SVGTextContainer;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.engine.FontLookup;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.RenderingMode;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.TextAlign;
	import flashx.textLayout.formats.TextLayoutFormat;
	
	public class TLFSVGTextDrawer implements ISVGTextDrawer
	{
		public var textFlow:TextFlow;
		
		public function start():void {
			textFlow = new TextFlow();
			textFlow.textAlign = TextAlign.START;
		}
		
		public function drawText(element:SVGTextContainer, text:String, svgFormat:SVGTextFormat):SVGDrawnText {
			var format:TextLayoutFormat = new TextLayoutFormat();
			textFlow.fontFamily = svgFormat.fontFamily;
			textFlow.fontWeight = svgFormat.fontWeight == "bold" ? FontWeight.BOLD : FontWeight.NORMAL;
			textFlow.fontStyle = svgFormat.fontStyle == "italic" ? FontPosture.ITALIC : FontPosture.NORMAL;
			
			textFlow.fontSize = svgFormat.fontSize;
			textFlow.color = svgFormat.color;
			
			textFlow.fontLookup = svgFormat.useEmbeddedFonts ? FontLookup.EMBEDDED_CFF : FontLookup.DEVICE;
			
			// Create a sprite to place the text
			var textSprite:Sprite = new Sprite();
			
			// Create a paragraph
			var paragraphElement:ParagraphElement = new ParagraphElement();
			textFlow.addChild(paragraphElement);
			
			// Create the textSpan with the text
			var spanElementTarget:SpanElement = new SpanElement();
			spanElementTarget.format = format;
			spanElementTarget.text = text;
			paragraphElement.addChild(spanElementTarget);
			
			// Create a controller to place the text inside sprite
			var containerController:ContainerController = new ContainerController(textSprite, Number.NaN, Number.NaN);
			containerController.verticalScrollPolicy = ScrollPolicy.OFF;
			textFlow.flowComposer.addController(containerController);
			
			// Update controllers
			textFlow.flowComposer.updateAllControllers();
			
			// Get firt textLine height, and update the controller height to show only one line
			var textFlowLine:TextFlowLine = textFlow.flowComposer.getLineAt(textFlow.flowComposer.numControllers - 1);
			var textLine:TextLine = textFlowLine.getTextLine();
			
			var lastAtomIndex:int = textLine.atomCount - 1;
			
			// Don't consider the size of the PARAGRAPH_SEPARATOR Atom,
			// It will always be the last atom because the current text is always the last text of the paragraph
			var char:String;
			while(true){
				char = textFlow.getCharAtPosition(textFlowLine.absoluteStart + lastAtomIndex);
				if(char.charCodeAt() == 8233 || char == "\n"){
					lastAtomIndex--;
				} else
					break;
			}
			
			var lastAtomBounds:Rectangle = textLine.getAtomBounds(lastAtomIndex);
			containerController.setCompositionSize(lastAtomBounds.right, textFlowLine.textHeight);
			
			return new SVGDrawnText(textSprite, lastAtomBounds.right, 0, textLine.ascent);
		}
		
		public function end():void {
			textFlow.interactionManager = new SelectionManager();
			textFlow.flowComposer.updateAllControllers();
			textFlow = null;
		}
	}
}