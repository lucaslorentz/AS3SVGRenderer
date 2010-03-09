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
		protected var svg_object:Object;
		protected var renderedItem:DisplayObject;
		protected var currentFontSize:Number;
		protected var currentViewBox:Rectangle;
		
		public function SVGRenderer(svg:Object, renderNow:Boolean = true){
			if(svg is XML){
				var parser:SVGParser = new SVGParser(svg as XML);
				this.svg_object = parser.parse();
			} else if(svg is Object) {
				this.svg_object = svg;
			}

			if(renderNow)
				render();
		}
		
		public function get svgObject():Object {
			return svg_object;
		}
		
		public function render():void {
			if(renderedItem!=null)
				this.removeChild(renderedItem);
				
			renderedItem = visit(svg_object);
			this.addChild(renderedItem);
		}
		
		private function visit(elt:Object):Sprite {
			var obj:Sprite;
			
			inheritStyles(elt);
			
			dispatchEvent(new SVGEvent(SVGEvent.PRE_RENDER_ELEMENT, elt));
				
			//Save current fontSize and viewBoxSize, and set the new one
			var oldFontSize:Number = currentFontSize;
			var oldViewBox:* = currentViewBox;
			if(elt.finalStyle["font-size"]!=null){
				currentFontSize = getUserUnit(elt.finalStyle["font-size"], SVGUtil.HEIGHT);
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
				
				case 'image':
				obj = visitImage(elt); break;
				
				default:
				throw new Error("Unknown tag type " + elt.localName());
			}
			
			if(obj!=null){
				if(elt.transform)
					obj.transform.matrix = elt.transform;
					
				if(elt.finalStyle["display"]=="none" || elt.finalStyle["visibility"]=="hidden")
					obj.visible = false;
					
				//Testing
				if(elt.clipPath!=null && elt.clipPath!="none"){
					var id:String = StringUtil.rtrim(String(elt.clipPath).split("(")[1], ")");
					id = StringUtil.ltrim(id, "#");

					var mask:* = visitClipPath(elt.root.defs[id]);

					var newGroup:Sprite = new Sprite();
					newGroup.addChild(obj);
					newGroup.addChild(mask);
					obj.mask = mask;
					
					obj = newGroup;
				}
				
				dispatchEvent(new SVGEvent(SVGEvent.POS_RENDER_ELEMENT, elt, obj));
			}
			//Restore the old fontSize and viewBoxSize
			currentFontSize = oldFontSize;
			currentViewBox = oldViewBox;
			//
			
			return obj;
		}
		
		private function inheritStyles(elt:Object):void {
			if(elt.parent){
				elt.finalStyle = elt.parent.finalStyle; //Inherits parent style
			} else {
				elt.finalStyle = {};
			}

			if(elt.root.styles[elt.type]!=null){ //Merge with type styles
				elt.finalStyle = SVGUtil.mergeObjects(elt.finalStyle, elt.root.styles[elt.type]);
			}
			
			if(elt["class"]){ //Merge with classes styles
				for each(var className:String in String(elt["class"]).split(" "))
					elt.finalStyle = SVGUtil.mergeObjects(elt.finalStyle, elt.root.styles["."+className]);
			}

			if(elt.style) //Merge with element's style attribute
				elt.finalStyle = SVGUtil.mergeObjects(elt.finalStyle, elt.style);
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
			if(elt.width!=null && elt.height!=null && elt.width.indexOf("%")==-1 && elt.height.indexOf("%")==-1){
				var w:Number = getUserUnit(elt.width, SVGUtil.WIDTH);
				var h:Number = getUserUnit(elt.height, SVGUtil.HEIGHT);
				
				if(elt.viewBox!=null){				
					activeArea.scaleX = w/elt.viewBox.width;
					activeArea.scaleY = h/elt.viewBox.height;
				} else {
					activeArea.scaleX = w/activeArea.width;
					activeArea.scaleY = h/activeArea.height;
				}
				
				activeArea.scaleX = Math.min(activeArea.scaleX, activeArea.scaleY);
				activeArea.scaleY = Math.min(activeArea.scaleX, activeArea.scaleY);
			}
			//
						
			return viewBox;
		}
		
		private function visitRect(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = elt.id != null ? elt.id : "rectangle";
			
			var x:Number = getUserUnit(elt.x, SVGUtil.WIDTH);
			var y:Number = getUserUnit(elt.y, SVGUtil.HEIGHT);
			var width:Number = getUserUnit(elt.width, SVGUtil.WIDTH);
			var height:Number = getUserUnit(elt.height, SVGUtil.HEIGHT);
						
			beginFill(s, elt);
			lineStyle(s, elt);
			
			if(elt.isRound) {
				var rx:Number = getUserUnit(elt.rx, SVGUtil.WIDTH);
				var ry:Number = getUserUnit(elt.ry, SVGUtil.HEIGHT);
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
			
			var winding:String = elt.finalStyle["fill-rule"] == null ? "nonzero" : elt.finalStyle["fill-rule"];
			
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
			
			var x1:Number = getUserUnit(elt.x1, SVGUtil.WIDTH);
			var y1:Number = getUserUnit(elt.y1, SVGUtil.HEIGHT);
			var x2:Number = getUserUnit(elt.x2, SVGUtil.WIDTH);
			var y2:Number = getUserUnit(elt.y2, SVGUtil.HEIGHT);
			
			lineStyle(s, elt);
			s.graphics.moveTo(x1, y1);
			s.graphics.lineTo(x2, y2);
			s.graphics.lineStyle();
			return s;
		}
		private function visitCircle(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = elt.id != null ? elt.id : "circle";
			
			var cx:Number = getUserUnit(elt.cx, SVGUtil.WIDTH);
			var cy:Number = getUserUnit(elt.cy, SVGUtil.HEIGHT);
			var r:Number = getUserUnit(elt.r, SVGUtil.WIDTH); //Its based on width?
			
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
			
			var cx:Number = getUserUnit(elt.cx, SVGUtil.WIDTH);
			var cy:Number = getUserUnit(elt.cy, SVGUtil.HEIGHT);
			var rx:Number = getUserUnit(elt.rx, SVGUtil.WIDTH);
			var ry:Number = getUserUnit(elt.ry, SVGUtil.HEIGHT);
			
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
                s.x = getUserUnit(elt.x, SVGUtil.WIDTH);
            if( elt.y != null )
                s.y =  getUserUnit(elt.y, SVGUtil.HEIGHT);
			
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
                s.x = getUserUnit(elt.x, SVGUtil.WIDTH);
            if( elt.y != null )
                s.y =  getUserUnit(elt.y, SVGUtil.HEIGHT);
			
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

			var textX:Number = getUserUnit(elt.x, SVGUtil.WIDTH);
			var textY:Number = getUserUnit(elt.y, SVGUtil.HEIGHT);

			var textAnchor:String = elt.finalStyle["text-anchor"];
			
			var dTFormat:TextFormat = styleToTextFormat(elt.finalStyle);

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
					tFormat = styleToTextFormat(childElt.finalStyle);
					tField.x += getUserUnit(childElt.dx, SVGUtil.WIDTH);
					tField.y += getUserUnit(childElt.dy, SVGUtil.HEIGHT);
					if(childElt.x!=null)
						tField.x = childElt.x-textX;
					if(childElt.y!=null)
						tField.y = childElt.y-textY;
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
		
		private function visitImage(elt:Object):Sprite {
			var s:Sprite = new Sprite();
			s.name = elt.id != null ? elt.id : "image";
			
			var loader:SVGImageLoader = new SVGImageLoader();
			
			loader.width = getUserUnit(elt.width, SVGUtil.WIDTH);
			loader.height = getUserUnit(elt.height, SVGUtil.HEIGHT);
			loader.x = getUserUnit(elt.x, SVGUtil.WIDTH);
			loader.y = getUserUnit(elt.y, SVGUtil.HEIGHT);
						
			if(elt.href.match(/^data:[a-z\/]*;base64,/))
				loader.loadBase64(elt.href);
			else
				loader.loadURL(elt.href);
			
			s.addChild(loader);
			
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
				
		private function beginFill(s:Sprite, elt:Object):void {
			var fill_str:String = elt.finalStyle.fill;
			
			if(fill_str == "" || fill_str=="none"){
				s.graphics.beginFill(0xFFFFFF, 0);
			} else {
				var fill_opacity:Number = Number(elt.finalStyle["opacity"]?elt.finalStyle["opacity"]: (elt.finalStyle["fill-opacity"]? elt.finalStyle["fill-opacity"] : 1));

				if(fill_str==null){
					s.graphics.beginFill(0x000000, fill_opacity); //Initial value to fill is black
					
				} else if(fill_str.indexOf("url")>-1){
					var id:String = StringUtil.rtrim(fill_str.split("(")[1], ")");
					id = StringUtil.ltrim(id, "#");
	
					var grad:Object = elt.root.gradients[id];
					
					if(grad!=null){
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
					}
				} else {
					var color:uint = SVGColor.parseToInt(fill_str);
					s.graphics.beginFill(color, fill_opacity);
				}
			}
		}
		
		private function calculateLinearGradient(grad:Object):void {
			var x1:Number = getUserUnit(grad.x1, SVGUtil.WIDTH);
			var y1:Number = getUserUnit(grad.y1, SVGUtil.HEIGHT);
			var x2:Number = getUserUnit(grad.x2, SVGUtil.WIDTH);
			var y2:Number = getUserUnit(grad.y2, SVGUtil.HEIGHT);
			
			grad.mat = SVGUtil.flashLinearGradientMatrix(x1, y1, x2, y2);
			if(grad.transform)
				grad.mat.concat(grad.transform);
		}
				
		private function calculateRadialGradient(grad:Object):void {
			var cx:Number = getUserUnit(grad.cx, SVGUtil.WIDTH);
			var cy:Number = getUserUnit(grad.cy, SVGUtil.HEIGHT);
			var r:Number = getUserUnit(grad.r, SVGUtil.WIDTH);
			var fx:Number = getUserUnit(grad.fx, SVGUtil.WIDTH);
			var fy:Number = getUserUnit(grad.fy, SVGUtil.HEIGHT);
	
			grad.mat = SVGUtil.flashRadialGradientMatrix(cx, cy, r, fx, fy);
			if(grad.transform)
				grad.mat.concat(grad.transform);
			
			var f:* = { x:fx-cx, y:fy-cy };
			grad.focalRatio = Math.sqrt( (f.x*f.x)+(f.y*f.y) )/r;
		}
		 
		private function lineStyle(s:Sprite, elt:Object):void {
			var color:uint = SVGColor.parseToInt(elt.finalStyle.stroke);
			var noStroke:Boolean = elt.finalStyle.stroke==null || elt.finalStyle.stroke == '' || elt.finalStyle.stroke=="none";

			var stroke_opacity:Number = Number(elt.finalStyle["opacity"]?elt.finalStyle["opacity"]: (elt.finalStyle["stroke-opacity"]? elt.finalStyle["stroke-opacity"] : 1));
						
			var w:Number = 1;
			if(elt.finalStyle["stroke-width"])
				w = getUserUnit(elt.finalStyle["stroke-width"], SVGUtil.WIDTH_HEIGHT);

			var stroke_linecap:String = CapsStyle.NONE;

			if(elt.finalStyle["stroke-linecap"]){
				var linecap:String = StringUtil.trim(elt.finalStyle["stroke-linecap"]).toLowerCase(); 
				if(linecap=="round")
					stroke_linecap = CapsStyle.ROUND;
				else if(linecap=="square")
					stroke_linecap = CapsStyle.SQUARE;
			}
				
			var stroke_linejoin:String = JointStyle.MITER;
			
			if(elt.finalStyle["stroke-linejoin"]){
				var linejoin:String = StringUtil.trim(elt.finalStyle["stroke-linejoin"]).toLowerCase(); 
				if(linejoin=="round")
					stroke_linejoin = JointStyle.ROUND;
				else if(linejoin=="bevel")
					stroke_linejoin = JointStyle.BEVEL;
			}
			
			if(!noStroke && elt.finalStyle.stroke.indexOf("url")>-1){
				var id:String = StringUtil.rtrim(String(elt.finalStyle.stroke).split("(")[1], ")");
				id = StringUtil.ltrim(id, "#");

				var grad:Object = elt.root.gradients[id];
				
				if(grad!=null){
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
				}
				return;
			} else if(noStroke)
				s.graphics.lineStyle();
			else
				s.graphics.lineStyle(w, color, stroke_opacity, true, "normal", stroke_linecap, stroke_linejoin);
		}
		
		private function getFontSize(s:String):Number{
			return SVGUtil.getFontSize(s, currentFontSize, currentViewBox);
		}
		
		public function getUserUnit(s:String, viewBoxReference:String):Number {
			return SVGUtil.getUserUnit(s, currentFontSize, currentViewBox, viewBoxReference);
		}
	}
}