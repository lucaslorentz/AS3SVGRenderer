/*
	Author: Lucas Lorentz Lara - 25/09/2008
	
	Thanks to Greg. Yachuk, for the changes to use the new Flash Player 10 function drawPath.
*/

package com.lorentz.SVG{
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsPathWinding;
	import flash.display.Sprite;
	import flash.geom.Point;

	public class PathRenderer {
		private var penX:Number;
		private var penY:Number;
		
		private var target:Sprite;

		private var first:Point;
		private var lastC:Point;//Last control point
		
		private var subPaths:Array;
		private var commands:Vector.<int>;
		private var pathData:Vector.<Number>;
		
		public function get numSubPaths():int{
			return subPaths.length;
		}
		
		public function PathRenderer(commands:Array) {
			subPaths = extractSubPaths(commands);
		}
		
		public function getGraphicsPath(winding:String):GraphicsPath {
			this.target = target;
			
			commands = new Vector.<int>();
			pathData = new Vector.<Number>();
			
			penX = penY = 0;

			for(var i:int = 0;i<numSubPaths; i++){
				renderSubPath(subPaths[i], i);
			}
			
			switch (winding.toUpperCase())
			{
				case GraphicsPathWinding.EVEN_ODD.toUpperCase():
					winding = GraphicsPathWinding.EVEN_ODD;
					break;
					
				case GraphicsPathWinding.NON_ZERO.toUpperCase():
					winding = GraphicsPathWinding.NON_ZERO;
					break;
			}
			
			return new GraphicsPath(commands, pathData, winding);
		}

		public function render(target:Sprite, winding:String):void {
			var graphicsPath:GraphicsPath = getGraphicsPath(winding);
			target.graphics.drawPath(graphicsPath.commands, graphicsPath.data, graphicsPath.winding);
		}
		
		private function renderSubPath(subPath:Array, pathNumber:int):void{
			for (var c:int = 0; c < subPath.length; c++) {
				var command:PathCommand = subPath[c];
				
				if(command.type == "Z" || command.type == "z"){
					closePath();
					continue;
				}
				
				var args:Array = command.args;
								
				var a:int = 0;
				while_args : while (a<args.length){
					var type:String = command.type;
					
					if(type=="m" && pathNumber==0 && a==0) //If the first command is m, it is considered M
						type = "M";
					if(type=="M" && a>0) //Subsequent pairs of coordinates are treated as implicit lineto commands
						type = "L";
					if(type=="m" && a>0) //Subsequent pairs of coordinates are treated as implicit lineto commands
						type = "l";
					
					switch (type) {
						case "M" : moveToAbs(Number(args[a++]), Number(args[a++])); break;
						case "m" : moveToRel(Number(args[a++]), Number(args[a++])); break;
						case "L" : lineToAbs(Number(args[a++]), Number(args[a++])); break;
						case "l" : lineToRel(Number(args[a++]), Number(args[a++])); break;
						case "H" : lineToHorizontalAbs(Number(args[a++]));break;
						case "h" : lineToHorizontalRel(Number(args[a++])); break;
						case "V" : lineToVerticalAbs(Number(args[a++])); break;
						case "v" : lineToVerticalRel(Number(args[a++])); break;
						case "Q" : curveToQuadraticAbs(Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++])); break;
						case "q" : curveToQuadraticRel(Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++])); break;
						case "S" : curveToCubicSmoothAbs(Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++])); break;
						case "s" : curveToCubicSmoothRel(Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++])); break;
						case "T" : curveToQuadraticSmoothAbs(Number(args[a++]), Number(args[a++])); break;
						case "t" : curveToQuadraticSmoothRel(Number(args[a++]), Number(args[a++])); break;

						case "C" : cubicCurveToAbs(Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++])); break;
						case "c" : cubicCurveToRel(Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++])); break;
						
						case "A" : arcAbs(Number(args[a++]), Number(args[a++]), args[a++], args[a++]!=0, args[a++]!=0, Number(args[a++]), Number(args[a++])); break;
						case "a" : arcRel(Number(args[a++]), Number(args[a++]), args[a++], args[a++]!=0, args[a++]!=0, Number(args[a++]), Number(args[a++]));break;
						default : trace("Invalid PathCommand type: " +command.type);
									break while_args;
					}
				}
			}
		}
		
		public static function extractSubPaths(commands:Array):Array{
			var _subPaths:Array = new Array();
			
			var path:Array;
			for each(var command:PathCommand in commands){
				if((command.type=="M") || (command.type=="m")){
					if(path!=null && path.length>0){
						_subPaths.push(path);
					}
						
					path = new Array();
				}
				path.push(command);
			}
			if(path!=null)
				_subPaths.push(path);
			
			return _subPaths;
		}

	
		public function closePath():void {
			commands.push(GraphicsPathCommand.LINE_TO);
			pathData.push(first.x, first.y);
			penX = first.x;
			penY = first.y;
		}
		public function moveToAbs(x:Number, y:Number):void {
			commands.push(GraphicsPathCommand.MOVE_TO);
			pathData.push(x, y);
			penX = x;
			penY = y;
			first = new Point(x, y);
		}
		public function moveToRel(x:Number, y:Number):void {
			moveToAbs(x+penX, y+penY);
		}
		public function lineToAbs(x:Number, y:Number):void {
			commands.push(GraphicsPathCommand.LINE_TO);
			pathData.push(x, y);
			penX = x;
			penY = y;
		}
		public function lineToRel(x:Number, y:Number):void {
			lineToAbs(x+penX,y+penY);
		}
		public function lineToHorizontalAbs(x:Number):void {
			lineToAbs(x, penY);
		}
		public function lineToHorizontalRel(x:Number):void {
			lineToHorizontalAbs(x+penX);
		}
		public function lineToVerticalAbs(y:Number):void {
			lineToAbs(penX, y);
		}
		public function lineToVerticalRel(y:Number):void {
			lineToVerticalAbs(y+penY);
		}
		public function curveToQuadraticAbs(x1:Number, y1:Number, x:Number, y:Number):void {
			commands.push(GraphicsPathCommand.CURVE_TO);
			pathData.push(x1, y1, x, y);
			penX = x;
			penY = y;
			lastC = new Point(x1, y1);
		}
		public function curveToQuadraticRel(control_x:Number, control_y:Number, anchor_x:Number, anchor_y:Number):void {
			curveToQuadraticAbs(control_x+penX, control_y+penY, anchor_x+penX, anchor_y+penY);
		}
		public function curveToCubicSmoothAbs(x2:Number, y2:Number, x:Number, y:Number):void {
			var x1:Number = penX + (penX - lastC.x);
			var y1:Number = penY + (penY - lastC.y);

			cubicCurveToAbs(x1, y1, x2, y2, x, y);
		}
		public function curveToCubicSmoothRel(x2:Number, y2:Number, x:Number, y:Number):void {
			curveToCubicSmoothAbs(x2+penX, y2+penY, x+penX, y+penY);
		}
		public function curveToQuadraticSmoothAbs(x:Number, y:Number):void {
			var x1:Number = penX + (penX - lastC.x);
			var y1:Number = penY + (penY - lastC.y);
			curveToQuadraticAbs(x1, y1, x, y);
			lastC = new Point(x1, y1);
		}
		public function curveToQuadraticSmoothRel(x:Number, y:Number):void {
			curveToQuadraticSmoothAbs(x+penX, y+penY);
		}
		public function cubeToBezier(bezier:Bezier):void {
			for each (var quadP:Object in bezier.QPts) {
				curveToQuadraticAbs(quadP.c.x, quadP.c.y, quadP.p.x, quadP.p.y);
			}
		}
		public function cubicCurveToAbs(x1:Number, y1:Number, x2:Number, y2:Number, x:Number, y:Number):void{
			var anchor1:Point = new Point(penX, penY);
			var control1:Point = new Point(x1, y1);
			var control2:Point = new Point(x2, y2);
			var anchor2:Point = new Point(x, y);

			var bezier:Bezier = new Bezier(anchor1, control1, control2, anchor2);
			cubeToBezier(bezier);
			lastC = control2;
		}
		public function cubicCurveToRel(x1:Number, y1:Number, x2:Number, y2:Number, x:Number, y:Number):void{
			cubicCurveToAbs(x1+penX, y1+penY, x2+penX, y2+penY, x+penX, y+penY);
		}
		
		 /** 
		 * Functions from degrafa
		 * com.degrafa.geometry.utilities.ArcUtils
		 **/
		private static function computeSvgArc(rx:Number, ry:Number,angle:Number,largeArcFlag:Boolean,sweepFlag:Boolean,
												x:Number,y:Number,LastPointX:Number, LastPointY:Number):Object {
	        //store before we do anything with it	 
	        var xAxisRotation:Number = angle;	 
	        	        	        	
	        // Compute the half distance between the current and the final point
	        var dx2:Number = (LastPointX - x) / 2.0;
	        var dy2:Number = (LastPointY - y) / 2.0;
	        
	        // Convert angle from degrees to radians
	        angle = degressToRadius(angle);
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
	        
	        var angleStart:Number = radiusToDegress(sign * Math.acos(p / n));
	
	        // Compute the angle extent
	        n = Math.sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy));
	        p = ux * vx + uy * vy;
	        sign = (ux * vy - uy * vx < 0) ? -1.0 : 1.0;
	        var angleExtent:Number = radiusToDegress(sign * Math.acos(p / n));
	        
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
	    
	    private static function degressToRadius(angle:Number):Number{
			return angle*(Math.PI/180);
		}
		
		private static function radiusToDegress(angle:Number):Number{
			return angle*(180/Math.PI);
		}
		
		private function drawEllipticalArc(x:Number, y:Number, startAngle:Number, arc:Number, radius:Number,yRadius:Number, xAxisRotation:Number=0):void
		{
			// Circumvent drawing more than is needed
			if (Math.abs(arc)>360) 
			{
				arc = 360;
			}
			
			// Draw in a maximum of 45 degree segments. First we calculate how many 
			// segments are needed for our arc.
			var segs:Number = Math.ceil(Math.abs(arc)/45);
			
			// Now calculate the sweep of each segment
			var segAngle:Number = arc/segs;
			
			var theta:Number = degressToRadius(segAngle);
			var angle:Number = degressToRadius(startAngle);
			
			// Draw as 45 degree segments
			if (segs>0) 
			{				
				var beta:Number = degressToRadius(xAxisRotation);
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
					cx= x + (radius * cosangle * cosbeta - yRadius * sinangle * sinbeta)/div; //Why divide by Math.cos(theta/2)?
					cy= y + (radius * cosangle * sinbeta + yRadius * sinangle * cosbeta)/div; //Why divide by Math.cos(theta/2)?
					
					sinangle = Math.sin(angle);
					cosangle = Math.cos(angle);
					
					x1 = x + (radius * cosangle * cosbeta - yRadius * sinangle * sinbeta);
				    y1 = y + (radius * cosangle * sinbeta + yRadius * sinangle * cosbeta);
					
					curveToQuadraticAbs(cx, cy, x1, y1);
                }
            }
        }
		
        public function arcAbs(rx:Number, ry:Number,angle:Number,largeArcFlag:Boolean,sweepFlag:Boolean,
                                                x:Number,y:Number):void {
            var ellipticalArc:Object = computeSvgArc(rx, ry, angle, largeArcFlag, sweepFlag, x, y, penX, penY);    
            drawEllipticalArc(ellipticalArc.cx, ellipticalArc.cy, ellipticalArc.startAngle, ellipticalArc.arc, ellipticalArc.radius, ellipticalArc.yRadius, ellipticalArc.xAxisRotation);
        }
        
		public function arcRel(rx:Number, ry:Number, xAxisRotation:Number, largeArcFlag:Boolean, sweepFlag:Boolean, 
		 x:Number, y:Number):void {
			arcAbs(rx, ry, xAxisRotation, largeArcFlag, sweepFlag, x+penX, y+penY);
		}
	}
}