package com.lorentz.SVG {
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	
	import com.lorentz.SVG.StringUtil;
	
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	import com.lorentz.SVG.PathCommand;
	
	public class SVGParser {
		private var svg:XML;
		private var svg_object:Object;
		private var defs:Object = new Object();
		
		public function SVGParser(svg:XML){
			this.svg = svg;
		}
		
		public function parse(){
			svg_object = visit(svg);
			svg_object.svg = svg;
			svg_object.defs = defs;
			
			parseGradients();
			
			return svg_object;
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
				
				case 'use':
				obj = visitUse(elt);
				break;
			}
			
			if(obj==null)
				return null;
			
			if(obj.type == null)
				obj.type = elt.localName();
				
			obj.id = elt.@id;
			
			obj.style = SVGUtil.presentationStyleToObject(elt);
			if("@style" in elt){
				obj.style = SVGUtil.mergeObjectStyles(obj.style, SVGUtil.styleToObject(elt.@style));
			}
			
			if("@class" in elt){
				obj["class"] = String(elt.@["class"]);
			}
			
			if("@transform" in elt)
				obj.transform = parseTransformation(elt.@transform);
			
			return obj;
		}
		private var currentViewBox:Object;
		
		private function visitSvg(elt:XML):Object {
			var obj:Object = new Object();
			obj.viewBox = parseViewBox(elt.@viewBox);

			currentViewBox = obj.viewBox;
			
			obj.styles = parseStyles(elt);
			
			if("@width" in elt)
				obj.width =  elt.@width;
			
			if("@height" in elt)
				obj.height = elt.@height;
			
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
			
			/*
			obj.x = Number(elt.@x);
			obj.y =  Number(elt.@y);
			obj.width =  Number(elt.@width);
			obj.height =  Number(elt.@height);
			obj.rx =  Number(elt.@rx);
			obj.ry =  Number(elt.@ry);
			*/
			
			obj.x = elt.@x;
			obj.y =  elt.@y;
			obj.width =  elt.@width;
			obj.height =  elt.@height;
			obj.rx =  elt.@rx;
			obj.ry =  elt.@ry;

//			obj.isRound = obj.rx != 0 || obj.ry != 0;
			obj.isRound = (obj.rx != null || obj.ry != null);
			if (obj.isRound) {
				obj.rx = (obj.ry != 0 && obj.rx == 0)?obj.ry:obj.rx;
				obj.ry = (obj.rx != 0 && obj.ry == 0)?obj.rx:obj.ry;
			}
			
			return obj;
		}
		
		private function visitPath(elt:XML):Object {
			var obj:Object = new Object();
			
			obj.d = parsePathData(elt.@d);
			
			return obj;
		}
		
		private function visitPolygon(elt:XML):Object {
			var obj:Object = new Object();
			obj.points = parseArgsData(elt.@points);

			return obj;
		}
		private function visitPolyline(elt:XML):Object {
			var obj:Object = new Object();
			obj.points = parseArgsData(elt.@points);

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
		
		private function visitDefs(elt:XML):Object {
			for each(var childElt:XML in elt.*) {
				var child:Object = visit(childElt);
				if(child){
					defs[child.id] = child;
				}
			}
			
			return null;
		}
		
		private function visitClipPath(elt:XML):Sprite {
			return null;
		}

		private function visitUse(elt:XML):Object {
			var xlink:Namespace = new Namespace("http://www.w3.org/1999/xlink");			
			var link:String = elt.@xlink::href;
			link = StringUtil.ltrim(link, "#");
			return defs[link];
		}
		
		public function parsePathData(input:String):Array { 
			var returnData:Array=new Array(); 
			var pointString:String=new String(); 
			var array_position:int=-1;
			input = CleanUp(input);
			for (var count:Number=0;count<input.length;count++) { 
				var code:Number=input.charCodeAt(count); 
				if (code>=65) {//is a letter
					//update the points of last inserted pathObject
					if(array_position>=0)
						returnData[array_position].args=parseArgsData(pointString); 
				
					var pathObject:PathCommand = new PathCommand(); 
					pathObject.type=input.charAt(count);
					returnData.push(pathObject); 
					array_position++;

					pointString=''; 
					//trace ('creating type: '+pathObject.type) 
				} else { 
					pointString+=input.charAt(count); 
				}
			}
			
			if(array_position>=0)
				returnData[array_position].args=parseArgsData(pointString); //update the last pathObject
				
			return(returnData); 
		}
		
		public static function parseArgsData(input:String):Array { 
			var returnData:Array=new Array(); 
			
			var inputString:String = StringUtil.replace(input,"-",",-");
			inputString = StringUtil.replace(inputString," ",",");
			inputString = StringUtil.shrinkSequencesOf(inputString,",");
			
			inputString = StringUtil.trim(inputString, ",");
			

			var argsArray:Array = inputString.split(",");
			
			for (var i:int=0; i<argsArray.length; i++) { 
				if(argsArray[i].length>0)
					returnData.push(Number(argsArray[i]));
			}

			return (returnData); 
		}
		
		public function parseStyles(elt:XML):Object {
			var result:Object = new Object();
			
			for each(var style_str:String in elt..*::style.text()){
				var content:String = CleanUp(style_str);
	
				var parts:Array = content.split("}");
				for each (var s:String in parts)
				{
					s = StringUtil.trim(s);
					if (s.indexOf("{") > -1)
					{
					   var subparts:Array = s.split("{");
					   
					   var names:Array = StringUtil.trim(subparts[0]).split(" ");
					   for each(var n:String in names){
						   var style_text:String = StringUtil.trim(subparts[1]);
						   result[n] = SVGUtil.styleToObject(style_text);
					   }
					}
				}
			}
			return result;
		}
		
		private function CleanUp(s:String):String
        {
            var temp:String = StringUtil.replace(s,"\r", "");
            temp = StringUtil.replace(temp,"\t", "");
            temp = StringUtil.replace(temp,"\n", "");
			temp = StringUtil.replace(temp, "&#xA", "");
			temp = StringUtil.replace(temp, "&nbsp;", " ");
            return temp;
        }
		
		public function parseTransformation(m:String):Matrix {
			if(m.length == 0) {
				return new Matrix();
			}
			
			var fix_m:String = StringUtil.rtrim(m, ")");
			var att_array:Array = fix_m.split(")");

			var mat:Matrix = new Matrix();
			mat.identity();
			for each(var att:String in att_array){
				var name:String = StringUtil.trim(att.split("(")[0]).toLowerCase();

				var args:Array = SVGParser.parseArgsData(att.split("(")[1]);
				
				if(name=="matrix"){
					return new Matrix(args[0], args[1], args[2], args[3], Number(args[4]), Number(args[5]));
				}

				import fl.motion.MatrixTransformer;
				switch(name){
					case "translate": mat.translate(Number(args[0]), args[1]!=null? Number(args[1]) : Number(args[0])); break;
					case "scale" 	: MatrixTransformer.setScaleX(mat, Number(args[0])); MatrixTransformer.setScaleY(mat, args[1]!=null ? Number(args[1]):Number(args[0])); break;
					case "rotate"	: MatrixTransformer.rotateAroundInternalPoint(mat, args[1]!=null?Number(args[1]):0 ,args[2]!=null?Number(args[2]):0, Number(args[0])); break;
					case "skewx" 	: MatrixTransformer.setSkewX(mat, -args[0]); break;
					case "skewy" 	: MatrixTransformer.setSkewY(mat, args[0]); break;
				}
			}
			return mat;
		}
		
		public function parseViewBox(viewBox:String):Rectangle {
			if(viewBox == null || viewBox == "") {
				return new Rectangle(0,0,500,500);
			}
			var params:Object = viewBox.split(/\s/);
			return new Rectangle(params[0], params[1], params[2], params[3]);
		}

		 private function parseGradients():void{
			svg_object.gradients = new Object();
			
			var nodes:XMLList = svg..*::*.(localName().toLowerCase()=="lineargradient" || localName().toLowerCase()=="radialgradient");
			for each(var node:XML in nodes){
				parseGradient(node.@id);
			}
		 }
		private function parseGradient(id:String):Object{
			id = StringUtil.ltrim(id, "#");
			
			if(svg_object.gradients[id]!=null)
				return svg_object.gradients[id];
				
			var grad:Object;
			
			var xml_grad:XML = svg..*.(attribute("id")==id)[0];

			//inherits the href reference
			var xlink:Namespace = new Namespace("http://www.w3.org/1999/xlink");
			if(xml_grad.@xlink::href.length()>0){
				grad = parseGradient(xml_grad.@xlink::href);
			}
			//
			
			if(grad==null)
				grad = new Object();
				
			if("@gradientUnits" in xml_grad)
				grad.gradientUnits = xml_grad.@gradientUnits;
			else
				grad.gradientUnits = "objectBoundingBox";
				

			switch(xml_grad.localName().toLowerCase()){
				case "lineargradient": {
					if("@x1" in xml_grad)
						grad.x1 = xml_grad.@x1;
					else if(grad.x1 == null)
						grad.x1 = "0%";
						
					if("@y1" in xml_grad)
						grad.y1 = xml_grad.@y1;
					else if(grad.y1 == null)
						grad.y1 = "0%";
						
					if("@x2" in xml_grad)
						grad.x2 = xml_grad.@x2;
					else if(grad.x2 == null)
						grad.x2 = "100%";
						
					if("@y2" in xml_grad)
						grad.y2 = xml_grad.@y2;
					else if(grad.y2 == null)
						grad.y2 = "0%";
				
					grad.type = GradientType.LINEAR;
					break;
				}
				case "radialgradient": {
					if("@cx" in xml_grad)
						grad.cx = xml_grad.@cx;
					else if(grad.cx==null)
						grad.cx = "50%";
						
					if("@cy" in xml_grad)
						grad.cy = xml_grad.@cy;
					else if(grad.cy==null)
						grad.cy = "50%";
						
					if("@r" in xml_grad)
						grad.r = xml_grad.@r;
					else if(grad.r == null)
						grad.r = "50%";
						
					if("@fx" in xml_grad)
						grad.fx = xml_grad.@fx;
					else if(grad.fx==null)
						grad.fx = grad.cx;
						
					if("@fy" in xml_grad)
						grad.fy = xml_grad.@fy;
					else if(grad.fy==null)
						grad.fy = grad.cy;

					grad.type = GradientType.RADIAL;

					break;
				}
			}
			
			switch(xml_grad.@spreadMethod){
				case "pad" : grad.spreadMethod = SpreadMethod.PAD; break;
				case "reflect" : grad.spreadMethod = SpreadMethod.REFLECT; break;
				case "repeat" : grad.spreadMethod = SpreadMethod.REPEAT; break;
				default: grad.spreadMethod = SpreadMethod.PAD; break
			}

			if(grad.colors == null)
				grad.colors = new Array();
			
			if(grad.alphas==null)
				grad.alphas = new Array();
				
			if(grad.ratios==null)
				grad.ratios = new Array();
			
			for each(var stop:XML in xml_grad.*::stop){
				var stop_style:Object = new Object();
				
				if("@stop-opacity" in stop)
					stop_style["stop-opacity"] = stop.@["stop-opacity"];
					
				if("@stop-color" in stop)
					stop_style["stop-color"] = stop.@["stop-color"];
					
				if("@style" in stop)
					stop_style = SVGUtil.mergeObjectStyles(stop_style, SVGUtil.styleToObject(stop.@style));
			
				grad.colors.push( SVGColor.parseToInt(stop_style["stop-color"]) );
				grad.alphas.push( stop_style["stop-opacity"]!=null ? Number(stop_style["stop-opacity"]) : 1 );
				
				var offset:Number = Number(StringUtil.rtrim(stop.@offset, "%"));
				if(String(stop.@offset).indexOf("%") > -1){
					offset/=100;
				}
				grad.ratios.push( offset*255 );
			}

			//Save the gradient definition
			svg_object.gradients[id] = grad;
			//
			
			return grad;
		}
	}
}