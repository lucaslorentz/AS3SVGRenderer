package com.lorentz.SVG.display {
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import com.lorentz.SVG.SVGUtil;
	import com.lorentz.SVG.SVGParserCommon;
	import com.lorentz.SVG.StringUtil;
	import com.lorentz.SVG.PathCommand;
	import com.lorentz.SVG.SVGColor;
	import com.lorentz.SVG.MatrixTransformer;
	
	public class SVGDocument extends SVG {	
		protected var _svg:XML;
				
		public var defs:Object = {};
		public var styles:Object = {};
		public var gradients:Object = {};
		
		public var baseURL:String;
		
		public function SVGDocument(){			
			super();
		}
				
		public function parse(svg:XML):void {			
			clear();
			
			_svg = svg;
			
			gradients = SVGParserCommon.parseGradients(_svg);
			styles = SVGParserCommon.parseStyles(_svg);
						
			visit(_svg, this);
			
			invalidate();
		}
		
		public function clear():void {
			_svg = null;
			
			id = null;
			svgClass = null;
			svgClipPath = null;
			clearStyles();
			
			viewBox = null;
			svgX = null;
			svgY = null;
			svgWidth = null;
			svgHeight = null;
			
			defs = {};
			styles = {};
			gradients = {};
			
			while(numChildren>0)
				removeChildAt(0);
				
			_content.scaleX = 1;
			_content.scaleY = 1;
		}
				
		public function getDefinitionClone(id:String):SVGElement {
			if(defs[id] == null)
				throw new Error("Cannot find the definition '"+id+"'");
				
			return defs[id].clone(true);
		}
		
		private function visit(elt:XML, target:SVG = null):SVGElement {
			var obj:SVGElement;
			
			var localName:String = String(elt.localName()).toLowerCase();
			
			switch(localName) {
				case 'svg': obj = visitSvg(elt, target); break;
				case 'defs': obj = visitDefs(elt); break;
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
				case 'text': obj = visitText(elt); break;
				case 'tspan': obj = visitTspan(elt); break;
				case 'image' : obj = visitImage(elt); break;
				case 'a' : obj = visitA(elt); break;
				case 'use' : obj = visitUse(elt); break;
				case 'pattern' : obj = visitPattern(elt); break;
			}
			
			if(obj==null)
				return null;
							
			obj.type = localName;
			obj.id = elt.@id;
			
			//Save in definitions
			if(obj.id != null && obj.id != "")
				defs[obj.id] = obj;
			
			//Set document
			if(obj is IDocumentSetable)
				(obj as IDocumentSetable).setDocument(this);
			
			obj.setStyles(SVGUtil.presentationStyleToObject(elt));
			if("@style" in elt){
				obj.setStyles(SVGUtil.styleToObject(elt.@style));
			}
			
			if("@class" in elt){
				obj.svgClass = String(elt.@["class"]);
			}
			
			if("@transform" in elt)
				obj.transform.matrix = SVGParserCommon.parseTransformation(elt.@transform);
				
			if("@clip-path" in elt)
				obj.svgClipPath = String(elt["@clip-path"]);
				
			if(obj is IViewBox)
				(obj as IViewBox).viewBox = SVGParserCommon.parseViewBox(elt.@viewBox);
				
			if(obj.type == "clippath" || obj.type=="symbol")
				return null;
			
			return obj;
		}

		private function visitSvg(elt:XML, target:SVG):SVGElement {
			var obj:SVG = target;
			if(obj==null)
				obj = new SVG();
						
			obj.svgX = ("@x" in elt) ? elt.@x : null;
			obj.svgY = ("@y" in elt) ? elt.@y : null;
			obj.svgWidth = ("@width" in elt) ? elt.@width : "100%";
			obj.svgHeight = ("@height" in elt) ? elt.@height : "100%";
			obj.svgPreserveAspectRatio = ("@preserveAspectRatio" in elt) ? elt.@preserveAspectRatio : null;
			
			for each(var childElt:XML in elt.*) {
				var child:SVGElement = visit(childElt);
				if(child){
					obj.addChild(child);
				}
			}
			
			return obj;
		}
		
		private function visitDefs(elt:XML):SVGElement {
			for each(var childElt:XML in elt.*) {
				visit(childElt);
			}
			return null;
		}

		private function visitRect(elt:XML):SVGElement {
			var obj:SVGRect = new SVGRect();
			
			obj.svgX = elt.@x;
			obj.svgY =  elt.@y;
			obj.svgWidth =  elt.@width;
			obj.svgHeight =  elt.@height;
			obj.svgRx =  elt.@rx;
			obj.svgRy =  elt.@ry;

			if (obj.isRound) {
				obj.svgRx = (obj.svgRy != null && obj.svgRx == null) ? obj.svgRy : obj.svgRx;
				obj.svgRy = (obj.svgRx != null && obj.svgRy == null) ? obj.svgRx : obj.svgRy;
			}
			
			return obj;
		}
		
		private function visitPath(elt:XML):SVGElement {
			var obj:SVGPath = new SVGPath();
			obj.path = SVGParserCommon.parsePathData(elt.@d);
			return obj;
		}
		
		private function visitPolygon(elt:XML):SVGElement {
			var obj:SVGPolygon = new SVGPolygon();
			obj.points = SVGParserCommon.parseArgsData(elt.@points);
			return obj;
		}
		private function visitPolyline(elt:XML):SVGElement {
			var obj:SVGPolyline = new SVGPolyline();
			obj.points = SVGParserCommon.parseArgsData(elt.@points);
			return obj;
		}
		private function visitLine(elt:XML):SVGElement {
			var obj:SVGLine = new SVGLine();

			obj.svgX1 = elt.@x1;
			obj.svgY1 = elt.@y1;
			
			obj.svgX2 = elt.@x2;
			obj.svgY2 = elt.@y2;

			return obj;
		}
		private function visitCircle(elt:XML):SVGElement {
			var obj:SVGCircle = new SVGCircle();

			obj.svgCx = elt.@cx;
			obj.svgCy = elt.@cy;

			obj.svgR = elt.@r;

			return obj;
		}
		private function visitEllipse(elt:XML):SVGElement {
			var obj:SVGEllipse = new SVGEllipse();

			obj.svgCx = elt.@cx;
			obj.svgCy = elt.@cy;
			obj.svgRx = elt.@rx;
			obj.svgRy = elt.@ry;
			
			return obj;
		}
		private function visitG(elt:XML):SVGElement {
			var obj:SVGG = new SVGG();
			
			for each(var childElt:XML in elt.*) {
				var child:SVGElement = visit(childElt);
				if(child){
					obj.addChild(child);
				}
			}
			
			return obj;
		}
		
		private function visitA(elt:XML):SVGElement {
			var obj:SVGA = new SVGA();
			
			var xlink:Namespace = new Namespace("http://www.w3.org/1999/xlink");
			var link:String = elt.@xlink::href;
			link = StringUtil.ltrim(link, "#");
			
			obj.svgHref = link;
			
			for each(var childElt:XML in elt.*) {
				var child:SVGElement = visit(childElt);
				if(child){
					obj.addChild(child);
				}
			}
			
			return obj;
		}
		
		private function visitClipPath(elt:XML):SVGElement {
			var obj:SVGClipPath = new SVGClipPath();
			
			for each(var childElt:XML in elt.*) {
				var child:SVGElement = visit(childElt);
				if(child){
					obj.addChild(child);
				}
			}
			
			return obj;
		}
		
		private function visitSymbol(elt:XML):SVGElement {
			var obj:SVGSymbol = new SVGSymbol();
			
			obj.svgPreserveAspectRatio = ("@preserveAspectRatio" in elt) ? elt.@preserveAspectRatio : null;
			
			for each(var childElt:XML in elt.*) {
				var child:SVGElement = visit(childElt);
				if(child){
					obj.addChild(child);
				}
			}
			
			return obj;
		}
		
		private function visitText(elt:XML):SVGElement {
			var obj:SVGText = new SVGText();

			obj.svgX = ("@x" in elt) ? elt.@x : "0";
			obj.svgY = ("@y" in elt) ? elt.@y : "0";
			
			obj.children = new Array();
			for each(var childElt:XML in elt.*) {
				if(childElt.nodeKind() == "text"){
					obj.children.push(SVGParserCommon.CleanUp(childElt.toString()));
				} else if(childElt.nodeKind() == "element"){
					var child:Object = visit(childElt);
					if(child!=null){
						obj.children.push(child);
					}
				}
			}
			return obj;
		}
		private function visitTspan(elt:XML):SVGElement {
			var obj:SVGTSpan = new SVGTSpan();
			obj.text = SVGParserCommon.CleanUp(elt.text().toString());
			obj.svgX = ("@x" in elt) ? elt.@x : null;
			obj.svgY = ("@y" in elt) ? elt.@y : null;
			obj.svgDx = ("@dx" in elt) ? elt.@dx : "0";
			obj.svgDy = ("@dy" in elt) ? elt.@dy : "0";
			
			return obj;
		}
		
		private function visitImage(elt:XML):SVGElement {
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
		
		private function visitUse(elt:XML):SVGElement {
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
			
			for each(var childElt:XML in elt.*) {
				var child:SVGElement = visit(childElt);
				if(child){
					obj.addChild(child);
				}
			}
			
			return obj;
		}
			
		public function resolveURL(url:String):String
		{
			if (url != null && !isHttpURL(url) && baseURL!=null)
			{
				if (url.indexOf("./") == 0)
					url = url.substring(2);

				if (isHttpURL(baseURL))
				{
					var slashPos:Number;
	
					if (url.charAt(0) == '/')
					{
						// non-relative path, "/dev/foo.bar".
						slashPos = baseURL.indexOf("/", 8);
						if (slashPos == -1)
							slashPos = baseURL.length;
					}
					else
					{
						// relative path, "dev/foo.bar".
						slashPos = baseURL.lastIndexOf("/") + 1;
						if (slashPos <= 8)
						{
							baseURL += "/";
							slashPos = baseURL.length;
						}
					}
	
					if (slashPos > 0)
						url = baseURL.substring(0, slashPos) + url;
				} else {
					url = StringUtil.rtrim(baseURL, "/") + "/" + url;
				}
			}
	
			return url;
		}
	
		public static function isHttpURL(url:String):Boolean
		{
			return url != null &&
				   (url.indexOf("http://") == 0 ||
					url.indexOf("https://") == 0);
		}

		override protected function set numInvalidChildren(value:int):void {
			if(super.numInvalidChildren == 0 && value > 0){
		        if (stage != null) {
					stage.addEventListener(Event.ENTER_FRAME, validateCaller, false, 0, true);
					stage.addEventListener(Event.RENDER, validateCaller, false, 0, true);
					stage.invalidate();
		        } else {
					addEventListener(Event.ADDED_TO_STAGE, validateCaller, false, 0, true);
		        }
			}
			super.numInvalidChildren = value;
		}
		
		protected function validateCaller(e:Event):void {
			if (e.type == Event.ADDED_TO_STAGE) {
				removeEventListener(Event.ADDED_TO_STAGE, validateCaller);
			} else {
					e.target.removeEventListener(Event.ENTER_FRAME, validateCaller);
					e.target.removeEventListener(Event.RENDER, validateCaller);
					if (stage == null) {
						// received render, but the stage is not available, so we will listen for addedToStage again:
						addEventListener(Event.ADDED_TO_STAGE, validateCaller, false, 0, true);
						return;
					}
			}
			validate(true);
		}
	}
}