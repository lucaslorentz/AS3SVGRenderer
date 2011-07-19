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
	
	public class SVGRasterRenderer extends Sprite{		
		/*protected var svg_object:Object;
		protected var renderedItem:Sprite;
		protected var currentFontSize:Number;
		protected var currentViewBox:Rectangle;
		protected var currentTransform:Matrix;
		
		public function SVGRasterRenderer(svg:Object, renderNow:Boolean = true){
			if(svg is XML){
				var parser:SVGParser = new SVGParser(svg as XML);
				this.svg_object = parser.parse();
			} else if(svg is Object) {
				this.svg_object = svg;
			}

			if(renderNow)
				render();
		}
		
		public function render():void {
			if(renderedItem!=null)
				this.removeChild(renderedItem);
			
			renderedItem = new Sprite();
			currentTransform = new Matrix();
			visit(renderedItem, svg_object);
			this.addChild(renderedItem);
		}
		
		private function visit(target:Sprite, elt:Object):void {			
			inheritStyles(elt);
			
			dispatchEvent(new SVGEvent(SVGEvent.PRE_RENDER_ELEMENT, elt));
			
			//IF the object is invisible, dont render it
			if(elt.finalStyle["display"]=="none" || elt.finalStyle["visibility"]=="hidden")
				return;
				
			//Save current fontSize and viewBoxSize, and set the new one
			var oldFontSize:Number = currentFontSize;
			var oldViewBox:* = currentViewBox;
			if(elt.finalStyle["font-size"]!=null){
				currentFontSize = getUserUnit(elt.finalStyle["font-size"], SVGUtil.HEIGHT);
			}
			if(elt.viewBox!=null){
				currentViewBox = elt.viewBox;
			}
			if(elt.transform!=null){
				var oldTransform:Matrix = currentTransform.clone();
				var t:Matrix = elt.transform.clone();
				t.concat(currentTransform);
				currentTransform = t;
			}
			//
							
			switch(elt.type) {
				case 'svg':
				visitSvg(target, elt); break;
				
				case 'rect':
				visitRect(target, elt); break;
				
				case 'path':
				visitPath(target, elt); break;
				
				case 'polygon':
				visitPolygon(target, elt); break;
				
				case 'polyline':
				visitPolyline(target, elt); break;
				
				case 'line':
				visitLine(target, elt); break;
				
				case 'circle':
				visitCircle(target, elt); break;
				
				case 'ellipse':
				visitEllipse(target, elt); break;
				
				case 'g':
				visitG(target, elt); break;
				
				case 'text':
				visitText(target, elt); break;

				default:
				throw new Error("Unknown tag type " + elt.localName());
			}
			
			//Testing
			if(elt.clipPath!=null){
				var id:String = StringUtil.rtrim(String(elt.clipPath).split("(")[1], ")");
				id = StringUtil.ltrim(id, "#");

				var mask:Sprite = new Sprite();
				visitClipPath(mask, elt.root.defs[id]);

				var newGroup:Sprite = new Sprite();
				newGroup.addChild(target);
				newGroup.addChild(mask);
				target.mask = mask;
			}
			
			//Restore the old fontSize and viewBoxSize
			currentFontSize = oldFontSize;
			currentViewBox = oldViewBox;
			if(elt.transform!=null){
				currentTransform = oldTransform;
			}
			//
		}
		
		private function inheritStyles(elt:Object):void {
			if(elt.parent){
				elt.finalStyle = elt.parent.finalStyle; //Inherits parent style
			} else {
				elt.finalStyle = new Object();
			}

			if(elt.root.styles[elt.type]!=null){ //Merge with elements styles
				elt.finalStyle = SVGUtil.mergeObjects(elt.finalStyle, elt.root.styles[elt.type]);
			}
			
			if(elt["class"]){ //Merge with classes styles
				for each(var className:String in String(elt["class"]).split(" "))
					elt.finalStyle = SVGUtil.mergeObjects(elt.finalStyle, elt.root.styles["."+className]);
			}

			if(elt.style) //Merge all styles with the style attribute
				elt.finalStyle = SVGUtil.mergeObjects(elt.finalStyle, elt.style);
		}
		
		private function visitSvg(target:Sprite, elt:Object):void {
			// iterate through the children of the svg node
			for each(var childElt:Object in elt.children) {
				visit(target, childElt)
			}
		}
		
		private function visitRect(target:Sprite, elt:Object):void {
			var x:Number = getUserUnit(elt.x, SVGUtil.WIDTH);
			var y:Number = getUserUnit(elt.y, SVGUtil.HEIGHT);
			var width:Number = getUserUnit(elt.width, SVGUtil.WIDTH);
			var height:Number = getUserUnit(elt.height, SVGUtil.HEIGHT);
						
			beginFill(target, elt);
			lineStyle(target, elt);
			
			var position:Point = currentTransform.transformPoint(new Point(x, y));
			var size:Point = currentTransform.deltaTransformPoint(new Point(width, height));
			
			if(elt.isRound) {
				var rx:Number = getUserUnit(elt.rx, SVGUtil.WIDTH);
				var ry:Number = getUserUnit(elt.ry, SVGUtil.HEIGHT);
				var rounds:Point = currentTransform.deltaTransformPoint(new Point(rx, ry));
				target.graphics.drawRoundRect(position.x, position.y, size.x, size.y, rounds.x, rounds.y);
			} else {
				target.graphics.drawRect(position.x, position.y, size.x, size.y);
			}
			
			target.graphics.endFill();
		}
		
		private function visitPath(target:Sprite, elt:Object):void {
			var winding:String = elt.finalStyle["fill-rule"] == null ? "nonzero" : elt.finalStyle["fill-rule"];
			
			var renderer:PathRenderer = new PathRenderer(elt.d);
			
			beginFill(target, elt);
			lineStyle(target, elt);
			renderer.render(target, winding);
			target.graphics.endFill();
		}
		
		private function visitPolywhatever(target:Sprite, elt:Object, isPolygon:Boolean):void {
		    var args:Array = elt.points;
			
            if(isPolygon) {
				beginFill(target, elt);
            }
			
           lineStyle(target, elt);
			
			if(args.length>2){
				var start_p:Point = currentTransform.transformPoint(new Point(Number(args[0]), Number(args[1])));
	            target.graphics.moveTo(start_p.x, start_p.y);
				
				var index:int = 2;
	            while(index < args.length) {
					var p:Point = currentTransform.transformPoint(new Point(Number(args[index]), Number(args[index+1])));
            		target.graphics.lineTo(p.x, p.y);
            		index+=2;
           		}
				
				if(isPolygon) {
	           	    target.graphics.lineTo(start_p.x, start_p.y);
	            	target.graphics.endFill();
            	}
			}
			
            target.graphics.lineStyle();
		}
		private function visitPolygon(target:Sprite, elt:Object):void {
			visitPolywhatever(target, elt, true);
		}
		private function visitPolyline(target:Sprite, elt:Object):void {
			visitPolywhatever(target, elt, false);
		}
		private function visitLine(target:Sprite, elt:Object):void {
			var x1:Number = getUserUnit(elt.x1, SVGUtil.WIDTH);
			var y1:Number = getUserUnit(elt.y1, SVGUtil.HEIGHT);
			var x2:Number = getUserUnit(elt.x2, SVGUtil.WIDTH);
			var y2:Number = getUserUnit(elt.y2, SVGUtil.HEIGHT);
			
			var p1:Point = currentTransform.transformPoint(new Point(x1, y1));
			var p2:Point = currentTransform.transformPoint(new Point(x2, y2));
			
			lineStyle(target, elt);
			target.graphics.moveTo(p1.x, p1.y);
			target.graphics.lineTo(p2.x, p2.y);
			target.graphics.lineStyle();
		}
		private function visitCircle(target:Sprite, elt:Object):void {
			var cx:Number = getUserUnit(elt.cx, SVGUtil.WIDTH);
			var cy:Number = getUserUnit(elt.cy, SVGUtil.HEIGHT);
			var r:Number = getUserUnit(elt.r, SVGUtil.WIDTH); //Its based on width?
			
			var c:Point = currentTransform.transformPoint(new Point(cx, cy));
			
			beginFill(target, elt);
			lineStyle(target, elt);

			target.graphics.drawCircle(c.x, c.y, r);
			target.graphics.endFill();
			target.graphics.lineStyle();
		}
		private function visitEllipse(target:Sprite, elt:Object):void {
			var cx:Number = getUserUnit(elt.cx, SVGUtil.WIDTH);
			var cy:Number = getUserUnit(elt.cy, SVGUtil.HEIGHT);
			var rx:Number = getUserUnit(elt.rx, SVGUtil.WIDTH);
			var ry:Number = getUserUnit(elt.ry, SVGUtil.HEIGHT);
			
			var c:Point = currentTransform.transformPoint(new Point(cx, cy));
			
			beginFill(target, elt);
			lineStyle(target, elt);

			target.graphics.drawEllipse(c.x-rx, c.y-ry, rx*2, ry*2);
			target.graphics.endFill();
			target.graphics.lineStyle();
		}
		private function visitG(target:Sprite, elt:Object):void {
			
			if(elt.x || elt.y){
				var oldTransform:Matrix = currentTransform.clone();
				var t:Matrix = new Matrix();
				if(elt.x)
					t.translate(getUserUnit(elt.x, SVGUtil.WIDTH), 0);
				if(elt.y)
					t.translate(0, getUserUnit(elt.y, SVGUtil.HEIGHT));

				t.concat(currentTransform);
				currentTransform = t;
			}
				
			for each(var childElt:Object in elt.children) {
				visit(target, childElt)
			}
			
			if(elt.x || elt.y){
				currentTransform = oldTransform;
			}
		}
		
		private function visitClipPath(target:Sprite, elt:Object):void {
			var s:Sprite = new Sprite();
			s.name = elt.id != null ? elt.id : "clipPath";
			
	        if( elt.x != null )
                s.x = getUserUnit(elt.x, SVGUtil.WIDTH);
            if( elt.y != null )
                s.y =  getUserUnit(elt.y, SVGUtil.HEIGHT);
			
			if(elt.transform)
				s.transform.matrix = elt.transform;
				
			for each(var childElt:Object in elt.children) {
				var child:Sprite = new Sprite();
				visit(child, childElt)
				s.addChild(child);
			}
		}
		
		private function visitText(target:Sprite, elt:Object):void {
			var subSprite:Sprite = new Sprite();

			var textX:Number = getUserUnit(elt.x, SVGUtil.WIDTH);
			var textY:Number = getUserUnit(elt.y, SVGUtil.HEIGHT);
			
			var position:Point = currentTransform.transformPoint(new Point(textX, textY));

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

			subSprite.x = position.x;
			subSprite.y = position.y+2; //Bottom margin
			
			if(textAnchor == "middle"){
				subSprite.x -= (subSprite.width/2);
				subSprite.y -= (subSprite.height/2);
			}
			else if(textAnchor == "end"){
				subSprite.x -= subSprite.width;
				subSprite.y -= subSprite.height;
			}
			
			target.addChild(subSprite);
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
		
		protected function getFontSize(s:String):Number{
			return SVGUtil.getFontSize(s, currentFontSize, currentViewBox);
		}
		
		protected function getUserUnit(s:String, viewBoxReference:String):Number {
			return SVGUtil.getUserUnit(s, currentFontSize, currentViewBox, viewBoxReference);
		}*/
	}
}