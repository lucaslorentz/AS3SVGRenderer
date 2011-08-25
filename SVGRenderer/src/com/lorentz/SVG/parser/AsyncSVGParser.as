package com.lorentz.SVG.parser
{
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
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.SVGContainer;
	import com.lorentz.SVG.display.base.SVGElement;
	import com.lorentz.SVG.utils.SVGUtil;
	import com.lorentz.SVG.utils.StringUtil;
	import com.lorentz.processing.Process;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class AsyncSVGParser extends EventDispatcher
	{
		public static const COMPLETE:String = "complete";
		
		private var visitQueue:Vector.<VisitDefinition>;
		private var _svg:XML;
		private var _target:SVGDocument;
		private var _process:Process;
		
		public function AsyncSVGParser(target:SVGDocument, svg:XML)
		{
			_target = target;
			_svg = svg;
		}
		
		public function parse():void {
			_target.gradients = SVGParserCommon.parseGradients(_svg);
			
			var stylesObj:Object = SVGParserCommon.parseStyles(_svg);
			for(var selector:String in stylesObj)
				_target.addStyleDeclaration(selector, stylesObj[selector]);
			
			visitQueue = new Vector.<VisitDefinition>();
			visitQueue.push(new VisitDefinition(_svg));
			
			_process = new Process(null, executeLoop, parseComplete);
			_process.start();
		}
		
		public function cancel():void {
			_process.stop();
			_process = null;
		}
		
		private function executeLoop():int {
			visitQueue.unshift.apply(this, visit(visitQueue.shift()));		
			return visitQueue.length == 0 ? Process.COMPLETE : Process.CONTINUE;
		}
		
		private function parseComplete():void {
			dispatchEvent( new Event( COMPLETE ) );
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
			
			//Set document
			if(obj is SVGElement){
				var element:SVGElement = obj as SVGElement;
				
				element.id = elt.@id;
				
				//Save in definitions
				if(element.id != null && element.id != "")
					_target.addDefinition(element.id, element);
				
				SVGUtil.presentationStyleToStyleDeclaration(elt, element.style);
				if("@style" in elt)
					element.style.fromString(elt.@style);
				
				if("@class" in elt)
					element.svgClass = String(elt.@["class"]);
				
				if("@transform" in elt)
					element.svgTransform = SVGParserCommon.parseTransformation(elt.@transform);
				
				if("@clip-path" in elt)
					element.svgClipPath = String(elt["@clip-path"]);
				
				if("@mask" in elt)
					element.svgMask = String(elt["@mask"]);
				
				if(element is ISVGViewBox)
					(element as ISVGViewBox).svgViewBox = SVGParserCommon.parseViewBox(elt.@viewBox);
								
				if(element is SVGContainer){
					var container:SVGContainer = element as SVGContainer;
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
			var obj:SVG = elt == _svg ? _target : new SVG();
			
			if(obj==null)
				obj = new SVG();
			
			obj.svgX = ("@x" in elt) ? elt.@x : null;
			obj.svgY = ("@y" in elt) ? elt.@y : null;
			obj.svgWidth = ("@width" in elt) ? elt.@width : "100%";
			obj.svgHeight = ("@height" in elt) ? elt.@height : "100%";
			obj.svgPreserveAspectRatio = ("@preserveAspectRatio" in elt) ? elt.@preserveAspectRatio : null;
			
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
			var obj:SVGSymbol = new SVGSymbol();
			obj.svgPreserveAspectRatio = ("@preserveAspectRatio" in elt) ? elt.@preserveAspectRatio : null;			
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
							str = SVGParserCommon.cleanUpText(str);
							
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
							str = SVGParserCommon.cleanUpText(str);
							
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
			obj.svgPreserveAspectRatio = ("@preserveAspectRatio" in elt) ? elt.@preserveAspectRatio : null;
			
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
			return obj;
		}
		
		private function visitSwitch(elt:XML):SVGSwitch {
			var obj:SVGSwitch = new SVGSwitch();
			return obj;
		}
		
	}
}