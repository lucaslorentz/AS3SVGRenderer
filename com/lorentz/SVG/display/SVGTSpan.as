package com.lorentz.SVG.display {
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
	
	import com.lorentz.SVG.SVGUtil;
	
	public class SVGTSpan extends SVGElement {	
		public var svgX:String;
		public var svgY:String;
		public var svgDx:String;
		public var svgDy:String;
		public var text:String;
		
		public function SVGTSpan(){
			super();
		}
		
		override protected function initialize():void {
			super.initialize();
			_validateFunctions.push(render);
		}
		
		protected function render():void {
			var tField:TextField = new TextField();
			
			tField.autoSize = TextFieldAutoSize.LEFT;
			//tField.embedFonts = true;
			tField.antiAliasType = AntiAliasType.ADVANCED;
			tField.multiline = false;
			tField.background = false;
			tField.selectable = false;

			tField.appendText(text);

			var tFormat:TextFormat = styleToTextFormat(_finalStyle);
			tField.x = getUserUnit(svgDx, SVGUtil.WIDTH);
			tField.y = getUserUnit(svgDy, SVGUtil.HEIGHT);
			
			tField.setTextFormat(tFormat);
			
			addChild(tField);
			
			tField.y -= 2; //Top margin
			tField.y -= tField.textHeight;
			tField.x -= 2; //Left margin
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGTSpan = super.clone(deep) as SVGTSpan;
			c.svgX = svgX;
			c.svgY = svgY;
			c.svgDx = svgDx;
			c.svgDy = svgDy;
			c.text = text;
			return c;
		}
	}
}