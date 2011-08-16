package com.lorentz.SVG.data.gradients
{
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class SVGGradient
	{
		public function SVGGradient(type:String){
			_type = type;
		}
		
		private var _type:String;
		public function get type():String {
			return _type;
		}
		
		public var gradientUnits:String;
		public var transform:Matrix;
		public var spreadMethod:String;
		
		public var colors:Array;
		public var alphas:Array;
		public var ratios:Array;
		
		public final function clone():SVGGradient {
			var clazz:Class = getDefinitionByName(getQualifiedClassName(this)) as Class;
			var copy:SVGGradient = new clazz();
			copyTo(copy);
			return copy;
		}
		
		public function copyTo(target:SVGGradient):void {
			target.gradientUnits = gradientUnits;
			target.transform = transform == null ? null : transform.clone();
			target.spreadMethod = spreadMethod;
			target.colors = colors == null ? null : colors.slice();
			target.alphas = alphas == null ? null : alphas.slice();
			target.ratios = ratios == null ? null : ratios.slice();
		}
	}
}