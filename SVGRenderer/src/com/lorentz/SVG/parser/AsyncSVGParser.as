package com.lorentz.SVG.parser
{
	import com.lorentz.SVG.data.filters.ISVGFilter;
	import com.lorentz.SVG.data.filters.SVGColorMatrix;
	import com.lorentz.SVG.data.filters.SVGFilterCollection;
	import com.lorentz.SVG.data.filters.SVGGaussianBlur;
	import com.lorentz.SVG.data.gradients.SVGGradient;
	import com.lorentz.SVG.data.gradients.SVGLinearGradient;
	import com.lorentz.SVG.data.gradients.SVGRadialGradient;
	import com.lorentz.SVG.data.style.StyleDeclaration;
	import com.lorentz.SVG.display.SVG;
	import com.lorentz.SVG.display.SVGA;
	import com.lorentz.SVG.display.SVGCircle;
	import com.lorentz.SVG.display.SVGClipPath;
	import com.lorentz.SVG.display.SVGDocument;
	import com.lorentz.SVG.display.SVGEllipse;
	import com.lorentz.SVG.display.SVGG;
	import com.lorentz.SVG.display.SVGImage;
	import com.lorentz.SVG.display.SVGLine;
	import com.lorentz.SVG.display.SVGMarker;
	import com.lorentz.SVG.display.SVGMask;
	import com.lorentz.SVG.display.SVGPath;
	import com.lorentz.SVG.display.SVGPattern;
	import com.lorentz.SVG.display.SVGPolygon;
	import com.lorentz.SVG.display.SVGPolyline;
	import com.lorentz.SVG.display.SVGRect;
	import com.lorentz.SVG.display.SVGSwitch;
	import com.lorentz.SVG.display.SVGSymbol;
	import com.lorentz.SVG.display.SVGTSpan;
	import com.lorentz.SVG.display.SVGText;
	import com.lorentz.SVG.display.SVGUse;
	import com.lorentz.SVG.display.base.ISVGPreserveAspectRatio;
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.SVGContainer;
	import com.lorentz.SVG.display.base.SVGElement;
	import com.lorentz.SVG.utils.SVGColorUtils;
	import com.lorentz.SVG.utils.SVGUtil;
	import com.lorentz.SVG.utils.StringUtil;
	import com.lorentz.processing.Process;
	
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="complete", type="flash.events.Event")]
	public class AsyncSVGParser extends EventDispatcher
	{
		protected namespace svg = "http://www.w3.org/2000/svg";
		
		private var _visitQueue:Vector.<VisitDefinition>;
		private var _svg:XML;
		private var _target:SVGDocument;
		private var _process:Process;
		
		public function AsyncSVGParser(target:SVGDocument, svg:XML)
		{
			_target = target;
			_svg = svg;
		}
		
		public function parse():void {
			parseStyles(_svg);
			parseGradients(_svg);
			parseFilters(_svg);
			
			_visitQueue = new Vector.<VisitDefinition>();
			_visitQueue.push(new VisitDefinition(_svg, function(obj:SVGElement):void {
				_target.addElement(obj);
			}));
			
			_process = new Process(null, executeLoop, parseComplete);
			_process.start();
		}
		
		public function cancel():void {
			_process.stop();
			_process = null;
		}
		
		private function executeLoop():int {
			_visitQueue.unshift.apply(this, visit(_visitQueue.shift()));		
			return _visitQueue.length == 0 ? Process.COMPLETE : Process.CONTINUE;
		}
		
		private function parseComplete():void {
			dispatchEvent( new Event( Event.COMPLETE ) );
			_process = null;
		}
		
		private function visit(visitDefinition:VisitDefinition):Array {
			var childVisits:Array = [];
			
			var elt:XML = visitDefinition.node;
						
			var obj:Object;
			
			if(elt.nodeKind() == "text"){
				obj = elt.toString();
			} else if(elt.nodeKind() == "element"){
				var localName:String = String(elt.localName()).toLowerCase();
				
				switch(localName) {
					case 'svg': obj = visitSvg(elt); break;
					case 'defs': visitDefs(elt, childVisits); break;
					case 'rect': obj = visitRect(elt); break;
					case 'path': obj = visitPath(elt); break;
					case 'polygon': obj = visitPolygon(elt); break;
					case 'polyline': obj = visitPolyline(elt); break;
					case 'line': obj = visitLine(elt); break;
					case 'circle': obj = visitCircle(elt); break;
					case 'ellipse': obj = visitEllipse(elt); break;
					case 'g': obj = visitG(elt); break;
					case 'clippath': obj = visitClipPath(elt); break;
					case 'symbol' : obj = visitSymbol(elt); break;
					case 'marker' : obj = visitMarker(elt); break;
					case 'mask' : obj = visitMask(elt); break;
					case 'text': obj = visitText(elt, childVisits); break;
					case 'tspan': obj = visitTspan(elt, childVisits); break;
					case 'image' : obj = visitImage(elt); break;
					case 'a' : obj = visitA(elt); break;
					case 'use' : obj = visitUse(elt); break;
					case 'pattern' : obj = visitPattern(elt); break;
					case 'switch' : obj = visitSwitch(elt); break;
				}
			}
			
			if(obj is SVGElement){
				var element:SVGElement = obj as SVGElement;
								
				element.id = elt.@id;
				
				element.metadata = elt.svg::metadata[0];
				
				//Save in definitions
				if(element.id != null && element.id != "")
					_target.addDefinition(element.id, element);
				
				SVGUtil.presentationStyleToStyleDeclaration(elt, element.style);
				if("@style" in elt)
					element.style.fromString(elt.@style);
				
				if("@class" in elt)
					element.svgClass = String(elt["@class"]);
				
				if("@transform" in elt)
					element.svgTransform = String(elt.@transform);
				
				if("@clip-path" in elt)
					element.svgClipPath = String(elt["@clip-path"]);
				
				if("@mask" in elt)
					element.svgMask = String(elt.@mask);
				
				if(element is ISVGPreserveAspectRatio)
					(element as ISVGPreserveAspectRatio).svgPreserveAspectRatio = ("@preserveAspectRatio" in elt) ? elt.@preserveAspectRatio : null; 
				
				if(element is ISVGViewBox)
					(element as ISVGViewBox).svgViewBox = SVGParserCommon.parseViewBox(elt.@viewBox);
								
				if(element is SVGContainer){
					var container:SVGContainer = element as SVGContainer;
					
					if (element is SVGPattern)
					{
						var xlink:Namespace = new Namespace("http://www.w3.org/1999/xlink");
						var link:String = elt.@xlink::href;
						if (link != "")
						{
							(element as SVGPattern).originalPatternHref = link;
							
							if(elt.elements().length() == 0)
								container.addElement(visitUse(elt));
						}
					}
					
					for each(var childElt:XML in elt.elements()) {
						childVisits.push(new VisitDefinition(childElt, function(child:SVGElement):void{
							if(child){
								container.addElement(child);
							}					
						}));
						
					}
				}
			}
			
			if(visitDefinition.onComplete != null)
				visitDefinition.onComplete(obj);
			
			return childVisits;
		}
		
		private function visitSvg(elt:XML):SVG {
			var obj:SVG = new SVG();
			
			obj.svgX = ("@x" in elt) ? elt.@x : null;
			obj.svgY = ("@y" in elt) ? elt.@y : null;
			obj.svgWidth = ("@width" in elt) ? elt.@width : "100%";
			obj.svgHeight = ("@height" in elt) ? elt.@height : "100%";
			
			return obj;
		}
		
		private function visitDefs(elt:XML, childVisits:Array):void {
			for each(var childElt:XML in elt.*) {
				childVisits.push(new VisitDefinition(childElt));
			}
		}
		
		private function visitRect(elt:XML):SVGRect {
			var obj:SVGRect = new SVGRect();
			
			obj.svgX = elt.@x;
			obj.svgY =  elt.@y;
			obj.svgWidth =  elt.@width;
			obj.svgHeight =  elt.@height;
			obj.svgRx =  elt.@rx;
			obj.svgRy =  elt.@ry;
			
			return obj;
		}
		
		private function visitPath(elt:XML):SVGPath {
			var obj:SVGPath = new SVGPath();
			obj.path = SVGParserCommon.parsePathData(elt.@d);
			return obj;
		}
		
		private function visitPolygon(elt:XML):SVGPolygon {
			var obj:SVGPolygon = new SVGPolygon();
			obj.points = SVGParserCommon.splitNumericArgs(elt.@points);
			return obj;
		}
		private function visitPolyline(elt:XML):SVGPolyline {
			var obj:SVGPolyline = new SVGPolyline();
			obj.points = SVGParserCommon.splitNumericArgs(elt.@points);
			return obj;
		}
		private function visitLine(elt:XML):SVGLine {
			var obj:SVGLine = new SVGLine();
			
			obj.svgX1 = elt.@x1;
			obj.svgY1 = elt.@y1;
			
			obj.svgX2 = elt.@x2;
			obj.svgY2 = elt.@y2;
			
			return obj;
		}
		private function visitCircle(elt:XML):SVGCircle {
			var obj:SVGCircle = new SVGCircle();
			
			obj.svgCx = elt.@cx;
			obj.svgCy = elt.@cy;
			
			obj.svgR = elt.@r;
			
			return obj;
		}
		private function visitEllipse(elt:XML):SVGEllipse {
			var obj:SVGEllipse = new SVGEllipse();
			
			obj.svgCx = elt.@cx;
			obj.svgCy = elt.@cy;
			obj.svgRx = elt.@rx;
			obj.svgRy = elt.@ry;
			
			return obj;
		}
		private function visitG(elt:XML):SVGG {
			var obj:SVGG = new SVGG();
			return obj;
		}
		
		private function visitA(elt:XML):SVGA {
			var obj:SVGA = new SVGA();
			
			var xlink:Namespace = new Namespace("http://www.w3.org/1999/xlink");
			var link:String = elt.@xlink::href;
			link = StringUtil.ltrim(link, "#");
			
			obj.svgHref = link;
			
			return obj;
		}
		
		private function visitClipPath(elt:XML):SVGClipPath {
			var obj:SVGClipPath = new SVGClipPath();
			return obj;
		}
		
		private function visitSymbol(elt:XML):SVGSymbol {
			return new SVGSymbol();
		}
		
		private function visitMarker(elt:XML):SVGMarker {
			var obj:SVGMarker = new SVGMarker();
			obj.svgRefX = elt.@refX;
			obj.svgRefY = elt.@refY;
			obj.svgMarkerWidth = elt.@markerWidth;
			obj.svgMarkerHeight = elt.@markerHeight;
			obj.svgOrient = elt.@orient;
						
			return obj;
		}
		
		private function visitMask(elt:XML):SVGMask {
			var obj:SVGMask = new SVGMask();
			return obj;
		}
		
		private function visitText(elt:XML, childVisits:Array):SVGText {
			var obj:SVGText = new SVGText();
			
			obj.svgX = ("@x" in elt) ? elt.@x : "0";
			obj.svgY = ("@y" in elt) ? elt.@y : "0";
			
			var numChildrenToVisit:int = 0;
			var visitNumber:int = 0;
			for each(var childElt:XML in elt.*) {
				numChildrenToVisit++;
				childVisits.push(new VisitDefinition(childElt, function(child:Object):void{
					if(child){
						if(child is String){
							var str:String = child as String;
							str = SVGUtil.prepareXMLText(str);
							
							if(visitNumber == 0)
								str = StringUtil.ltrim(str);
							else if(visitNumber == numChildrenToVisit - 1)
								str = StringUtil.rtrim(str);
							
							if(StringUtil.trim(str) != "") {
								obj.addTextElement(str);
							}
						} else {
							obj.addTextElement(child);
						}
					}
					visitNumber++;
				}));
			}
			return obj;
		}
		
		private function visitTspan(elt:XML, childVisits:Array):SVGTSpan {
			var obj:SVGTSpan = new SVGTSpan();
			obj.svgX = ("@x" in elt) ? elt.@x : null;
			obj.svgY = ("@y" in elt) ? elt.@y : null;
			obj.svgDx = ("@dx" in elt) ? elt.@dx : "0";
			obj.svgDy = ("@dy" in elt) ? elt.@dy : "0";
			
			var numChildrenToVisit:int = 0;
			var visitNumber:int = 0;
			for each(var childElt:XML in elt.*) {
				numChildrenToVisit++;
				childVisits.push(new VisitDefinition(childElt, function(child:Object):void{
					if(child){
						if(child is String){
							var str:String = child as String;
							str = SVGUtil.prepareXMLText(str);
							
							if(StringUtil.trim(str) != "") {
								obj.addTextElement(str);
							}
						} else {
							obj.addTextElement(child);
						}
					}
					visitNumber++;
				}));
			}
			
			return obj;
		}
		
		private function visitImage(elt:XML):SVGImage {
			var obj:SVGImage = new SVGImage();
			obj.svgX = ("@x" in elt) ? elt.@x : null;
			obj.svgY = ("@y" in elt) ? elt.@y : null;
			obj.svgWidth = ("@width" in elt) ? elt.@width : null;
			obj.svgHeight = ("@height" in elt) ? elt.@height : null;
			
			var xlink:Namespace = new Namespace("http://www.w3.org/1999/xlink");			
			var href:String = elt.@xlink::href;
			obj.svgHref = StringUtil.trim(href);
			
			return obj;
		}
		
		private function visitUse(elt:XML):SVGUse {
			var obj:SVGUse = new SVGUse();
			obj.svgX = ("@x" in elt) ? elt.@x : null;
			obj.svgY = ("@y" in elt) ? elt.@y : null;
			obj.svgWidth = ("@width" in elt) ? elt.@width : null;
			obj.svgHeight = ("@height" in elt) ? elt.@height : null;
			
			var xlink:Namespace = new Namespace("http://www.w3.org/1999/xlink");			
			var href:String = elt.@xlink::href;
			obj.svgHref = StringUtil.trim(href);
			
			return obj;
		}
		
		private function visitPattern(elt:XML):SVGPattern {
			var obj:SVGPattern = new SVGPattern();
			obj.svgX = ("@x" in elt) ? elt.@x : null;
			obj.svgY = ("@y" in elt) ? elt.@y : null;
			obj.svgWidth = ("@width" in elt) ? elt.@width : null;
			obj.svgHeight = ("@height" in elt) ? elt.@height : null;
			obj.patternTransform = ("@patternTransform" in elt) ? elt.@patternTransform : null;
			return obj;
		}
		
		private function visitSwitch(elt:XML):SVGSwitch {
			var obj:SVGSwitch = new SVGSwitch();
			return obj;
		}
		
		private function parseStyles(elt:XML):void {
			var stylesTexts:XMLList = (elt..*::style.text());
			
			for each(var styleString:String in stylesTexts){
				var content:String = SVGUtil.prepareXMLText(styleString);
				
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
							_target.addStyleDeclaration(n, StyleDeclaration.createFromString(style_text));
						}
					}
				}
			}
		}
				
		private function parseGradients(svg:XML):void {
			var nodes:XMLList = svg..*::*;
			for each(var node:XML in nodes){
				if(node && (String(node.localName()).toLowerCase()=="lineargradient"||String(node.localName()).toLowerCase()=="radialgradient")){
					parseGradient(node.@id, svg);
				}
			}
		}
		
		private function parseGradient(id:String, svg:XML):SVGGradient {
			id = StringUtil.ltrim(id, "#");
			
			if(_target.hasDefinition(id))
				return _target.getDefinition(id) as SVGGradient;
			
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
			
			//Inherits the href reference
			var xlink:Namespace = new Namespace("http://www.w3.org/1999/xlink");
			if(xml_grad.@xlink::href.length() > 0){
				var baseGradient:SVGGradient = parseGradient(xml_grad.@xlink::href, svg);
				if(baseGradient)
					baseGradient.copyTo(grad);
			}
			//
			
			if("@gradientUnits" in xml_grad)
				grad.gradientUnits = xml_grad.@gradientUnits;
			else
				grad.gradientUnits = "objectBoundingBox";
			
			if("@gradientTransform" in xml_grad)
				grad.transform = SVGParserCommon.parseTransformation(xml_grad.@gradientTransform);
			
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
			_target.addDefinition(id, grad);
			
			return grad;
		}
		
		private function parseFilters(svg:XML):void
		{
			var nodes:XMLList = svg..*::*;
			for each(var node:XML in nodes){
				if(node && (String(node.localName()).toLowerCase()=="filter")){
					parseFilterCollection(node);
				}
			}
		}
		
		private function parseFilterCollection(node:XML):void {			
			var filterCollection:SVGFilterCollection = new SVGFilterCollection();
			for each(var childNode:XML in node.elements()){
				var filter:ISVGFilter = parseFilter(childNode);
				if(filter)
					filterCollection.svgFilters.push(filter);
			}
			
			var id:String = StringUtil.ltrim(node.@id, "#");
			_target.addDefinition(id, filterCollection);
		}
		
		private function parseFilter(node:XML):ISVGFilter {
			var localName:String = String(node.localName()).toLowerCase();
			
			switch(localName)
			{
				case "fegaussianblur" : return parseFilterGaussianBlur(node);
				case "fecolormatrix" : return parseFilterColorMatrix(node);
			}
			
			return null;
		}
		
		private function parseFilterGaussianBlur(node:XML):SVGGaussianBlur {
			var obj:SVGGaussianBlur = new SVGGaussianBlur();
			
			if(("@stdDeviation" in node))
			{	
				var parts:Array = String(node.@stdDeviation).split(/\s,/);
				obj.stdDeviationX = Number(parts[0]);
				obj.stdDeviationY = parts.length > 1 ? Number(parts[1]) : Number(parts[0]);
			}
			
			return obj;
		}
		
		private function parseFilterColorMatrix(node:XML):SVGColorMatrix {
			var obj:SVGColorMatrix = new SVGColorMatrix();
			
			obj.type = ("@type" in node) ? node.@type : "matrix";
			
			var valuesString:String = ("@values" in node) ? node.@values : "";
			var values:Array = [];
			for each(var v:String in SVGParserCommon.splitNumericArgs(valuesString)){
				values.push(Number(v));
			}
			obj.values = values;
			return obj;
		}
	}
}