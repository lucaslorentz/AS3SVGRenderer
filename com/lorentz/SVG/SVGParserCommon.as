package com.lorentz.SVG {
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class SVGParserCommon {
		
		public static function parsePathData(input:String):Array { 
			var returnData:Array=new Array(); 
			var pointString:String=new String(); 
			var array_position:int=-1;
			input = CleanUp(input);
			for (var count:Number=0;count<input.length;count++) { 
				var c:String = input.charAt(count);
				var code:Number=input.charCodeAt(count); 
				if (code>=65 && c.toLowerCase()!="e") {//is a letter, not exponential number
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

			var last_char:String = "";
			var cur_char:String = null;
			var cur_arg:String = "";
			var i:int = 0;
			while(i<input.length){
				cur_char = input.charAt(i);
				if(cur_char=="-" && last_char.toLowerCase()!="e"){
					if(cur_arg!="")
						returnData.push(cur_arg);
					cur_arg = cur_char;
				} else if(cur_char=="," || cur_char==" " || cur_char=="\t" || cur_char=="\r" || cur_char=="\n"){
					if(cur_arg!="")
						returnData.push(cur_arg);
					cur_arg = "";
				} else {
					cur_arg+=cur_char;
				}
				last_char = cur_char;
				i++;
			}
			if(cur_arg!=="")
				returnData.push(cur_arg);

			return (returnData); 
		}
		
				
		public static function CleanUp(s:String):String
        {
            var temp:String = StringUtil.replace(s,"\r", " ");
            temp = StringUtil.replace(temp,"\t", " ");
            temp = StringUtil.replace(temp,"\n", " ");
			temp = StringUtil.replace(temp, "&#xA", "");
			temp = StringUtil.replace(temp, "&nbsp;", " ");
			temp = StringUtil.shrinkSequencesOf(temp, " ");
            return temp;
        }
		
		public static function parseTransformation(m:String):Matrix {
			if(m.length == 0) {
				return new Matrix();
			}
			
			var fix_m:String = StringUtil.rtrim(m, ")");
			var att_array:Array = fix_m.split(")");

			var mat:Matrix = new Matrix();
			mat.identity();
			for each(var att:String in att_array){
				var name:String = StringUtil.trim(att.split("(")[0]).toLowerCase();

				var args:Array = parseArgsData(att.split("(")[1]);
				
				if(name=="matrix"){
					return new Matrix(Number(args[0]), Number(args[1]), Number(args[2]), Number(args[3]), Number(args[4]), Number(args[5]));
				}

				switch(name){
					case "translate": mat.translate(Number(args[0]), args[1]!=null? Number(args[1]) : Number(args[0])); break;
					case "scale" 	: mat.scale(Number(args[0]),args[1]!=null ? Number(args[1]):Number(args[0])); break;
					case "rotate"	: MatrixTransformer.rotateAroundInternalPoint(mat, args[1]!=null?Number(args[1]):0 ,args[2]!=null?Number(args[2]):0, Number(args[0])); break;
					case "skewx" 	: MatrixTransformer.setSkewX(mat, args[0]); break;
					case "skewy" 	: MatrixTransformer.setSkewY(mat, args[0]); break;
				}
			}
			return mat;
		}
		
		public static function parseViewBox(viewBox:String):Rectangle {
			if(viewBox == null || viewBox == "") {
				return null;
			}
			var params:Object = viewBox.split(/\s/);
			return new Rectangle(params[0], params[1], params[2], params[3]);
		}
		
		public static function parseStyles(elt:XML):Object {
			var result:Object = {};
			
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
		
		public static function parseGradients(svg:XML):Object{
			var result:Object = {};
			
			var nodes:XMLList = svg..*::*.(localName().toLowerCase()=="lineargradient" || localName().toLowerCase()=="radialgradient");
			for each(var node:XML in nodes){
				parseGradient(node.@id, svg, result);
			}
			
			return result;
		 }
		private static function parseGradient(id:String, svg:XML, storeObject:Object):Object{
			id = StringUtil.ltrim(id, "#");
			
			if(storeObject[id]!=null)
				return storeObject[id];
				
			var grad:Object;
			
			var xml_grad:XML = svg..*.(attribute("id")==id)[0];

			//inherits the href reference
			var xlink:Namespace = new Namespace("http://www.w3.org/1999/xlink");
			if(xml_grad.@xlink::href.length()>0){
				grad = parseGradient(xml_grad.@xlink::href, svg, storeObject);
			}
			//
			
			if(grad==null)
				grad = new Object();
				
			if("@gradientUnits" in xml_grad)
				grad.gradientUnits = xml_grad.@gradientUnits;
			else
				grad.gradientUnits = "objectBoundingBox";
				
			if("@gradientTransform" in xml_grad)
				grad.transform = parseTransformation(xml_grad.@gradientTransform);

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
					stop_style = SVGUtil.mergeObjects(stop_style, SVGUtil.styleToObject(stop.@style));
			
				grad.colors.push( SVGColor.parseToInt(stop_style["stop-color"]) );
				grad.alphas.push( stop_style["stop-opacity"]!=null ? Number(stop_style["stop-opacity"]) : 1 );
				
				var offset:Number = Number(StringUtil.rtrim(stop.@offset, "%"));
				if(String(stop.@offset).indexOf("%") > -1){
					offset/=100;
				}
				grad.ratios.push( offset*255 );
			}

			//Save the gradient definition
			storeObject[id] = grad;
			//
			
			return grad;
		}
	}
}