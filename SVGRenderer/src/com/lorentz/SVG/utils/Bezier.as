package com.lorentz.SVG.utils
{
    import flash.geom.Point;

    /**
        Class: Bezier

        Bezier approximation methods used in SVG import.

                         (see muSpriteLogo.png)
    */
    public final class Bezier
    {
        /**
            Approximation deviation tolerance.

            Set tolerance to zero to use Timothee Groleau's midpoint method.
            Or larger than zero to use Robert Penner's recursive approximation method.
            In Robert Penner's version of getQuadBezier, the last argument is
            tolerance (1 = very accurate, 25 (eg) = faster, not so accurate)
        */
        public static var tolerance:Number = 1;
		
		public static var savedBeziers:Object = new Object();

        public var p1:Point = null;
        public var p2:Point = null;
        public var c1:Point = null;
        public var c2:Point = null;
        public var QPts:Array = null;

        /**
            Bezier object Constructor

            Defines a cubic bezier curve with anchor points p1 and p2,
            and control points c1 and c2.  Also calls getQuadBezier to create an
            array of quadratic bezier points, QPts, which approximate the cubic

            Parameters:
                p1 - first anchor
                p2 - second anchor
                c1 - first control
                c2 - second control
        */
        public function Bezier(p1Anchor:Point, c1Control:Point, c2Control:Point, p2Anchor:Point):void
        {
            p1 = p1Anchor;
            p2 = p2Anchor;
            c1 = c1Control;
            c2 = c2Control;
            QPts = new Array();
            getQuadBezier(p1, c1, c2, p2);
        }

        /**
            Calls either <GetQuadBez_TG> or <GetQuadBez_RP> depending on <tolerance>.

            Parameters:
                p1Anchor - first anchor
                p2Anchor - second anchor
                c1Control - first control
                c2Control - second control
        */
        private function getQuadBezier(p1Anchor:Point, c1Control:Point, c2Control:Point, p2Anchor:Point):void
        {
            if (tolerance == 0)
            {
                // Timothee Groleau's midpoint method:
                GetQuadBez_TG(p1Anchor, c1Control, c2Control, p2Anchor);
            }
            else
            {
                // Robert Penner's recursive approximation method:
                GetQuadBez_RP(p1Anchor, c1Control, c2Control, p2Anchor);
            }
        }

        /**
            Midpoint approximation of a cubic bezier with four quad segments.
            Set tolerance to zero to use it.  Adds 4 elements to QPts array.

            Parameters:
                P0 - first anchor
                P1 - first control
                P2 - second control
                P3 - second anchor
        */
        private function GetQuadBez_TG(P0:Point, P1:Point, P2:Point, P3:Point):void
        {
                 // calculates the useful base points
                 var PA:Point = Point.interpolate(P0, P1, 3/4);
                 var PB:Point = Point.interpolate(P3, P2, 3/4);

                 // get 1/16 of the [P3, P0] segment
                 var dx:Number = (P3.x - P0.x)/16;
                 var dy:Number = (P3.y - P0.y)/16;

                 // calculates control point 1
                 var Pc_1:Point = Point.interpolate(P0, P1, 3/8);

                 // calculates control point 2
                 var Pc_2:Point = Point.interpolate(PA, PB, 3/8);
                 Pc_2.x -= dx;
                 Pc_2.y -= dy;

                 // calculates control point 3
                 var Pc_3:Point = Point.interpolate(PB, PA, 3/8);
                 Pc_3.x += dx;
                 Pc_3.y += dy;

                 // calculates control point 4
                 var Pc_4:Point = Point.interpolate(P3, P2, 3/8);

                 // calculates the 3 anchor points
                 var Pa_1:Point = Point.interpolate(Pc_1, Pc_2, 0.5);
                 var Pa_2:Point = Point.interpolate(PA, PB, 0.5);
                 var Pa_3:Point = Point.interpolate(Pc_3, Pc_4, 0.5);

                 // save the four quadratic subsegments
                 this.QPts = [{p:Pa_1, c:Pc_1}, {p:Pa_2, c:Pc_2}, {p:Pa_3, c:Pc_3}, {p:P3, c:Pc_4}];
        }

        /**
            Recursive midpoint approximation of a cubic bezier with as many
            quadratic bezier segments (n) as required to achieve specified tolerance.
            Set tolerance larger than zero to use. Adds n elements to QPts array.

            Parameters:
                a - first anchor point
                b - first control point
                c - second control point
                d - second anchor point
                k - tolerance (low number = most accurate result)
        */
        private function GetQuadBez_RP(a:Point, b:Point, c:Point, d:Point):void
        {
            // find intersection between bezier arms
            var s:Point = MathUtils.intersect2Lines(a, b, c, d);
			
			if (s && !isNaN(s.x) && !isNaN(s.y))
			{
				// find distance between the midpoints
				var dx:Number = (a.x + d.x + s.x * 4 - (b.x + c.x) * 3) * .125;
				var dy:Number = (a.y + d.y + s.y * 4 - (b.y + c.y) * 3) * .125;
				// split curve if the quadratic isn't close enough
				if (dx*dx + dy*dy <= tolerance*tolerance) {
					// end recursion by saving points
					this.QPts.push({p:d,c:s});
					return;
				}
			} else {
				var mp:Point = Point.interpolate(a, d, 0.5);
				if(Point.distance(a, mp)<=tolerance){
					this.QPts.push({p:d,c:mp});
					return;
				}
			}
				
			var halves:Object = MathUtils.bezierSplit (a, b, c, d);
			var b0:Object = halves.b0;
			var b1:Object = halves.b1;
			// recursive call to subdivide curve
			getQuadBezier(a,     b0.b, b0.c, b0.d);
			getQuadBezier(b1.a,  b1.b, b1.c, d);
        }
    }
}
