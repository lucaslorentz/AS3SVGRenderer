package com.lorentz.SVG.utils
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.TextLayoutFormat;

	public class TextUtils
	{
		public static function createTextSprite(text:String, textFlow:TextFlow, format:ITextLayoutFormat):Object {			
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
			
			return { sprite: textSprite, xOffset: lastAtomBounds.right, height: textFlowLine.ascent };
		}
	}
}