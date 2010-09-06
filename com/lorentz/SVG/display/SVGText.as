package com.lorentz.SVG.display {
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
	
	import com.lorentz.SVG.SVGUtil;
	
	public class SVGText extends SVGElement {	
		public var svgX:String;
		public var svgY:String;

		public function SVGText(){
			super();
		}
		
		public var children:Array = [];
		
		protected var subSprite:Sprite;
		
		override protected function initialize():void {
			super.initialize();
			
			//Create children
			subSprite = new Sprite();
			addChild(subSprite); //Add child before to TSpan inherit this style
			//
			
			_validateFunctions.push(render);
		}
		
		protected function render():void {
			if(subSprite.numChildren>0)
				subSprite.removeChildAt(0);

			var textX:Number = getUserUnit(svgX, SVGUtil.WIDTH);
			var textY:Number = getUserUnit(svgY, SVGUtil.HEIGHT);

			var textAnchor:String = _finalStyle["text-anchor"];
			
			var dTFormat:TextFormat = styleToTextFormat(_finalStyle);

			var tx:Number = 0;
			for each(var childElt:Object in children) {
				if(childElt is String){
					var tField:TextField = new TextField();				
					tField.autoSize = TextFieldAutoSize.LEFT;
					//tField.embedFonts = true;
					tField.antiAliasType = AntiAliasType.ADVANCED;
					tField.multiline = false;
					tField.background = false;
					tField.selectable = false;
					tField.x = tx;
					
					tField.appendText(childElt as String);

					tField.setTextFormat(dTFormat);
				
					subSprite.addChild(tField);
					
					tField.y -= 2; //Top margin
					tField.y -= tField.textHeight;
					tField.x -= 2; //Left margin
					tx+=tField.textWidth;
				} else {						
					subSprite.addChild(childElt as SVGTSpan);
					
					childElt.invalidate();
					childElt.validate();
					
					childElt.x = tx;
					
					if(childElt.svgX!=null)
						childElt.x = childElt.x-textX;
					if(childElt.svgY!=null)
						childElt.y = childElt.y-textY;
					
					tx+=childElt.width;
				}				
			}

			subSprite.x = textX;
			subSprite.y = textY+2; //Bottom margin
			
			if(textAnchor == "middle"){
				subSprite.x -= (subSprite.width/2);
				subSprite.y -= (subSprite.height/2);
			}
			else if(textAnchor == "end"){
				subSprite.x -= subSprite.width;
				subSprite.y -= subSprite.height;
			}
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGText = super.clone(deep) as SVGText;
			c.svgX = svgX;
			c.svgY = svgY;
			
			for each(var child:* in children){
				if(child is String)
					c.children.push(child);
				else if(child is SVGTSpan)
					c.children.push((child as SVGTSpan).clone());
			}

			return c;
		}
	}
}