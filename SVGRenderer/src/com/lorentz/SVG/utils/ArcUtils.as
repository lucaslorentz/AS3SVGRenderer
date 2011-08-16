package com.lorentz.SVG.utils
{
	import flash.geom.Point;

	public class ArcUtils
	{
		/** 
		 * Function from degrafa
		 * com.degrafa.geometry.utilities.ArcUtils
		 **/
		public static function computeSvgArc(rx:Number, ry:Number,angle:Number,largeArcFlag:Boolean,sweepFlag:Boolean,
									   		x:Number,y:Number,LastPointX:Number, LastPointY:Number):Object {
			//store before we do anything with it	 
			var xAxisRotation:Number = angle;	 
			
			// Compute the half distance between the current and the final point
			var dx2:Number = (LastPointX - x) / 2.0;
			var dy2:Number = (LastPointY - y) / 2.0;
			
			// Convert angle from degrees to radians
			angle = MathUtils.degressToRadius(angle);
			var cosAngle:Number = Math.cos(angle);
			var sinAngle:Number = Math.sin(angle);
			
			//Compute (x1, y1)
			var x1:Number = (cosAngle * dx2 + sinAngle * dy2);
			var y1:Number = (-sinAngle * dx2 + cosAngle * dy2);
			
			// Ensure radii are large enough
			rx = Math.abs(rx);
			ry = Math.abs(ry);
			var Prx:Number = rx * rx;
			var Pry:Number = ry * ry;
			var Px1:Number = x1 * x1;
			var Py1:Number = y1 * y1;
			
			// check that radii are large enough
			var radiiCheck:Number = Px1/Prx + Py1/Pry;
			if (radiiCheck > 1) {
				rx = Math.sqrt(radiiCheck) * rx;
				ry = Math.sqrt(radiiCheck) * ry;
				Prx = rx * rx;
				Pry = ry * ry;
			}
			
			
			//Compute (cx1, cy1)
			var sign:Number = (largeArcFlag == sweepFlag) ? -1 : 1;
			var sq:Number = ((Prx*Pry)-(Prx*Py1)-(Pry*Px1)) / ((Prx*Py1)+(Pry*Px1));
			sq = (sq < 0) ? 0 : sq;
			var coef:Number = (sign * Math.sqrt(sq));
			var cx1:Number = coef * ((rx * y1) / ry);
			var cy1:Number = coef * -((ry * x1) / rx);
			
			
			//Compute (cx, cy) from (cx1, cy1)
			var sx2:Number = (LastPointX + x) / 2.0;
			var sy2:Number = (LastPointY + y) / 2.0;
			var cx:Number = sx2 + (cosAngle * cx1 - sinAngle * cy1);
			var cy:Number = sy2 + (sinAngle * cx1 + cosAngle * cy1);
			
			
			//Compute the angleStart (angle1) and the angleExtent (dangle)
			var ux:Number = (x1 - cx1) / rx;
			var uy:Number = (y1 - cy1) / ry;
			var vx:Number = (-x1 - cx1) / rx;
			var vy:Number = (-y1 - cy1) / ry;
			var p:Number 
			var n:Number
			
			//Compute the angle start
			n = Math.sqrt((ux * ux) + (uy * uy));
			p = ux;
			
			sign = (uy < 0) ? -1.0 : 1.0;
			
			var angleStart:Number = MathUtils.radiusToDegress(sign * Math.acos(p / n));
			
			// Compute the angle extent
			n = Math.sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy));
			p = ux * vx + uy * vy;
			sign = (ux * vy - uy * vx < 0) ? -1.0 : 1.0;
			var angleExtent:Number = MathUtils.radiusToDegress(sign * Math.acos(p / n));
			
			if(!sweepFlag && angleExtent > 0) 
			{
				angleExtent -= 360;
			} 
			else if (sweepFlag && angleExtent < 0) 
			{
				angleExtent += 360;
			}
			
			angleExtent %= 360;
			angleStart %= 360;
			
			return Object({x:LastPointX,y:LastPointY,startAngle:angleStart,arc:angleExtent,radius:rx,yRadius:ry,xAxisRotation:xAxisRotation, cx:cx,cy:cy});
		}
		
		public static function convertToCurves(x:Number, y:Number, startAngle:Number, arcAngle:Number, xRadius:Number, yRadius:Number, xAxisRotation:Number=0):Array
		{
			var curves:Array = [];
			
			// Circumvent drawing more than is needed
			if (Math.abs(arcAngle)>360) 
			{
				arcAngle = 360;
			}

			// Draw in a maximum of 45 degree segments. First we calculate how many 
			// segments are needed for our arc.
			var segs:Number = Math.ceil(Math.abs(arcAngle)/45);
			
			// Now calculate the sweep of each segment
			var segAngle:Number = arcAngle/segs;
			
			var theta:Number = MathUtils.degressToRadius(segAngle);
			var angle:Number = MathUtils.degressToRadius(startAngle);
			
			// Draw as 45 degree segments
			if (segs>0) 
			{				
				var beta:Number = MathUtils.degressToRadius(xAxisRotation);
				var sinbeta:Number = Math.sin(beta);
				var cosbeta:Number = Math.cos(beta);
				
				var cx:Number;
				var cy:Number;
				var x1:Number;
				var y1:Number;
				
				// Loop for drawing arc segments
				for (var i:int = 0; i<segs; i++) 
				{
					angle += theta;
					
					var sinangle:Number = Math.sin(angle-(theta/2));
					var cosangle:Number = Math.cos(angle-(theta/2));
					
					var div:Number = Math.cos(theta/2);
					cx= x + (xRadius * cosangle * cosbeta - yRadius * sinangle * sinbeta)/div; //Why divide by Math.cos(theta/2)?
					cy= y + (xRadius * cosangle * sinbeta + yRadius * sinangle * cosbeta)/div; //Why divide by Math.cos(theta/2)?
					
					sinangle = Math.sin(angle);
					cosangle = Math.cos(angle);
					
					x1 = x + (xRadius * cosangle * cosbeta - yRadius * sinangle * sinbeta);
					y1 = y + (xRadius * cosangle * sinbeta + yRadius * sinangle * cosbeta);
					
					curves.push( { c: new Point(cx, cy), p: new Point(x1, y1) } );
				}
			}
			
			return curves;
		}
	}
}