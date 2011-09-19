package com.lorentz.SVG.parser {
	import com.lorentz.SVG.data.gradients.SVGGradient;
	import com.lorentz.SVG.data.gradients.SVGLinearGradient;
	import com.lorentz.SVG.data.gradients.SVGRadialGradient;
	import com.lorentz.SVG.data.path.SVGArcToCommand;
	import com.lorentz.SVG.data.path.SVGClosePathCommand;
	import com.lorentz.SVG.data.path.SVGCurveToCubicCommand;
	import com.lorentz.SVG.data.path.SVGCurveToCubicSmoothCommand;
	import com.lorentz.SVG.data.path.SVGCurveToQuadraticCommand;
	import com.lorentz.SVG.data.path.SVGCurveToQuadraticSmoothCommand;
	import com.lorentz.SVG.data.path.SVGLineToCommand;
	import com.lorentz.SVG.data.path.SVGLineToHorizontalCommand;
	import com.lorentz.SVG.data.path.SVGLineToVerticalCommand;
	import com.lorentz.SVG.data.path.SVGMoveToCommand;
	import com.lorentz.SVG.data.path.SVGPathCommand;
	import com.lorentz.SVG.data.style.StyleDeclaration;
	import com.lorentz.SVG.utils.MathUtils;
	import com.lorentz.SVG.utils.SVGColorUtils;
	import com.lorentz.SVG.utils.SVGUtil;
	import com.lorentz.SVG.utils.StringUtil;
	
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class SVGParserCommon {
		public static function parsePathData(input:String):Vector.<com.lorentz.SVG.data.path.SVGPathCommand> {			
			var commands:Vector.<com.lorentz.SVG.data.path.SVGPathCommand> = new Vector.<com.lorentz.SVG.data.path.SVGPathCommand>();
			
			for each(var commandString:String in input.match(/[A-DF-Za-df-z][^A-Za-df-z]*/g)){
				var type:String = commandString.charAt(0);
				var args:Vector.<String> = SVGParserCommon.splitNumericArgs(commandString.substr(1));
				
				if(type == "Z" || type == "z"){
					commands.push(new SVGClosePathCommand());
					continue;
				}
				
				var a:int = 0;
				while (a<args.length){
					if(type=="M" && a>0) //Subsequent pairs of coordinates are treated as implicit lineto commands
						type = "L";
					if(type=="m" && a>0) //Subsequent pairs of coordinates are treated as implicit lineto commands
						type = "l";
					
					switch (type) {
						case "M" : 
						case "m" : 
							commands.push(new SVGMoveToCommand(type=="M", Number(args[a++]), Number(args[a++])));
							break;
						case "L" :
						case "l" :
							commands.push(new SVGLineToCommand(type=="L", Number(args[a++]), Number(args[a++])));
							break;
						case "H" :
						case "h" :
							commands.push(new SVGLineToHorizontalCommand(type=="H", Number(args[a++])));
							break;
						case "V" :
						case "v" :
							commands.push(new SVGLineToVerticalCommand(type=="V", Number(args[a++])));
							break;
						case "Q" :
						case "q" :
							commands.push(new SVGCurveToQuadraticCommand(type=="Q", Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++])));
							break;
						case "T" :
						case "t" :
							commands.push(new SVGCurveToQuadraticSmoothCommand(type=="T", Number(args[a++]), Number(args[a++])));
							break;
						case "C" :
						case "c" :
							commands.push(new SVGCurveToCubicCommand(type=="C", Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++])));
							break;
						
						case "S" :
						case "s" :
							commands.push(new SVGCurveToCubicSmoothCommand(type=="S", Number(args[a++]), Number(args[a++]), Number(args[a++]), Number(args[a++])));
							break;
						
						case "A" :
						case "a" :
							commands.push(new SVGArcToCommand(type=="A", Number(args[a++]), Number(args[a++]), Number(args[a++]), args[a++]!="0", args[a++]!="0", Number(args[a++]), Number(args[a++])));
							break;	
						
						default : trace("Invalid PathCommand type: " + type);
							a = args.length; //Break args loop
					}
				}
			}
			
			return commands; 
		}
		
		public static function splitNumericArgs(input:String):Vector.<String> {
			var returnData:Vector.<String> = new Vector.<String>();
						
			var matchedNumbers:Array = input.match(/(?:\+|-)?\d+(?:\.\d+)?(?:e(?:\+|-)?\d+)?/g);
			for each(var numberString:String in matchedNumbers){
				returnData.push(numberString);
			}
			
			return returnData;
		}
		
		public static function cleanUpText(s:String):String
		{
			s = s.replace(/\r|\t|\n|\&\#xA;|\&\#xD;/g, "");
			s = s.replace(/\&nbsp;/g, " ");
			s = s.replace(/\s+/g, " ");
			return s;
		}
		
		public static function parseTransformation(m:String):Matrix {
			if(m.length == 0) {
				return new Matrix();
			}
			
			var transformations:Array = m.match(/(\w+?\s*\([^)]*\))/g);
			
			var mat:Matrix = new Matrix();
			
			if(transformations is Array){
				for(var i:int = transformations.length - 1; i >= 0; i--)
				{
					var parts:Array = /(\w+?)\s*\(([^)]*)\)/.exec(transformations[i]);
					if(parts is Array){
						var name:String = parts[1].toLowerCase();
						var args:Vector.<String> = splitNumericArgs(parts[2]);
						
						if(name=="matrix"){
							return new Matrix(Number(args[0]), Number(args[1]), Number(args[2]), Number(args[3]), Number(args[4]), Number(args[5]));
						}
						
						switch(name){
							case "translate" :
								mat.translate(Number(args[0]), args.length > 1 ? Number(args[1]) : Number(args[0]));
								break;
							case "scale" :
								mat.scale(Number(args[0]), args.length > 1 ? Number(args[1]) : Number(args[0]));
								break;
							case "rotate" :
								if(args.length > 1){
									var tx:Number = args.length > 1 ? Number(args[1]) : 0;
									var ty:Number = args.length > 2 ? Number(args[2]) : 0;
									mat.translate(-tx, -ty);
									mat.rotate(MathUtils.degressToRadius(Number(args[0])));
									mat.translate(tx, ty);
								} else {
									mat.rotate(MathUtils.degressToRadius(Number(args[0])));
								}
								break;
							case "skewx" :
								var skewXMatrix:Matrix = new Matrix();
								skewXMatrix.c = Math.tan(MathUtils.degressToRadius(Number(args[0])));
								mat.concat(skewXMatrix);
								break;
							case "skewy" :
								var skewYMatrix:Matrix = new Matrix();
								skewYMatrix.b = Math.tan(MathUtils.degressToRadius(Number(args[0])));
								mat.concat(skewYMatrix);
								break;
						}
					}
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
			
			var stylesTexts:XMLList = (elt..*::style.text());
			
			for each(var styleString:String in stylesTexts){
				var content:String = cleanUpText(styleString);
				
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
							result[n] = StyleDeclaration.createFromString(style_text);
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
		private static function parseGradient(id:String, svg:XML, storeObject:Object):SVGGradient {
			id = StringUtil.ltrim(id, "#");
			
			if(storeObject[id]!=null)
				return storeObject[id];
						
			var xml_grad:XML = svg..*.(attribute("id")==id)[0];
			
			if(xml_grad == null)
				return null;
			
			var grad:SVGGradient;
			
			switch(xml_grad.localName().toLowerCase()){
				case "lineargradient": 
					grad = new SVGLinearGradient(); break;
				case "radialgradient" :
					grad = new SVGRadialGradient(); break;
			}
			
			//inherits the href reference
			var xlink:Namespace = new Namespace("http://www.w3.org/1999/xlink");
			if(xml_grad.@xlink::href.length()>0){
				var baseGradient:SVGGradient = parseGradient(xml_grad.@xlink::href, svg, storeObject);
				baseGradient.copyTo(grad);
			}
			//
			
			if("@gradientUnits" in xml_grad)
				grad.gradientUnits = xml_grad.@gradientUnits;
			else
				grad.gradientUnits = "objectBoundingBox";
			
			if("@gradientTransform" in xml_grad)
				grad.transform = parseTransformation(xml_grad.@gradientTransform);
			
			switch(grad.type){
				case GradientType.LINEAR : {
					var linearGrad:SVGLinearGradient = grad as SVGLinearGradient;
					
					if("@x1" in xml_grad)
						linearGrad.x1 = xml_grad.@x1;
					else if(linearGrad.x1 == null)
						linearGrad.x1 = "0%";
					
					if("@y1" in xml_grad)
						linearGrad.y1 = xml_grad.@y1;
					else if(linearGrad.y1 == null)
						linearGrad.y1 = "0%";
					
					if("@x2" in xml_grad)
						linearGrad.x2 = xml_grad.@x2;
					else if(linearGrad.x2 == null)
						linearGrad.x2 = "100%";
					
					if("@y2" in xml_grad)
						linearGrad.y2 = xml_grad.@y2;
					else if(linearGrad.y2 == null)
						linearGrad.y2 = "0%";

					break;
				}
				case GradientType.RADIAL : {
					var radialGrad:SVGRadialGradient = grad as SVGRadialGradient;
					
					if("@cx" in xml_grad)
						radialGrad.cx = xml_grad.@cx;
					else if(radialGrad.cx==null)
						radialGrad.cx = "50%";
					
					if("@cy" in xml_grad)
						radialGrad.cy = xml_grad.@cy;
					else if(radialGrad.cy==null)
						radialGrad.cy = "50%";
					
					if("@r" in xml_grad)
						radialGrad.r = xml_grad.@r;
					else if(radialGrad.r == null)
						radialGrad.r = "50%";
					
					if("@fx" in xml_grad)
						radialGrad.fx = xml_grad.@fx;
					else if(radialGrad.fx==null)
						radialGrad.fx = radialGrad.cx;
					
					if("@fy" in xml_grad)
						radialGrad.fy = xml_grad.@fy;
					else if(radialGrad.fy==null)
						radialGrad.fy = radialGrad.cy;
					
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
				var stopStyle:StyleDeclaration = new StyleDeclaration();
				
				if("@stop-opacity" in stop)
					stopStyle.setProperty("stop-opacity", stop.@["stop-opacity"]);
				
				if("@stop-color" in stop)
					stopStyle.setProperty("stop-color", stop.@["stop-color"]);
				
				if("@style" in stop){
					stopStyle.fromString(stop.@style);
				}
				
				grad.colors.push( SVGColorUtils.parseToUint(stopStyle.getPropertyValue("stop-color")) );
				grad.alphas.push( stopStyle.getPropertyValue("stop-opacity" ) != null ? Number(stopStyle.getPropertyValue("stop-opacity")) : 1 );
				
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