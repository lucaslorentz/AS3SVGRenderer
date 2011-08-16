package com.lorentz.SVG.drawing
{
	public interface IDrawer
	{
		function get penX():Number;
		function get penY():Number;
		
		function moveTo(x:Number, y:Number):void;
		
		function lineTo(x:Number, y:Number):void;
		
		function curveTo(cx:Number, cy:Number, x:Number, y:Number):void;
		
		function cubicCurveTo(cx1:Number, cy1:Number, cx2:Number, cy2:Number, x:Number, y:Number):void;
		
		function arcTo(rx:Number, ry:Number, angle:Number, largeArcFlag:Boolean, sweepFlag:Boolean, x:Number, y:Number):void;
	}
}