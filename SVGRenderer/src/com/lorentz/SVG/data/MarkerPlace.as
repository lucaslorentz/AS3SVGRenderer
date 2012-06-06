package com.lorentz.SVG.data
{
	import flash.geom.Point;

	public class MarkerPlace
	{
		public var position:Point;
		public var angle:Number;
		public var type:String;
		public var strokeWidth:Number;
		
		public function MarkerPlace(position:Point, angle:Number, type:String, strokeWidth:Number = 0) {
			this.position = position;
			this.angle = angle;
			this.type = type;
			this.strokeWidth = strokeWidth;
		}
		
		public function averageAngle(otherAngle:Number):void {
			angle = (angle + otherAngle) * 0.5;
		}
	}
}