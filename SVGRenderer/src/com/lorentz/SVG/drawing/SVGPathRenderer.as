package com.lorentz.SVG.drawing{
	import com.lorentz.SVG.data.path.SVGPathCommand;
	import com.lorentz.SVG.data.path.SVGArcToCommand;
	import com.lorentz.SVG.data.path.SVGCurveToCubicCommand;
	import com.lorentz.SVG.data.path.SVGCurveToCubicSmoothCommand;
	import com.lorentz.SVG.data.path.SVGCurveToQuadraticCommand;
	import com.lorentz.SVG.data.path.SVGCurveToQuadraticSmoothCommand;
	import com.lorentz.SVG.data.path.SVGLineToCommand;
	import com.lorentz.SVG.data.path.SVGLineToHorizontalCommand;
	import com.lorentz.SVG.data.path.SVGLineToVerticalCommand;
	import com.lorentz.SVG.data.path.SVGMoveToCommand;
	import com.lorentz.SVG.utils.Bezier;
	
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsPathWinding;
	import flash.display.Sprite;
	import flash.geom.Point;

	public class SVGPathRenderer {
		private var firstPoint:Point;
		private var lastControlPoint:Point;//Last control point
		
		private var commands:Vector.<com.lorentz.SVG.data.path.SVGPathCommand>;
		private var _drawer:IDrawer;
		
		public function SVGPathRenderer(commands:Vector.<com.lorentz.SVG.data.path.SVGPathCommand>) {
			this.commands = commands;
		}
		
		public function render(drawer:IDrawer):void {
			_drawer = drawer;
			
			if(_drawer.penX != 0 || _drawer.penY != 0)
				_drawer.moveTo(0, 0);
			
			for each(var pathCommand:com.lorentz.SVG.data.path.SVGPathCommand in commands){
				switch(pathCommand.type){
					case "M" :
					case "m" :
						moveTo(pathCommand as SVGMoveToCommand);
						break;
					case "L" :
					case "l" :
						lineTo(pathCommand as SVGLineToCommand);
						break;
					case "H" :
					case "h" :
						lineToHorizontal(pathCommand as SVGLineToHorizontalCommand);
						break;
					case "V" :
					case "v" :
						lineToVertical(pathCommand as SVGLineToVerticalCommand);
						break;
					case "Q" :
					case "q" :
						curveToQuadratic(pathCommand as SVGCurveToQuadraticCommand);
						break;
					case "T" :
					case "t" :
						curveToQuadraticSmooth(pathCommand as SVGCurveToQuadraticSmoothCommand);
						break;					
					case "C" :
					case "c" :
						curveToCubic(pathCommand as SVGCurveToCubicCommand);
						break;
					case "S" :
					case "s" :
						curveToCubicSmooth(pathCommand as SVGCurveToCubicSmoothCommand);
						break;
					case "A" :
					case "a" :
						arcTo(pathCommand as SVGArcToCommand);
						break;
					
					case "Z" :
					case "z" :
						closePath();
						break;
				}
			}
		}
		
		private function closePath():void {
			_drawer.lineTo(firstPoint.x, firstPoint.y);
		}
		
		private function moveTo(command:SVGMoveToCommand):void {
			var x:Number = command.x;
			var y:Number = command.y;
			
			if(!command.absolute){
				x += _drawer.penX;
				y += _drawer.penY;
			}
			
			_drawer.moveTo(x, y);
			firstPoint = new Point(x, y);
		}
		
		private function lineTo(command:SVGLineToCommand):void {
			var x:Number = command.x;
			var y:Number = command.y;
			
			if(!command.absolute){
				x += _drawer.penX;
				y += _drawer.penY;
			}
			
			_drawer.lineTo(x, y);
		}
		
		private function lineToHorizontal(command:SVGLineToHorizontalCommand):void {
			var x:Number = command.x;

			if(!command.absolute){
				x += _drawer.penX;
			}
			
			_drawer.lineTo(x, _drawer.penY);
		}
		
		private function lineToVertical(command:SVGLineToVerticalCommand):void {
			var y:Number = command.y;
			
			if(!command.absolute){
				y += _drawer.penY;
			}
			
			_drawer.lineTo(_drawer.penX, y);
		}
		
		private function curveToQuadratic(command:SVGCurveToQuadraticCommand):void {
			var x1:Number = command.x1;
			var y1:Number = command.y1;
			var x:Number = command.x;
			var y:Number = command.y;
			
			if(!command.absolute){
				x1 += _drawer.penX;
				y1 += _drawer.penY;
				x += _drawer.penX;
				y += _drawer.penY;
			}
			
			_drawer.curveTo(x1, y1, x, y);
			lastControlPoint = new Point(x1, y1);
		}
				
		private function curveToQuadraticSmooth(command:SVGCurveToQuadraticSmoothCommand):void {
			var x1:Number = _drawer.penX + (_drawer.penX - lastControlPoint.x);
			var y1:Number = _drawer.penY + (_drawer.penY - lastControlPoint.y);
			
			var x:Number = command.x;
			var y:Number = command.y;
			
			if(!command.absolute){
				x += _drawer.penX;
				y += _drawer.penY;
			}
			
			_drawer.curveTo(x1, y1, x, y);
			lastControlPoint = new Point(x1, y1);
		}
		
		private function curveToCubic(command:SVGCurveToCubicCommand):void{
			var x1:Number = command.x1;
			var y1:Number = command.y1;
			var x2:Number = command.x2;
			var y2:Number = command.y2;
			var x:Number = command.x;
			var y:Number = command.y;
			
			if(!command.absolute){
				x1 += _drawer.penX;
				y1 += _drawer.penY;
				x2 += _drawer.penX;
				y2 += _drawer.penY;
				x += _drawer.penX;
				y += _drawer.penY;
			}
			
			_drawer.cubicCurveTo(x1, y1, x2, y2, x, y);
			lastControlPoint = new Point(x2, y2);
		}
		
		private function curveToCubicSmooth(command:SVGCurveToCubicSmoothCommand):void {
			var x1:Number = _drawer.penX + (_drawer.penX - lastControlPoint.x);
			var y1:Number = _drawer.penY + (_drawer.penY - lastControlPoint.y);
			
			var x2:Number = command.x2;
			var y2:Number = command.y2;
			var x:Number = command.x;
			var y:Number = command.y;
			
			if(!command.absolute){
				x2 += _drawer.penX;
				y2 += _drawer.penY;
				x += _drawer.penX;
				y += _drawer.penY;
			}
			
			_drawer.cubicCurveTo(x1, y1, x2, y2, x, y);
			lastControlPoint = new Point(x2, y2);
		}
		
        private function arcTo(command:SVGArcToCommand):void {
			var x:Number = command.x;
			var y:Number = command.y;
			
			if(!command.absolute){
				x += _drawer.penX;
				y += _drawer.penY;
			}
			
			_drawer.arcTo(command.rx, command.ry, command.xAxisRotation, command.largeArc, command.sweep, x, y);
        }
	}
}