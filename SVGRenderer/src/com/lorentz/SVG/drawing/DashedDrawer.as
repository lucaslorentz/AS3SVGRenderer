package com.lorentz.SVG.drawing
{
	import com.lorentz.SVG.utils.ArcUtils;
	import com.lorentz.SVG.utils.Bezier;
	import com.lorentz.SVG.utils.MathUtils;
	
	import flash.geom.Point;
	
	public class DashedDrawer implements IDrawer
	{
		private var _baseDrawer:IDrawer;
		
		public function DashedDrawer(baseDrawer:IDrawer)
		{
			_baseDrawer = baseDrawer;
			initDash(_dashOffset);
		}
		
		/**
		 * A value representing the accuracy used in determining the length
		 * of curveTo curves.
		 */	
		public function get penX():Number {
			return _baseDrawer.penX;
		}
		
		public function get penY():Number {
			return _baseDrawer.penY;
		}
		
		private var _dashArray:Array = [10, 10]; //same as SVG's dasharray
		private var _dashOffset:Number = 0; //same as SVG's dashoffset
		
		private var _totalLength:Number = 20; //Total length of dashArray
		private var _alignToCorners:Boolean = false;
		
		public var _curveAccuracy:Number = 6;
		private var isLine:Boolean = true;
		private var _dashIndex:uint = 0; //where are we in the _dashArray currently
		private var _dashDrawnLength:Number = 0; //The length of the curent dash
		
		private var _scaleToAlign:Number = 1;
		private var _isAligned:Boolean = false;
		
		public function get dashArray():Array {
			return _dashArray;
		}
		public function set dashArray(value:Array):void {
			//check for errors
			for (var i:uint = 0; i < value.length;i++) {
				if (isNaN(value[i] = Number(value[i])) || value[i]<0) return; //error
			}
			
			//if its an odd length, make it even by doubling it
			if (value.length &1) {
				value = value.concat(value);
			}
			
			_totalLength = 0;
			for each(var v:Number in value)
				_totalLength += v;
			
			_dashArray = value;
			
			initDash(_dashOffset);
		}
		
		public function get dashOffset():Number {
			return _dashOffset;
		}
		public function set dashOffset(value:Number):void {
			_dashOffset = value;
			initDash(_dashOffset);
		}
		
		public function get alignToCorners():Boolean {
			return _alignToCorners;
		}
		public function set alignToCorners(value:Boolean):void {
			_alignToCorners = value;
		}
		
		private function initDash(offset:Number):void {
			var i:uint;
			
			isLine = true;
			_dashIndex = 0;
			_dashDrawnLength = 0;
			
			offset = offset % _totalLength;
			if(offset < 0)
				offset = _totalLength - offset;
			while(offset > 0){
				var v:Number = Math.min(offset, _dashArray[_dashIndex]);
				offset -= v;
				moveInDashArray(v);
			}
		}
		
		private function getDashLength():Number {
			if(_isAligned)
				return _dashArray[_dashIndex] * _scaleToAlign;
			else
				return _dashArray[_dashIndex];
		}
		
		private function moveInDashArray(length:Number):void {
			_dashDrawnLength += length;
			
			if(_dashDrawnLength >= getDashLength()){ //Dash complete, move to next dash
				isLine = !isLine;
				_dashIndex++;
				if(_dashIndex > dashArray.length - 1)
					_dashIndex = 0;
				_dashDrawnLength = 0;
			}
		}
		
		private function initDashAlign(length:Number):void {
			var startTrim:Number = _dashArray[0]/2;
			var endTrim:Number = _dashArray[_dashArray.length-1] + _dashArray[_dashArray.length-2]/2;
			
			length += startTrim + endTrim;
			
			var numDashArrayRepeats:int = Math.round(length / _totalLength);				
			var dashesLength:Number = _totalLength * numDashArrayRepeats;
			
			_scaleToAlign = length / dashesLength;
			
			initDash(startTrim);
			
			_isAligned = true;
		}
		
		private function endDashAlign():void {
			_isAligned = false;
			_scaleToAlign = 1;
		}
		
		
		public function moveTo(x:Number, y:Number):void {
			_baseDrawer.moveTo(x, y);
		}
		
		public function lineTo(x:Number, y:Number):void {
			if(_alignToCorners && !_isAligned){
				initDashAlign(lineLength(x-penX, y-penY));
				lineTo(x, y);
				endDashAlign();
				return;
			}
			
			do {
				var dx:Number = x-penX
				var dy:Number = y-penY;
				
				var lineLength:Number = lineLength(dx, dy);
				
				var lengthToDraw:Number = Math.min(lineLength, getDashLength() - _dashDrawnLength);
				
				var newX:Number;
				var newY:Number;
				
				if(lengthToDraw < lineLength){ //Draw part of the line
					var lineAngle:Number = Math.atan2(dy, dx);
					newX = Math.cos(lineAngle) * lengthToDraw + penX;
					newY = Math.sin(lineAngle) * lengthToDraw + penY;					
				} else {
					newX = x;
					newY = y;
				}
				
				if(isLine)
					_baseDrawer.lineTo(newX, newY);
				else
					_baseDrawer.moveTo(newX, newY);
				
				moveInDashArray(lengthToDraw);
			} while(lengthToDraw < lineLength);
			
			_scaleToAlign = 1;
		}
		
		public function curveTo(cx:Number, cy:Number, x:Number, y:Number):void {
			if(_alignToCorners && !_isAligned){
				initDashAlign(curveLength(penX, penY, cx, cy, x, y, _curveAccuracy));
				curveTo(cx, cy, x, y);
				endDashAlign();
				return;
			}
			
			do {
				var curveLength:Number = curveLength(penX, penY, cx, cy, x, y, _curveAccuracy);
				
				var lengthToDraw:Number = Math.min(curveLength, getDashLength() - _dashDrawnLength);
				
				var newCX:Number;
				var newCY:Number;
				var newX:Number;
				var newY:Number;
				
				if(lengthToDraw < curveLength){ //Draw part of the curve
					var splitCurveFactor:Number = lengthToDraw / curveLength;
					
					var curveToDraw:Array = curveSliceUpTo(penX, penY, cx, cy, x, y, splitCurveFactor);
					
					newCX = curveToDraw[2]; newCY = curveToDraw[3];
					newX = curveToDraw[4]; newY = curveToDraw[5];
					
					var otherCurve:Array = curveSliceFrom(penX, penY, cx, cy, x, y, splitCurveFactor);
					
					//Update variables of the next curve
					cx = otherCurve[2]; cy = otherCurve[3];
				} else {
					newCX = cx; newCY = cy;
					newX = x; newY = y;
				}
				
				if(isLine)
					_baseDrawer.curveTo(newCX, newCY, newX, newY);
				else
					_baseDrawer.moveTo(newX, newY);
				
				moveInDashArray(lengthToDraw);				
			} while(lengthToDraw < curveLength);
		}
		
		public function cubicCurveTo(cx1:Number, cy1:Number, cx2:Number, cy2:Number, x:Number, y:Number):void
		{
			if(_alignToCorners && !_isAligned){
				initDashAlign(cubicCurveLength(penX, penY, cx1, cy1, cx2, cy2, x, y, _curveAccuracy));
				cubicCurveTo(cx1, cy1, cx2, cy2, x, y);
				endDashAlign();
				return;
			}
			
			var bezier:Bezier = new Bezier(new Point(penX, penY), new Point(cx1, cy1), new Point(cx2, cy2), new Point(x, y));
			
			for each (var quadP:Object in bezier.QPts)
				curveTo(quadP.c.x, quadP.c.y, quadP.p.x, quadP.p.y);
		}
		
		public function arcTo(rx:Number, ry:Number, angle:Number, largeArcFlag:Boolean, sweepFlag:Boolean, x:Number, y:Number):void
		{
			if(_alignToCorners && !_isAligned){
				initDashAlign(arcLength(penX, penY, rx, ry, angle, largeArcFlag, sweepFlag, x, y, _curveAccuracy));
				arcTo(rx, ry, angle, largeArcFlag, sweepFlag, x, y);
				endDashAlign();
				return;
			}
			
			var ellipticalArc:Object = ArcUtils.computeSvgArc(rx, ry, angle, largeArcFlag, sweepFlag, x, y, penX, penY);
			
			var curves:Array = ArcUtils.convertToCurves(ellipticalArc.cx, ellipticalArc.cy, ellipticalArc.startAngle, ellipticalArc.arc, ellipticalArc.radius, ellipticalArc.yRadius, ellipticalArc.xAxisRotation);
			
			// Loop for drawing arc segments
			for (var i:int = 0; i<curves.length; i++) 
				curveTo(curves[i].c.x, curves[i].c.y, curves[i].p.x, curves[i].p.y);
		}
		
		// private methods				
		private function lineLength(sx:Number, sy:Number, ex:Number=0, ey:Number=0):Number {
			if (arguments.length == 2) return Math.sqrt(sx*sx + sy*sy);
			var dx:Number = ex - sx;
			var dy:Number = ey - sy;
			return Math.sqrt(dx*dx + dy*dy);
		}
		
		private function curveLength(sx:Number, sy:Number, cx:Number, cy:Number, ex:Number, ey:Number, accuracy:Number):Number {
			var total:Number = 0;
			var tx:Number = sx;
			var ty:Number = sy;
			var px:Number, py:Number, t:Number, it:Number, a:Number, b:Number, c:Number;
			var n:Number = (accuracy) ? accuracy : _curveAccuracy;
			for (var i:Number = 1; i<=n; i++){
				t = i/n;
				it = 1-t;
				a = it*it; b = 2*t*it; c = t*t;
				px = a*sx + b*cx + c*ex;
				py = a*sy + b*cy + c*ey;
				total += lineLength(tx, ty, px, py);
				tx = px;
				ty = py;
			}
			return total;
		}
		
		private function cubicCurveLength(sx:Number, sy:Number, cx1:Number, cy1:Number, cx2:Number, cy2:Number, x:Number, y:Number, accuracy:Number):Number {
			var bezier:Bezier = new Bezier(new Point(sx, sy), new Point(cx1, cy1), new Point(cx2, cy2), new Point(x, y));
			
			var length:Number = 0;
			var curX:Number = sx;
			var curY:Number = sy;
			
			for each (var quadP:Object in bezier.QPts){
				length += curveLength(curX, curY, quadP.c.x, quadP.c.y, quadP.p.x, quadP.p.y, accuracy);
				curX = quadP.p.x; curY = quadP.p.y;
			}
			
			return length;
		}
		
		private function arcLength(sx:Number, sy:Number, rx:Number, ry:Number, angle:Number, largeArcFlag:Boolean, sweepFlag:Boolean, x:Number, y:Number, accuracy:Number):Number {
			var ellipticalArc:Object = ArcUtils.computeSvgArc(rx, ry, angle, largeArcFlag, sweepFlag, x, y, sx, sy);
			
			var curves:Array = ArcUtils.convertToCurves(ellipticalArc.cx, ellipticalArc.cy, ellipticalArc.startAngle, ellipticalArc.arc, ellipticalArc.radius, ellipticalArc.yRadius, ellipticalArc.xAxisRotation);
			
			var length:Number = 0;
			var curX:Number = sx;
			var curY:Number = sy;
			
			for (var i:int = 0; i<curves.length; i++){
				length += curveLength(curX, curY, curves[i].c.x, curves[i].c.y, curves[i].p.x, curves[i].p.y, accuracy);
				curX = curves[i].p.x; curY = curves[i].p.y;
			}
			
			return length;
		}
		
		private function curveSliceUpTo(sx:Number, sy:Number, cx:Number, cy:Number, ex:Number, ey:Number, t:Number):Array {
			if (isNaN(t)) t = 1;
			if (t != 1) {
				var midx:Number = cx + (ex-cx)*t;
				var midy:Number = cy + (ey-cy)*t;
				cx = sx + (cx-sx)*t;
				cy = sy + (cy-sy)*t;
				ex = cx + (midx-cx)*t;
				ey = cy + (midy-cy)*t;
			}
			return [sx, sy, cx, cy, ex, ey];
		}
		
		private function curveSliceFrom(sx:Number, sy:Number, cx:Number, cy:Number, ex:Number, ey:Number, t:Number):Array {
			if (isNaN(t)) t = 1;
			if (t != 1) {
				var midx:Number = sx + (cx-sx)*t;
				var midy:Number = sy + (cy-sy)*t;
				cx = cx + (ex-cx)*t;
				cy = cy + (ey-cy)*t;
				sx = midx + (cx-midx)*t;
				sy = midy + (cy-midy)*t;
			}
			return [sx, sy, cx, cy, ex, ey];
		}
	}
}