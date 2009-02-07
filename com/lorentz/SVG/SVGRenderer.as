package com.lorentz.SVG {
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	
	import flash.geom.Point;
	import com.lorentz.SVG.PathCommand;
	import com.lorentz.SVG.Bezier;
	import com.lorentz.SVG.SVGColor;
	
	public class SVGRenderer extends Sprite{
		private var svg_object:Object;
		
		//Testing
		private var currentFontSize:Number;
		private var currentViewBox:Object;
		//
		
		public function SVGRenderer(svg:Object){
			if(svg is XML){
				var parser:SVGParser = new SVGParser(svg as XML);
				this.svg_object = parser.parse();
			} else if(svg is Object) {
				this.svg_object = svg;
			}

			this.addChild(visit(svg_object));
		}
		
		private function visit(elt:Object):Sprite {
			var obj:Sprite;
			
			if(elt.parent){
				elt.styleenv = elt.parent.styleenv; //inherits parent style
			} else {
				elt.styleenv = new Object();
			}

			if(svg_object.styles[elt.type]!=null){
				elt.styleenv = SVGUtil.mergeObjectStyles(elt.styleenv, svg_object.styles[elt.type]);
			}
			
			if(elt["class"]){
				for each(var className:String in String(elt["class"]).split(" "))
					elt.styleenv = SVGUtil.mergeObjectStyles(elt.styleenv, svg_object.styles["."+className]);
			}

			if(elt.style)
				elt.styleenv = SVGUtil.mergeObjectStyles(elt.styleenv, elt.style);
				
			//Testing
			var oldFontSize = currentFontSize;
			var oldViewBox = currentViewBox;
			if(elt.styleenv["font-size"]!=null){
				currentFontSize = getUserUnit(elt.styleenv["font-size"] , currentFontSize, currentViewBox.height);
			}
			if(elt.viewBox!=null){
				currentViewBox = elt.viewBox;
			}
			//
							
			switch(elt.type) {
				case 'svg':
				obj = visitSvg(elt); break;
				
				case 'rect':
				obj = visitRect(elt); break;
				
				case 'path':
				obj = visitPath(elt); break;
				
				case 'polygon':
				obj = visitPolygon(elt); break;
				
				case 'polyline':
				obj = visitPolyline(elt); break;
				
				case 'line':
				obj = visitLine(elt); break;
				
				case 'circle':
				obj = visitCircle(elt); break;
				
				case 'ellipse':
				obj = visitEllipse(elt); break;
				
				case 'g':
				obj = visitG(elt); break;
				
				case 'clipPath':
				obj = visitClipPath(elt); break;
				
				/*case 'defs':
				obj = visitDefs(elt); break;
				
				case 'use':
				obj = visitUse(elt); break;
				
				case 'notSupported':
				obj = new Sprite(); break;
				
				default:
				throw new Error("Unknown tag type " + elt.localName());*/
			}
			
			if(obj!=null){
				if(elt.transform)
					obj.transform.matrix = elt.transform;
					
				if(elt.styleenv["display"]=="none" || elt.styleenv["visibility"]=="hidden")
					obj.visible = false;
					
				//Testing
				currentFontSize = oldFontSize;
				currentViewBox = oldViewBox;
				//
			}
			
			return obj;
		}
		
		private function visitSvg(elt:Object):Sprite {
			// the view box
			var viewBox:Sprite = new Sprite();
			viewBox.name = "viewBox";
			viewBox.graphics.drawRect(0,0,elt.viewBox.width, elt.viewBox.height);
			
			var activeArea:Sprite = new Sprite();
			activeArea.name = "activeArea";
			viewBox.addChild(activeArea);
		
			// iterate through the children of the svg node
			for each(var childElt:Object in elt.children) {
				activeArea.addChild(visit(childElt));
			}
			
			// find the minimum point in the active area.
		    var min:Point = new Point(Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY);
		    var r:Rectangle;
		    
		    var i:int = 0;
		    var c:DisplayObject;
			for (i = 0; i < activeArea.numChildren; i++) {
				c = activeArea.getChildAt(i);
				r = c.getBounds(activeArea);
				min.x = Math.min(min.x, r.x);
				min.y = Math.min(min.y, r.y);
			}
			
			// move the transform into the activeArea layer
			activeArea.x = min.x;
			activeArea.y = min.y;
			for (i = 0; i < activeArea.numChildren; i++) {
				c = activeArea.getChildAt(i);
				c.x -= min.x;
				c.y -= min.y;
			}

			//Testing
			if(elt.width!=null && elt.height!=null){
				var activeAreaWidth = elt.viewBox.width || activeArea.width;
				var activeAreaHeight = elt.viewBox.height || activeArea.height;
				
				activeArea.scaleX = getUserUnit(elt.width, currentFontSize, currentViewBox.width)/activeAreaWidth;
				activeArea.scaleY = getUserUnit(elt.height, currentFontSize, currentViewBox.height)/activeAreaHeight;
				
				activeArea.scaleX = Math.min(activeArea.scaleX, activeArea.scaleY);
				activeArea.scaleY = Math.min(activeArea.scaleX, activeArea.scaleY);
			}
			//
						
			return viewBox;
		}
		
		private function visitRect(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = elt.id != null ? elt.id : "rectangle";
			
			var x:Number = getUserUnit(elt.x, currentFontSize, currentViewBox.width);
			var y:Number = getUserUnit(elt.y, currentFontSize, currentViewBox.height);
			var width:Number = getUserUnit(elt.width, currentFontSize, currentViewBox.width);
			var height:Number = getUserUnit(elt.height, currentFontSize, currentViewBox.height);
						
			beginFill(s, elt);
			lineStyle(s, elt);
			
			if(elt.isRound) {
				var rx:Number = getUserUnit(elt.rx, currentFontSize, currentViewBox.width);
				var ry:Number = getUserUnit(elt.ry, currentFontSize, currentViewBox.height);
				s.graphics.drawRoundRect(x, y, width, height, rx, ry);
			} else {
				s.graphics.drawRect(x, y, width, height);
			}
			
			s.graphics.endFill();
			
			return s;
		}
		
		private function visitPath(elt:Object):Sprite {
        	var s:Sprite = new Sprite();
			s.name = elt.id != null ? elt.id : "path";
			
			var renderer:PathRenderer = new PathRenderer(elt.d);

			var evenodd:Boolean = elt.styleenv["fill-rule"]=="evenodd";

			if(evenodd){
				for(var i:int = 0;i<renderer.numSubPaths; i++){
					beginFill(s, elt);
					lineStyle(s, elt);
					renderer.renderSubPath(s, i);
					s.graphics.lineStyle();
					s.graphics.endFill();
				}
			} else {
				beginFill(s, elt);
				lineStyle(s, elt);
				renderer.render(s);
				s.graphics.lineStyle();
				s.graphics.endFill();
			}
			
			return s;
		}
		
		private function visitPolywhatever(elt:Object, isPolygon:Boolean):Sprite {
            var s:Sprite = new Sprite();
			if(elt.id!=null)
				s.name = elt.id;
			else
	            s.name = isPolygon ? "polygon" : "polyline";
           
		    var args:Array = elt.points;
			
            if(isPolygon) {
				beginFill(s, elt);
            }
			
           lineStyle(s, elt);
			
			if(args.length>2){
	            s.graphics.moveTo(Number(args[0]), Number(args[1]));
				
				var index:int = 2;
	            while(index < args.length) {
            		s.graphics.lineTo(Number(args[index]), Number(args[index+1]));
            		index+=2;
           		}
				
				if(isPolygon) {
	           	    s.graphics.lineTo(Number(args[0]), Number(args[1]));
	            	s.graphics.endFill();
            	}
			}
			
            s.graphics.lineStyle();
			
			return s;
		}
		private function visitPolygon(elt:Object):Sprite {
			return visitPolywhatever(elt, true);
		}
		private function visitPolyline(elt:Object):Sprite {
			return visitPolywhatever(elt, false);
		}
		private function visitLine(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = elt.id != null ? elt.id : "line";
			
			var x1:Number = getUserUnit(elt.x1, currentFontSize, currentViewBox.width);
			var y1:Number = getUserUnit(elt.y1, currentFontSize, currentViewBox.height);
			var x2:Number = getUserUnit(elt.x2, currentFontSize, currentViewBox.width);
			var y2:Number = getUserUnit(elt.y2, currentFontSize, currentViewBox.height);
			
			lineStyle(s, elt);
			s.graphics.moveTo(x1, y1);
			s.graphics.lineTo(x2, y2);
			s.graphics.lineStyle();
			return s;
		}
		private function visitCircle(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = elt.id != null ? elt.id : "circle";
			
			var cx:Number = getUserUnit(elt.cx, currentFontSize, currentViewBox.width);
			var cy:Number = getUserUnit(elt.cy, currentFontSize, currentViewBox.height);
			var r:Number = getUserUnit(elt.r, currentFontSize, currentViewBox.width); //Its based on width?
			
			beginFill(s, elt);
			lineStyle(s, elt);

			s.graphics.drawCircle(cx, cy, r);
			s.graphics.endFill();
			s.graphics.lineStyle();
			return s;
		}
		private function visitEllipse(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = elt.id != null ? elt.id : "ellipse";
			
			var cx:Number = getUserUnit(elt.cx, currentFontSize, currentViewBox.width);
			var cy:Number = getUserUnit(elt.cy, currentFontSize, currentViewBox.height);
			var rx:Number = getUserUnit(elt.rx, currentFontSize, currentViewBox.width);
			var ry:Number = getUserUnit(elt.ry, currentFontSize, currentViewBox.height);
			
			beginFill(s, elt);
			lineStyle(s, elt);

			s.graphics.drawEllipse(cx-rx, cy-ry, rx*2, ry*2);
			s.graphics.endFill();
			s.graphics.lineStyle();
			return s;
		}
		private function visitG(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = elt.id != null ? elt.id : "g";
			
	        if( elt.x != null )
                s.x = getUserUnit(elt.x, currentFontSize, currentViewBox.width);
            if( elt.y != null )
                s.y =  getUserUnit(elt.y, currentFontSize, currentViewBox.height);
			
			if(elt.transform)
				s.transform.matrix = elt.transform;
				
			for each(var childElt:Object in elt.children) {
				s.addChild(visit(childElt));
			}
			return s;
		}
		
		private function visitClipPath(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = "clipPath";
			
			notImplemented("clipPath");
			return s;
		}
		
		/*
		private function visitDefs(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = "defs";
			
			notImplemented("defs");
			return s;
		}
		*/
		
		/*private function visitUse(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = "use";
			
			notImplemented("use");
			return s;
		}*/
		
		
		private function beginFill(s:Sprite, elt:Object):void {
			var color:uint = SVGColor.parseToInt(elt.styleenv.fill);
			
			var noFill:Boolean = elt.styleenv.fill==null || elt.styleenv.fill == '' || elt.styleenv.fill=="none";

			var fill_opacity:Number = Number(elt.styleenv["opacity"]?elt.styleenv["opacity"]: (elt.styleenv["fill-opacity"]? elt.styleenv["fill-opacity"] : 1));

			if(!noFill && elt.styleenv.fill.indexOf("url")>-1){
				var id:String = StringUtil.rtrim(String(elt.styleenv.fill).split("(")[1], ")");
				id = StringUtil.ltrim(id, "#");

				var grad:Object = svg_object.gradients[id];
				
				switch(grad.type){
					case GradientType.LINEAR: {
						var x1:Number = getUserUnit(grad.x1, currentFontSize, currentViewBox.width);
						var y1:Number = getUserUnit(grad.y1, currentFontSize, currentViewBox.height);
						var x2:Number = getUserUnit(grad.x2, currentFontSize, currentViewBox.width);
						var y2:Number = getUserUnit(grad.y2, currentFontSize, currentViewBox.height);
						
						grad.mat = flashLinearGradient(x1, y1, x2, y2);
						
						s.graphics.beginGradientFill(grad.type, grad.colors, grad.alphas, grad.ratios, grad.mat, grad.spreadMethod, "rgb");
						break;
					}
					case GradientType.RADIAL: {
						var cx:Number = getUserUnit(grad.cx, currentFontSize, currentViewBox.width);
						var cy:Number = getUserUnit(grad.cy, currentFontSize, currentViewBox.height);
						var r:Number = getUserUnit(grad.r, currentFontSize, currentViewBox.width);
						var fx:Number = getUserUnit(grad.fx, currentFontSize, currentViewBox.width);
						var fy:Number = getUserUnit(grad.fy, currentFontSize, currentViewBox.height);

						grad.mat = flashRadialGradient(cx, cy, r, fx, fy);  
						
						var f = { x:fx-cx, y:fy-cy };
						grad.focalRatio = Math.sqrt( (f.x*f.x)+(f.y*f.y) )/r;
					
						if(grad.r==0)
							s.graphics.beginFill(grad.colors[grad.colors.length-1], grad.alphas[grad.alphas.length-1]);
						else
							s.graphics.beginGradientFill(grad.type, grad.colors, grad.alphas, grad.ratios, grad.mat, grad.spreadMethod, "rgb", grad.focalRatio);
							
						break;
					}
				}
				return;
			}
			s.graphics.beginFill(color, noFill?0:fill_opacity);
		}
		
		
		private function flashLinearGradient( x1:Number, y1:Number, x2:Number, y2:Number ):Matrix { 
                 var w = x2-x1;
				 var h = y2-y1; 
                 var a = Math.atan2(h,w); 
                 var vl = Math.sqrt( Math.pow(w,2) + Math.pow(h,2) ); 
                  
                 var matr = new flash.geom.Matrix(); 
                 matr.createGradientBox( 1, 1, 0, 0., 0. ); 
  
                 matr.rotate( a ); 
                 matr.scale( vl, vl ); 
                 matr.translate( x1, y1 ); 
                  
                 return matr; 
         } 
		 
		private function flashRadialGradient( cx:Number, cy:Number, r:Number, fx:Number, fy:Number ):Matrix { 
                 var d = r*2; 
                 var matr = new flash.geom.Matrix(); 
                 matr.createGradientBox( d, d, 0, 0., 0. ); 
  
                 var a = Math.atan2(fy-cy,fx-cx); 
                 matr.translate( -cx, -cy ); 
                 matr.rotate( -a );
                 matr.translate( cx, cy ); 
				 
				 matr.translate( cx-r, cy-r ); 

                 return matr; 
         } 
		
		
		private function lineStyle(s:Sprite, elt:Object):void {
			var color:uint = SVGColor.parseToInt(elt.styleenv.stroke);
			var noStroke:Boolean = elt.styleenv.stroke==null || elt.styleenv.stroke == '' || elt.styleenv.stroke=="none";

			var stroke_opacity:Number = Number(elt.styleenv["opacity"]?elt.styleenv["opacity"]: (elt.styleenv["stroke-opacity"]? elt.styleenv["stroke-opacity"] : 1));
						
			var w:Number = 1;
			if(elt.styleenv["stroke-width"])
				w = getUserUnit(elt.styleenv["stroke-width"], currentFontSize, Math.sqrt(Math.pow(currentViewBox.width,2)+Math.pow(currentViewBox.height,2))/Math.sqrt(2));

			var stroke_linecap:String = CapsStyle.NONE;

			if(elt.styleenv["stroke-linecap"]){
				var linecap:String = StringUtil.trim(elt.styleenv["stroke-linecap"]).toLowerCase(); 
				if(linecap=="round")
					stroke_linecap = CapsStyle.ROUND;
				else if(linecap=="square")
					stroke_linecap = CapsStyle.SQUARE;
			}
				
			var stroke_linejoin:String = JointStyle.MITER;
			
			if(elt.styleenv["stroke-linejoin"]){
				var linejoin:String = StringUtil.trim(elt.styleenv["stroke-linejoin"]).toLowerCase(); 
				if(linejoin=="round")
					stroke_linejoin = JointStyle.ROUND;
				else if(linejoin=="bevel")
					stroke_linejoin = JointStyle.BEVEL;
			}
			if(noStroke)
				s.graphics.lineStyle();
			else
				s.graphics.lineStyle(w, color, stroke_opacity, true, "normal", stroke_linecap, stroke_linejoin);
		}
		
		private static function notImplemented(s:String):void {
			trace("renderer has not implemented " + s);
		}
		
		public function getUserUnit(s:String, relativeReference:Number = 1, percentageReference:Number = 1):Number {
			var value:Number;
			
			if(s.indexOf("pt")!=-1){
				value = Number(StringUtil.remove(s, "pt"));
				return value*1.25;
			} else if(s.indexOf("pc")!=-1){
				value = Number(StringUtil.remove(s, "pc"));
				return value*15;
			} else if(s.indexOf("mm")!=-1){
				value = Number(StringUtil.remove(s, "mm"));
				return value*3.543307;
			} else if(s.indexOf("cm")!=-1){
				value = Number(StringUtil.remove(s, "cm"));
				return value*35.43307;
			} else if(s.indexOf("in")!=-1){
				value = Number(StringUtil.remove(s, "in"));
				return value*90;
			} else if(s.indexOf("px")!=-1){
				value = Number(StringUtil.remove(s, "px"));
				return value;
				
			//Relative
			} else if(s.indexOf("em")!=-1){
				value = Number(StringUtil.remove(s, "em"));
				return value*relativeReference;
				
			//Percentage
			} else if(s.indexOf("%")!=-1){
				value = Number(StringUtil.remove(s, "%"));
				return value/100*percentageReference;
				
			} else {
				return Number(s);
			}
		}
	}
}