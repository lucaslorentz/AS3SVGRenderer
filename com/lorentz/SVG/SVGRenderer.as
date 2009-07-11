package com.lorentz.SVG {
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class SVGRenderer extends Sprite{
		private const WIDTH:String = "width";
		private const HEIGHT:String = "height";
		private const WIDTH_HEIGHT:String = "width_height";
		
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
			
			inheritStyles(elt);
				
			//Testing
			var oldFontSize:Number = currentFontSize;
			var oldViewBox:* = currentViewBox;
			if(elt.styleenv["font-size"]!=null){
				currentFontSize = getUserUnit(elt.styleenv["font-size"], HEIGHT);
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
				
				case 'text':
				obj = visitText(elt); break;
				
				default:
				throw new Error("Unknown tag type " + elt.localName());
			}
			
			if(obj!=null){
				if(elt.transform)
					obj.transform.matrix = elt.transform;
					
				if(elt.styleenv["display"]=="none" || elt.styleenv["visibility"]=="hidden")
					obj.visible = false;
					
				//Testing
				if(elt.clipPath!=null){
					var id:String = StringUtil.rtrim(String(elt.clipPath).split("(")[1], ")");
					id = StringUtil.ltrim(id, "#");

					var mask:* = visitClipPath(svg_object.clipPaths[id]);

					var newGroup:Sprite = new Sprite();
					newGroup.addChild(obj);
					newGroup.addChild(mask);
					obj.mask = mask;
					
					obj = newGroup;
				}
					
				//Testing
				currentFontSize = oldFontSize;
				currentViewBox = oldViewBox;
				//
			}
			
			return obj;
		}
		
		private function inheritStyles(elt:Object):void {
			if(elt.parent){
				elt.styleenv = elt.parent.styleenv; //Inherits parent style
			} else {
				elt.styleenv = new Object();
			}

			if(svg_object.styles[elt.type]!=null){ //Merge with elements styles
				elt.styleenv = SVGUtil.mergeObjectStyles(elt.styleenv, svg_object.styles[elt.type]);
			}
			
			if(elt["class"]){ //Merge with classes styles
				for each(var className:String in String(elt["class"]).split(" "))
					elt.styleenv = SVGUtil.mergeObjectStyles(elt.styleenv, svg_object.styles["."+className]);
			}

			if(elt.style) //Merge all styles with the style attribute
				elt.styleenv = SVGUtil.mergeObjectStyles(elt.styleenv, elt.style);
		}
		
		private function visitSvg(elt:Object):Sprite {
			// the view box
			var viewBox:Sprite = new Sprite();
			viewBox.name = "viewBox";
			//viewBox.graphics.drawRect(0,0,elt.viewBox.width, elt.viewBox.height);
			
			var activeArea:Sprite = new Sprite();
			activeArea.name = "activeArea";
			viewBox.addChild(activeArea);
		
			// iterate through the children of the svg node
			for each(var childElt:Object in elt.children) {
				activeArea.addChild(visit(childElt));
			}
			
			/*
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
			*/

			//Testing
			if(elt.width!=null && elt.height!=null){
				var activeAreaWidth:int = elt.viewBox.width || activeArea.width;
				var activeAreaHeight:int = elt.viewBox.height || activeArea.height;
				
				activeArea.scaleX = getUserUnit(elt.width, WIDTH)/activeAreaWidth;
				activeArea.scaleY = getUserUnit(elt.height, HEIGHT)/activeAreaHeight;
				
				activeArea.scaleX = Math.min(activeArea.scaleX, activeArea.scaleY);
				activeArea.scaleY = Math.min(activeArea.scaleX, activeArea.scaleY);
			}
			//
						
			return viewBox;
		}
		
		private function visitRect(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = elt.id != null ? elt.id : "rectangle";
			
			var x:Number = getUserUnit(elt.x, WIDTH);
			var y:Number = getUserUnit(elt.y, HEIGHT);
			var width:Number = getUserUnit(elt.width, WIDTH);
			var height:Number = getUserUnit(elt.height, HEIGHT);
						
			beginFill(s, elt);
			lineStyle(s, elt);
			
			if(elt.isRound) {
				var rx:Number = getUserUnit(elt.rx, WIDTH);
				var ry:Number = getUserUnit(elt.ry, HEIGHT);
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
			
			var winding:String = elt.styleenv["fill-rule"] == null ? "nonzero" : elt.styleenv["fill-rule"];
			
			var renderer:PathRenderer = new PathRenderer(elt.d);
			
			beginFill(s, elt);
			lineStyle(s, elt);
			renderer.render(s, winding);
			s.graphics.endFill();
			
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
			
			var x1:Number = getUserUnit(elt.x1, WIDTH);
			var y1:Number = getUserUnit(elt.y1, HEIGHT);
			var x2:Number = getUserUnit(elt.x2, WIDTH);
			var y2:Number = getUserUnit(elt.y2, HEIGHT);
			
			lineStyle(s, elt);
			s.graphics.moveTo(x1, y1);
			s.graphics.lineTo(x2, y2);
			s.graphics.lineStyle();
			return s;
		}
		private function visitCircle(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = elt.id != null ? elt.id : "circle";
			
			var cx:Number = getUserUnit(elt.cx, WIDTH);
			var cy:Number = getUserUnit(elt.cy, HEIGHT);
			var r:Number = getUserUnit(elt.r, WIDTH); //Its based on width?
			
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
			
			var cx:Number = getUserUnit(elt.cx, WIDTH);
			var cy:Number = getUserUnit(elt.cy, HEIGHT);
			var rx:Number = getUserUnit(elt.rx, WIDTH);
			var ry:Number = getUserUnit(elt.ry, HEIGHT);
			
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
                s.x = getUserUnit(elt.x, WIDTH);
            if( elt.y != null )
                s.y =  getUserUnit(elt.y, HEIGHT);
			
			if(elt.transform)
				s.transform.matrix = elt.transform;
				
			for each(var childElt:Object in elt.children) {
				s.addChild(visit(childElt));
			}
			return s;
		}
		
		private function visitClipPath(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = elt.id != null ? elt.id : "clipPath";
			
	        if( elt.x != null )
                s.x = getUserUnit(elt.x, WIDTH);
            if( elt.y != null )
                s.y =  getUserUnit(elt.y, HEIGHT);
			
			if(elt.transform)
				s.transform.matrix = elt.transform;
				
			for each(var childElt:Object in elt.children) {
				s.addChild(visit(childElt));
			}
			return s;
		}
		
		private function visitText(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = elt.id != null ? elt.id : "text";
			
			var subSprite:Sprite = new Sprite();

			var textX:Number = getUserUnit(elt.x, WIDTH);
			var textY:Number = getUserUnit(elt.y, HEIGHT);

			var textAnchor:String = elt.styleenv["text-anchor"];
			
			var dTFormat:TextFormat = styleToTextFormat(elt.styleenv);

			var tField:TextField;
			var tFormat:TextFormat;
			var tx:Number = 0;
			for each(var childElt:Object in elt.children) {
				tField = new TextField();
				
				tField.autoSize = TextFieldAutoSize.LEFT;
				//tField.embedFonts = true;
				tField.antiAliasType = AntiAliasType.ADVANCED;
				tField.multiline = false;
				tField.background = false;
				tField.selectable = false;
				tField.x = tx;

				if(childElt is String){
					tField.appendText(childElt as String);
					tFormat = dTFormat;
				} else {
					tField.appendText(childElt.text);
					inheritStyles(childElt);
					tFormat = styleToTextFormat(childElt.styleenv);
					tField.x += getUserUnit(childElt.x, WIDTH);
					tField.y += getUserUnit(childElt.y, HEIGHT);
				}
				
				tField.setTextFormat(tFormat);
				
				subSprite.addChild(tField);
				
				tField.y -= 2; //Top margin
				tField.y-=tField.textHeight;
				tField.x -= 2; //Left margin
				tx+=tField.textWidth;
			}

			subSprite.x = textX;
			subSprite.y = textY+2; //Bottom margin
			
			if(textAnchor == "middle"){
				subSprite.x -= (subSprite.width/2);
				subSprite.y -= (subSprite.height/2);
			}
			else if(textAnchor == "end"){
				subSprite.x -= subSprite.width;
				subSprite.y -= subSprite.height;
			}
			
			s.addChild(subSprite);
			
			return s;
		}
		
		private function styleToTextFormat(style:Object):TextFormat {
			var sFontSize:String = style["font-size"];
			var sFont:String = style["font-family"];

			var tFormat:TextFormat = new TextFormat();
			tFormat.font = sFont == null? "Arial" : sFont;
			//tFormat.font = "Arial";
			tFormat.bold = style["font-weight"] != undefined ? true : false;
			tFormat.size = getFontSize(sFontSize==null ? "medium" : sFontSize);
			tFormat.color = SVGColor.parseToInt(style["fill"])
			
			return tFormat;
		}
		
		private function getFontSize(s:String):Number{
			switch(s){
				case "xx-small" : s = "6.94pt"; break;
				case "x-small" : s = "8.33pt"; break;
				case "small" : s = "10pt"; break;
				case "medium" : s = "12pt"; break;
				case "large" : s = "14.4pt"; break;
				case "x-large" : s = "17.28pt"; break;
				case "xx-large" : s = "20.736pt"; break;
			}
			return getUserUnit(s, WIDTH);
		}
		
		private function beginFill(s:Sprite, elt:Object):void {
			var fill_str:String = elt.styleenv.fill;
			
			if(fill_str == "" || fill_str=="none"){
				s.graphics.beginFill(0xFFFFFF, 0);
			} else {
				var fill_opacity:Number = Number(elt.styleenv["opacity"]?elt.styleenv["opacity"]: (elt.styleenv["fill-opacity"]? elt.styleenv["fill-opacity"] : 1));

				if(fill_str==null){
					s.graphics.beginFill(0x000000, fill_opacity); //Initial value to fill is black
					
				} else if(fill_str.indexOf("url")>-1){
					var id:String = StringUtil.rtrim(fill_str.split("(")[1], ")");
					id = StringUtil.ltrim(id, "#");
	
					var grad:Object = svg_object.gradients[id];
					
					switch(grad.type){
						case GradientType.LINEAR: {
							calculateLinearGradient(grad);
							
							s.graphics.beginGradientFill(grad.type, grad.colors, grad.alphas, grad.ratios, grad.mat, grad.spreadMethod, "rgb");
							
							return;
						}
						case GradientType.RADIAL: {
							calculateRadialGradient(grad);
						
							if(grad.r==0)
								s.graphics.beginFill(grad.colors[grad.colors.length-1], grad.alphas[grad.alphas.length-1]);
							else
								s.graphics.beginGradientFill(grad.type, grad.colors, grad.alphas, grad.ratios, grad.mat, grad.spreadMethod, "rgb", grad.focalRatio);
								
							return;
						}
					}
				} else {
					var color:uint = SVGColor.parseToInt(fill_str);
					s.graphics.beginFill(color, fill_opacity);
				}
			}
		}
		
		private function calculateLinearGradient(grad:Object):void {
			var x1:Number = getUserUnit(grad.x1, WIDTH);
			var y1:Number = getUserUnit(grad.y1, HEIGHT);
			var x2:Number = getUserUnit(grad.x2, WIDTH);
			var y2:Number = getUserUnit(grad.y2, HEIGHT);
			
			grad.mat = flashLinearGradientMatrix(x1, y1, x2, y2);
		}
		
		private function flashLinearGradientMatrix( x1:Number, y1:Number, x2:Number, y2:Number ):Matrix { 
			var w:Number = x2-x1;
			var h:Number = y2-y1; 
			var a:Number = Math.atan2(h,w); 
			var vl:Number = Math.sqrt( Math.pow(w,2) + Math.pow(h,2) ); 
			
			var matr:Matrix = new flash.geom.Matrix(); 
			matr.createGradientBox( 1, 1, 0, 0., 0. ); 
			
			matr.rotate( a ); 
			matr.scale( vl, vl ); 
			matr.translate( x1, y1 ); 
			
			return matr; 
        } 
		
		private function calculateRadialGradient(grad:Object):void {
			var cx:Number = getUserUnit(grad.cx, WIDTH);
			var cy:Number = getUserUnit(grad.cy, HEIGHT);
			var r:Number = getUserUnit(grad.r, WIDTH);
			var fx:Number = getUserUnit(grad.fx, WIDTH);
			var fy:Number = getUserUnit(grad.fy, HEIGHT);
	
			grad.mat = flashRadialGradientMatrix(cx, cy, r, fx, fy);  
			
			var f:* = { x:fx-cx, y:fy-cy };
			grad.focalRatio = Math.sqrt( (f.x*f.x)+(f.y*f.y) )/r;
		}
		 
		private function flashRadialGradientMatrix( cx:Number, cy:Number, r:Number, fx:Number, fy:Number ):Matrix { 
			var d:Number = r*2; 
			var mat:Matrix = new flash.geom.Matrix(); 
			mat.createGradientBox( d, d, 0, 0., 0. ); 
			
			var a:Number = Math.atan2(fy-cy,fx-cx); 
			mat.translate( -cx, -cy ); 
			mat.rotate( -a );
			mat.translate( cx, cy ); 
			
			mat.translate( cx-r, cy-r ); 
			
			return mat; 
        }
		 
		private function lineStyle(s:Sprite, elt:Object):void {
			var color:uint = SVGColor.parseToInt(elt.styleenv.stroke);
			var noStroke:Boolean = elt.styleenv.stroke==null || elt.styleenv.stroke == '' || elt.styleenv.stroke=="none";

			var stroke_opacity:Number = Number(elt.styleenv["opacity"]?elt.styleenv["opacity"]: (elt.styleenv["stroke-opacity"]? elt.styleenv["stroke-opacity"] : 1));
						
			var w:Number = 1;
			if(elt.styleenv["stroke-width"])
				w = getUserUnit(elt.styleenv["stroke-width"], WIDTH_HEIGHT);

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
			
			if(!noStroke && elt.styleenv.stroke.indexOf("url")>-1){
				var id:String = StringUtil.rtrim(String(elt.styleenv.stroke).split("(")[1], ")");
				id = StringUtil.ltrim(id, "#");

				var grad:Object = svg_object.gradients[id];
				
				switch(grad.type){
					case GradientType.LINEAR: {
						calculateLinearGradient(grad);

						s.graphics.lineGradientStyle(grad.type, grad.colors, grad.alphas, grad.ratios, grad.mat, grad.spreadMethod, "rgb");
						break;
					}
					case GradientType.RADIAL: {
						calculateRadialGradient(grad);
						
						if(grad.r==0)
							s.graphics.lineStyle(w, grad.colors[grad.colors.length-1], grad.alphas[grad.alphas.length-1], true, "normal", stroke_linecap, stroke_linejoin);
						else
							s.graphics.lineGradientStyle(grad.type, grad.colors, grad.alphas, grad.ratios, grad.mat, grad.spreadMethod, "rgb", grad.focalRatio);
							
						break;
					}
				}
				return;
			} else if(noStroke)
				s.graphics.lineStyle();
			else
				s.graphics.lineStyle(w, color, stroke_opacity, true, "normal", stroke_linecap, stroke_linejoin);
		}
		
		private static function notImplemented(s:String):void {
			trace("renderer has not implemented " + s);
		}
		
		public function getUserUnit(s:String, viewBoxReference:String):Number {
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
				return value*currentFontSize;
				
			//Percentage
			} else if(s.indexOf("%")!=-1){
				value = Number(StringUtil.remove(s, "%"));
				
				switch(viewBoxReference){
					case WIDTH : return value/100 * currentViewBox.width;
							break;
					case HEIGHT : return value/100 * currentViewBox.height;
							break;
					default : return value/100 * Math.sqrt(Math.pow(currentViewBox.width,2)+Math.pow(currentViewBox.height,2))/Math.sqrt(2)
							break;
				}
			} else {
				return Number(s);
			}
		}
	}
}