package com.lorentz.SVG
{
    import flash.geom.Point;
    import flash.geom.Matrix;

	public class MatrixTransformer {
		public static function rotateAroundInternalPoint(mat:Matrix, x:Number, y:Number, angle:Number):void {
			var p:Point = mat.transformPoint(new Point(x, y));
			rotateAroundExternalPoint(mat, p.x, p.y, angle);
		}
		public static function rotateAroundExternalPoint(mat:Matrix, x:Number, y:Number, angle:Number):void {
			angle = Math.PI * angle / 180;
			mat.translate(-x, -y);
			mat.rotate(angle);
			mat.translate(x, y);
		}
		public static function setSkewX(mat:Matrix, angle:Number):void {
			angle = Math.PI * angle / 180;
			var skewMatrix:Matrix = new Matrix();
			skewMatrix.c = Math.tan(angle);
			mat.concat(skewMatrix);
		}
		public static function setSkewY(mat:Matrix, angle:Number):void {
			angle = Math.PI * angle / 180;
			var skewMatrix:Matrix = new Matrix();
			skewMatrix.b = Math.tan(angle);
			mat.concat(skewMatrix);
		}
	}
}