package com.lorentz.SVG.drawing
{
	import com.lorentz.SVG.utils.ArcUtils;
	import com.lorentz.SVG.utils.Bezier;
	import com.lorentz.SVG.utils.MathUtils;
	
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsPathWinding;
	import flash.geom.Point;

	public class GraphicsPathDrawer implements IDrawer
	{
		public var commands:Vector.<int>;
		public var pathData:Vector.<Number>;
		
		private var _penX:Number = 0;
		public function get penX():Number {
			return _penX;
		}
		
		private var _penY:Number = 0;
		public function get penY():Number {
			return _penY;
		}
		
		public function GraphicsPathDrawer()
		{
			commands = new Vector.<int>();
			pathData = new Vector.<Number>();
		}
		
		public function moveTo(x:Number, y:Number):void
		{
			commands.push(GraphicsPathCommand.MOVE_TO);
			pathData.push(x, y);
			_penX = x; _penY = y;
		}
		
		public function lineTo(x:Number, y:Number):void
		{
			commands.push(GraphicsPathCommand.LINE_TO);
			pathData.push(x, y);
			_penX = x; _penY = y;
		}
		
		public function curveTo(cx:Number, cy:Number, x:Number, y:Number):void
		{
			commands.push(GraphicsPathCommand.CURVE_TO);
			pathData.push(cx, cy, x, y);
			_penX = x; _penY = y;
		}
		
		public function cubicCurveTo(cx1:Number, cy1:Number, cx2:Number, cy2:Number, x:Number, y:Number):void
		{
			var anchor1:Point = new Point(_penX, _penY);
			var control1:Point = new Point(cx1, cy1);
			var control2:Point = new Point(cx2, cy2);
			var anchor2:Point = new Point(x, y);
			
			var bezier:Bezier = new Bezier(anchor1, control1, control2, anchor2);
			
			for each (var quadP:Object in bezier.QPts)
				curveTo(quadP.c.x, quadP.c.y, quadP.p.x, quadP.p.y);
		}
		
		public function arcTo(rx:Number, ry:Number, angle:Number, largeArcFlag:Boolean, sweepFlag:Boolean, x:Number, y:Number):void
		{
			var ellipticalArc:Object = ArcUtils.computeSvgArc(rx, ry, angle, largeArcFlag, sweepFlag, x, y, _penX, _penY);
			
			var curves:Array = ArcUtils.convertToCurves(ellipticalArc.cx, ellipticalArc.cy, ellipticalArc.startAngle, ellipticalArc.arc, ellipticalArc.radius, ellipticalArc.yRadius, ellipticalArc.xAxisRotation);
			
			// Loop for drawing arc segments
			for (var i:int = 0; i<curves.length; i++) 
				curveTo(curves[i].c.x, curves[i].c.y, curves[i].p.x, curves[i].p.y);
		}
	}
}