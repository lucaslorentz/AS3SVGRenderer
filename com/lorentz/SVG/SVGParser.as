package com.lorentz.SVG {
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class SVGParser {
		private var svg_original:XML;
		private var svg:XML;
		private var svg_object:Object;
		private var defs:Object = new Object();
		
		public function SVGParser(svg:XML){
			this.svg_original = svg;
		}
		
		public function parse():Object{
			processUses();
			svg_object = visit(svg);
			svg_object.defs = defs;
			svg_object.gradients = SVGParserCommon.parseGradients(svg);
			svg_object.styles = SVGParserCommon.parseStyles(svg);
			
			return svg_object;
		}
		
		private function processUses():void{
			this.svg = svg_original.copy();
			
			//Finish to implement, http://www.w3.org/TR/SVG/struct.html#UseElement
			for each(var useNode:XML in this.svg..*.(localName()=="use")){
				var xlink:Namespace = new Namespace("http://www.w3.org/1999/xlink");			
				var link:String = useNode.@xlink::href;
				link = StringUtil.ltrim(link, "#");

				var targetNode:XML = svg..*.(attribute("id")==link)[0];

				useNode.setLocalName("g");
				useNode.@xlink::href = null;
				useNode.appendChild(targetNode.copy());
			}
		}
		
		private function visit(elt:XML):Object {
			var obj:Object;
			
			switch(elt.localName()) {
				case 'svg':
				obj = visitSvg(elt);
				break;
				
				case 'rect':
				obj = visitRect(elt);
				break;
				
				case 'path':
				obj = visitPath(elt);
				break;
				
				case 'polygon':
				obj = visitPolygon(elt);
				break;
				
				case 'polyline':
				obj = visitPolyline(elt);
				break;
				
				case 'line':
				obj = visitLine(elt);
				break;
				
				case 'circle':
				obj = visitCircle(elt);
				break;
				
				case 'ellipse':
				obj = visitEllipse(elt);
				break;
				
				case 'g':
				obj = visitG(elt);
				break;
				
				case 'defs':
				obj = visitDefs(elt);
				break;
				
				case 'clipPath':
				obj = visitClipPath(elt);
				break;
				
				case 'text':
				obj = visitText(elt);
				break;
				
				case 'tspan':
				obj = visitTspan(elt);
				break;
				
				case 'image' :
				obj = visitImage(elt);
				break;
				
				case 'a' :
				obj = visitA(elt);
				break;
			}
			
			if(obj==null)
				return null;
			
			if(obj.type == null)
				obj.type = elt.localName();
				
			obj.id = elt.@id;
			
			obj.style = SVGUtil.presentationStyleToObject(elt);
			if("@style" in elt){
				obj.style = SVGUtil.mergeObjects(obj.style, SVGUtil.styleToObject(elt.@style));
			}
			
			if("@class" in elt){
				obj["class"] = String(elt.@["class"]);
			}
			
			if("@transform" in elt)
				obj.transform = SVGParserCommon.parseTransformation(elt.@transform);
				
			if("@clip-path" in elt)
				obj.clipPath = String(elt["@clip-path"]);
			
			return obj;
		}

		private function visitSvg(elt:XML):Object {
			var obj:Object = new Object();
			obj.viewBox = SVGParserCommon.parseViewBox(elt.@viewBox);
			
			if("@width" in elt)
				obj.width =  elt.@width;
			else
				obj.width = "100%";
			
			if("@height" in elt)
				obj.height = elt.@height;
			else
				obj.height = "100%";
			
			obj.children = new Array();

			for each(var childElt:XML in elt.*) {
				var child:Object = visit(childElt);
				if(child){
					child.parent = obj;
					obj.children.push(child);
				}
			}
			
			return obj;
		}
		
		private function visitRect(elt:XML):Object {
			var obj:Object = new Object();
			
			obj.x = elt.@x;
			obj.y =  elt.@y;
			obj.width =  elt.@width;
			obj.height =  elt.@height;
			obj.rx =  elt.@rx;
			obj.ry =  elt.@ry;

			obj.isRound = (obj.rx != null || obj.ry != null);
			if (obj.isRound) {
				obj.rx = (obj.ry != 0 && obj.rx == 0)?obj.ry:obj.rx;
				obj.ry = (obj.rx != 0 && obj.ry == 0)?obj.rx:obj.ry;
			}
			
			return obj;
		}
		
		private function visitPath(elt:XML):Object {
			var obj:Object = new Object();
			
			obj.d = SVGParserCommon.parsePathData(elt.@d);
			
			return obj;
		}
		
		private function visitPolygon(elt:XML):Object {
			var obj:Object = new Object();
			obj.points = SVGParserCommon.parseArgsData(elt.@points);

			return obj;
		}
		private function visitPolyline(elt:XML):Object {
			var obj:Object = new Object();
			obj.points = SVGParserCommon.parseArgsData(elt.@points);

			return obj;
		}
		private function visitLine(elt:XML):Object {
			var obj:Object = new Object();

			obj.x1 = elt.@x1;
			obj.y1 = elt.@y1;
			
			obj.x2 = elt.@x2;
			obj.y2 = elt.@y2;

			return obj;
		}
		private function visitCircle(elt:XML):Object {
			var obj:Object = new Object();

			obj.cx = elt.@cx;
			obj.cy = elt.@cy;

			obj.r = elt.@r;

			return obj;
		}
		private function visitEllipse(elt:XML):Object {
			var obj:Object = new Object();

			obj.cx = elt.@cx;
			obj.cy = elt.@cy;
			obj.rx = elt.@rx;
			obj.ry = elt.@ry;
			
			return obj;
		}
		private function visitG(elt:XML):Object {
			var obj:Object = new Object();
			
			obj.children = new Array();
			for each(var childElt:XML in elt.*) {
				var child:Object = visit(childElt);
				if(child){
					child.parent = obj;
					obj.children.push(child);
				}
			}
			
			return obj;
		}
		
		private function visitA(elt:XML):Object {
			var obj:Object = new Object();
			
			var xlink:Namespace = new Namespace("http://www.w3.org/1999/xlink");
			var link:String = elt.@xlink::href;
			link = StringUtil.ltrim(link, "#");
			
			obj.href = link;
			
			obj.children = new Array();
			for each(var childElt:XML in elt.*) {
				var child:Object = visit(childElt);
				if(child){
					child.parent = obj;
					obj.children.push(child);
				}
			}
			
			return obj;
		}
		
		private function visitDefs(elt:XML):Object {
			for each(var childElt:XML in elt.*) {
				var child:Object = visit(childElt);
				if(child){
					defs[child.id] = child;
				}
			}
			
			return null;
		}
		
		private function visitClipPath(elt:XML):Object {
			var obj:Object = new Object();
			
			obj.children = new Array();
			for each(var childElt:XML in elt.*) {
				var child:Object = visit(childElt);
				if(child){
					child.parent = obj;
					obj.children.push(child);
				}
			}
			
			return obj;
		}
		
		private function visitText(elt:XML):Object {
			var obj:Object = new Object();

			obj.x = ("@x" in elt) ? elt.@x : 0;
			obj.y = ("@y" in elt) ? elt.@y : 0;
			obj.children = new Array();
			for each(var childElt:XML in elt.*) {
				if(childElt.nodeKind() == "text"){
					obj.children.push(SVGParserCommon.CleanUp(childElt.toString()));
				} else if(childElt.nodeKind() == "element"){
					var child:Object = visit(childElt);
					if(child!=null){
						child.parent = obj;
						obj.children.push(child);
					}
				}
			}
			return obj;
		}
		private function visitTspan(elt:XML):Object {
			var obj:Object = new Object();
			obj.text = SVGParserCommon.CleanUp(elt.text().toString());
			obj.x = ("@x" in elt) ? elt.@x : null;
			obj.y = ("@y" in elt) ? elt.@y : null;
			obj.dx = ("@dx" in elt) ? elt.@dx : 0;
			obj.dy = ("@dy" in elt) ? elt.@dy : 0;
			
			return obj;
		}
		
		private function visitImage(elt:XML):Object {
			var obj:Object = new Object();
			obj.x = ("@x" in elt) ? elt.@x : null;
			obj.y = ("@y" in elt) ? elt.@y : null;
			obj.width = ("@width" in elt) ? elt.@width : 0;
			obj.height = ("@height" in elt) ? elt.@height : 0;
			obj.preserveAspectRatio = ("@preserveAspectRatio" in elt) ? elt.@preserveAspectRatio : 0;
			
			var xlink:Namespace = new Namespace("http://www.w3.org/1999/xlink");			
			var href:String = elt.@xlink::href;
			obj.href = StringUtil.trim(href);
			
			return obj;
		}
	}
}