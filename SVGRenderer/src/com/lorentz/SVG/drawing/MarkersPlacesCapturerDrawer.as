package com.lorentz.SVG.drawing
{
	import com.lorentz.SVG.data.MarkerPlace;
	import com.lorentz.SVG.data.MarkerType;
	import com.lorentz.SVG.utils.ArcUtils;
	import com.lorentz.SVG.utils.MathUtils;
	
	import flash.geom.Point;

	public class MarkersPlacesCapturerDrawer implements IDrawer
	{
		private var _baseDrawer:IDrawer;
		
		private var _markersInfo:Vector.<MarkerPlace> = new Vector.<MarkerPlace>();
		
		private var _firstCommand:Boolean = true;
		
		public function getMarkersInfo():Vector.<MarkerPlace>
		{
			setLastMarkAsEndMark();
			return _markersInfo;
		}
				
		public function MarkersPlacesCapturerDrawer(baseDrawer:IDrawer)
		{
			_baseDrawer = baseDrawer;
		}
		
		public function arcTo(rx:Number, ry:Number, angle:Number, largeArcFlag:Boolean, sweepFlag:Boolean, x:Number, y:Number):void
		{		
			var startAngle:Number = getArcStartAngle(rx, ry, angle, largeArcFlag, sweepFlag, x, y, penX, penY);
			var endAngle:Number = getArcEndAngle(rx, ry, angle, largeArcFlag, sweepFlag, x, y, penX, penY);
			
			if(_firstCommand){
				_firstCommand = false;

				_markersInfo.push(new MarkerPlace(new Point(penX, penY), startAngle, MarkerType.START));
			} else {
				_markersInfo[_markersInfo.length-1].averageAngle(startAngle);
			}
			
			_markersInfo.push(new MarkerPlace(new Point(x, y), endAngle, MarkerType.MID));
			
			_baseDrawer.arcTo(rx, ry, angle, largeArcFlag, sweepFlag, x, y);
		}
		
		public function cubicCurveTo(cx1:Number, cy1:Number, cx2:Number, cy2:Number, x:Number, y:Number):void
		{
			var startAngle:Number = getCubicCurveStartAngle(penX, penY, cx1, cy1, cx2, cy2, x, y);
			var endAngle:Number = getCubicCurveEndAngle(penX, penY, cx1, cy1, cx2, cy2, x, y);
			
			if(_firstCommand){
				_firstCommand = false;
				
				_markersInfo.push(new MarkerPlace(new Point(penX, penY), startAngle, MarkerType.START));
			} else {
				_markersInfo[_markersInfo.length-1].averageAngle(startAngle);
			}
			
			_markersInfo.push(new MarkerPlace(new Point(x, y), endAngle, MarkerType.MID));
			
			_baseDrawer.cubicCurveTo(cx1, cy1, cx2, cy2, x, y);
		}
		
		public function curveTo(cx:Number, cy:Number, x:Number, y:Number):void
		{
			var startAngle:Number = getQuadCurveStartAngle(penX, penY, cx, cy, x, y);
			var endAngle:Number = getQuadCurveEndAngle(penX, penY, cx, cy, x, y);
			
			if(_firstCommand){
				_firstCommand = false;
				
				_markersInfo.push(new MarkerPlace(new Point(penX, penY), startAngle, MarkerType.START));
			} else {
				_markersInfo[_markersInfo.length-1].averageAngle(startAngle);
			}
			
			_markersInfo.push(new MarkerPlace(new Point(x, y), endAngle, MarkerType.MID));
			
			_baseDrawer.curveTo(cx, cy, x, y);
		}
		
		public function lineTo(x:Number, y:Number):void
		{
			var angle:Number = getLineAngle(penX, penY, x, y);
			
			if(_firstCommand){
				_firstCommand = false;
				
				_markersInfo.push(new MarkerPlace(new Point(penX, penY), angle, MarkerType.START));
			} else {
				_markersInfo[_markersInfo.length-1].averageAngle(angle);
			}
			
			_markersInfo.push(new MarkerPlace(new Point(x, y), angle, MarkerType.MID));
			
			_baseDrawer.lineTo(x, y);
		}
		
		public function moveTo(x:Number, y:Number):void
		{
			setLastMarkAsEndMark();
			
			_firstCommand = true;
			_baseDrawer.moveTo(x, y);
		}
		
		public function get penX():Number
		{
			return _baseDrawer.penX;
		}
		
		public function get penY():Number
		{
			return _baseDrawer.penY;
		}
				
		private function getArcStartAngle(rx:Number, ry:Number, angle:Number, largeArcFlag:Boolean, sweepFlag:Boolean, x:Number, y:Number, sx:Number, sy:Number):Number {
			var ellipticalArc:Object = ArcUtils.computeSvgArc(rx, ry, angle, largeArcFlag, sweepFlag, x, y, sx, sy);
			
			var curves:Array = ArcUtils.convertToCurves(ellipticalArc.cx, ellipticalArc.cy, ellipticalArc.startAngle, ellipticalArc.arc, ellipticalArc.radius, ellipticalArc.yRadius, ellipticalArc.xAxisRotation);
			
			var firstQuadCurve:Object = curves[0];
			
			return getQuadCurveStartAngle(firstQuadCurve.s.x, firstQuadCurve.s.y, firstQuadCurve.c.x, firstQuadCurve.c.y, firstQuadCurve.p.x, firstQuadCurve.p.y);
		}
		
		private function getArcEndAngle(rx:Number, ry:Number, angle:Number, largeArcFlag:Boolean, sweepFlag:Boolean, x:Number, y:Number, sx:Number, sy:Number):Number {
			var ellipticalArc:Object = ArcUtils.computeSvgArc(rx, ry, angle, largeArcFlag, sweepFlag, x, y, sx, sy);
			
			var curves:Array = ArcUtils.convertToCurves(ellipticalArc.cx, ellipticalArc.cy, ellipticalArc.startAngle, ellipticalArc.arc, ellipticalArc.radius, ellipticalArc.yRadius, ellipticalArc.xAxisRotation);
			
			var lastQuadCurve:Object = curves[curves.length - 1];
			
			return getQuadCurveEndAngle(lastQuadCurve.s.x, lastQuadCurve.s.y, lastQuadCurve.c.x, lastQuadCurve.c.y, lastQuadCurve.p.x, lastQuadCurve.p.y);
		}
		
		private function getCubicCurveStartAngle(sx:Number, sy:Number, cx1:Number, cy1:Number, cx2:Number, cy2:Number, x:Number, y:Number):Number
		{
			if(cx1 == sx && cy1 == sy)
				return MathUtils.radiusToDegress(Math.atan2(cy2 - sy, cx2 - sx));
			else
				return MathUtils.radiusToDegress(Math.atan2(cy1 - sy, cx1 - sx));
		}
		
		private function getCubicCurveEndAngle(sx:Number, sy:Number, cx1:Number, cy1:Number, cx2:Number, cy2:Number, x:Number, y:Number):Number
		{
			if(cx2 == x && cy2 == y)
				return MathUtils.radiusToDegress(Math.atan2(y - cy1, x - cx1));
			else
				return MathUtils.radiusToDegress(Math.atan2(y - cy2, x - cx2));
		}
		
		
		private function getQuadCurveStartAngle(sx:Number, sy:Number, cx:Number, cy:Number, x:Number, y:Number):Number {
			return MathUtils.radiusToDegress(Math.atan2(cy - sy, cx - sx));
		}
		
		private function getQuadCurveEndAngle(sx:Number, sy:Number, cx:Number, cy:Number, x:Number, y:Number):Number {
			return MathUtils.radiusToDegress(Math.atan2(y - cy, x - cx));
		}
		
		private function getLineAngle(sx:Number, sy:Number, x:Number, y:Number):Number{
			return MathUtils.radiusToDegress(Math.atan2(y - sy, x - sx));
		}
		
		private function setLastMarkAsEndMark():void {
			if(_markersInfo.length > 0)
				_markersInfo[_markersInfo.length-1].type = MarkerType.END;
		}
	}
}