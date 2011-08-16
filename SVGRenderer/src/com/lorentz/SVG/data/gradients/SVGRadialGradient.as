package com.lorentz.SVG.data.gradients
{
	import flash.display.GradientType;

	public class SVGRadialGradient extends SVGGradient
	{
		public function SVGRadialGradient()
		{
			super(GradientType.RADIAL);
		}
		
		public var cx:String;
		public var cy:String;
		public var r:String;
		public var fx:String;
		public var fy:String;
		
		override public function copyTo(target:SVGGradient):void {
			super.copyTo(target);
			
			var targetRadialGradient:SVGRadialGradient = target as SVGRadialGradient;
			if(targetRadialGradient){
				targetRadialGradient.cx = cx;
				targetRadialGradient.cy = cy;
				targetRadialGradient.r = r;
				targetRadialGradient.fx = fx;
				targetRadialGradient.fy = fy;
			}
		}
	}
}