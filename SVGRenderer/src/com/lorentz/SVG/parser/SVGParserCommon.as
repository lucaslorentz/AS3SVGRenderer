package com.lorentz.SVG.parser {
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
	import com.lorentz.SVG.utils.MathUtils;
	
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
						
			var matchedNumbers:Array = input.match(/(?:\+|-)?(?:(?:\d*\.\d+)|(?:\d+))(?:e(?:\+|-)?\d+)?/g);
			for each(var numberString:String in matchedNumbers){
				returnData.push(numberString);
			}
			
			return returnData;
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

						switch(name){
							case "matrix" :
								mat.concat(new Matrix(Number(args[0]), Number(args[1]), Number(args[2]), Number(args[3]), Number(args[4]), Number(args[5])));
								break;
							case "translate" :
								mat.translate(Number(args[0]), args.length > 1 ? Number(args[1]) : 0);
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
		
		public static function parsePreserveAspectRatio(text:String):Object {
			var parts:Array = /(?:(defer)\s+)?(\w*)(?:\s+(meet|slice))?/gi.exec(text.toLowerCase());					
			
			return {
				defer: parts[1] != undefined,
				align: parts[2] || "xmidymid",
				meetOrSlice: parts[3] || "meet"
			};
		}
	}
}