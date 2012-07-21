package com.lorentz.SVG.data.text
{
	import flash.display.DisplayObject;

	public class SVGDrawnText
	{
		public function SVGDrawnText(displayObject:DisplayObject = null, textWidth:Number = 0, startX:Number = 0, startY:Number = 0, baseLineShift:Number = 0){
			this.displayObject = displayObject;
			this.textWidth = textWidth;
			this.startX = startX;
			this.startY = startY;
			this.baseLineShift = baseLineShift;
		}
		
		public var displayObject:DisplayObject;
		public var textWidth:Number = 0;
		public var startX:Number = 0;
		public var startY:Number = 0;
		public var direction:String;
		public var baseLineShift:Number = 0;
	}
}