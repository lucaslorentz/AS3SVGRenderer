package com.lorentz.SVG.display
{
	import com.lorentz.SVG.data.MarkerPlace;
	import com.lorentz.SVG.display.base.ISVGPreserveAspectRatio;
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.SVGContainer;
	import com.lorentz.SVG.display.base.SVGElement;
	import com.lorentz.SVG.parser.SVGParserCommon;
	import com.lorentz.SVG.utils.SVGUtil;
	import com.lorentz.SVG.utils.SVGViewPortUtils;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class SVGMarker extends SVGContainer implements ISVGViewBox, ISVGPreserveAspectRatio {
		private var _invalidPlacement:Boolean = true;
		private var _markerPlace:MarkerPlace;
		
		public function SVGMarker(){
			super("marker");
		}
			
		public function get svgRefX():String {
			return getAttribute("refX") as String;
		}
		public function set svgRefX(value:String):void {
			setAttribute("refX", value);
			invalidatePlacement();
		}
		
		public function get svgRefY():String {
			return getAttribute("refY") as String;
		}
		public function set svgRefY(value:String):void {
			setAttribute("refY", value);
			invalidatePlacement();
		}
		
		public function get svgMarkerWidth():String {
			return getAttribute("markerWidth") as String;
		}
		public function set svgMarkerWidth(value:String):void {
			setAttribute("markerWidth", value);
			invalidatePlacement();
		}
		
		public function get svgMarkerHeight():String {
			return getAttribute("markerHeight") as String;
		}
		public function set svgMarkerHeight(value:String):void {
			setAttribute("markerHeight", value);
			invalidatePlacement();
		}
		
		public function get svgOrient():String {
			return getAttribute("orient") as String;
		}
		public function set svgOrient(value:String):void {
			setAttribute("orient", value);
			invalidatePlacement();
		}
		
		public function get svgViewBox():Rectangle {
			return getAttribute("viewBox") as Rectangle;
		}
		public function set svgViewBox(value:Rectangle):void {
			setAttribute("viewBox", value);
			invalidatePlacement();
		}
		
		public function get svgPreserveAspectRatio():String {
			return getAttribute("preserveAspectRatio") as String;
		}
		public function set svgPreserveAspectRatio(value:String):void {
			setAttribute("preserveAspectRatio", value);
			invalidatePlacement();
		}
		
		protected function invalidatePlacement():void {
			if(!_invalidPlacement)
			{
				_invalidPlacement = true;
				invalidate();
			}
		}
		
		override protected function getElementToInheritStyles():SVGElement {
			if(!parentElement)
				return null;
			
			return parentElement.parentElement;
		}
				
		public function get markerPlace():MarkerPlace {
			return _markerPlace;
		}
		public function set markerPlace(value:MarkerPlace):void {		
			_markerPlace = value;
			invalidatePlacement();
		}
		
		override public function validate():void {
			super.validate();
			
			if(_invalidPlacement){				
				_invalidPlacement = false;
				
				//viewport
				scrollRect = null;
				content.scaleX = 1;
				content.scaleY = 1;
				content.x = 0;
				content.y = 0;
				
				var markerWidth:Number = 3;
				if(svgMarkerWidth)
					markerWidth = getUserUnit(svgMarkerWidth, SVGUtil.WIDTH);
				
				var markerHeight:Number = 3;
				if(svgMarkerHeight)
					markerHeight = getUserUnit(svgMarkerHeight, SVGUtil.HEIGHT);
								
				if(svgViewBox != null){					
					if(svgPreserveAspectRatio != "none"){
						var viewPortBox:Rectangle = new Rectangle(0, 0, markerWidth, markerHeight);
						
						var preserveAspectRatio:Object = SVGParserCommon.parsePreserveAspectRatio(svgPreserveAspectRatio || "");
						
						var viewPortContentMetrics:Object = SVGViewPortUtils.getContentMetrics(viewPortBox, svgViewBox, preserveAspectRatio.align, preserveAspectRatio.meetOrSlice);
						
						if(preserveAspectRatio.meetOrSlice == "slice"){
							scrollRect = viewPortBox;
						}
						
						content.scaleX = viewPortContentMetrics.contentScaleX;
						content.scaleY = viewPortContentMetrics.contentScaleY;
						content.x = viewPortContentMetrics.contentX;
						content.y = viewPortContentMetrics.contentY;
					} else {
						content.x = x;
						content.y = y;
						content.scaleX = markerWidth / content.width;
						content.scaleY = markerHeight / content.height;
					}
				}
				
				//Position and so on
				var refX:Number = 0;
				if(svgRefX)
					refX = getUserUnit(svgRefX, SVGUtil.WIDTH);
				
				var refY:Number = 0;
				if(svgRefY)
					refY = getUserUnit(svgRefY, SVGUtil.HEIGHT);
				
				rotation = !svgOrient || svgOrient == "auto" ? markerPlace.angle : Number(svgOrient);
				scaleX = markerPlace.strokeWidth;
				scaleY = markerPlace.strokeWidth;
				
				var referenceGlobal:Point = content.localToGlobal(new Point(refX, refY));
				var referencePointOnParentObject:Point = parent.globalToLocal(referenceGlobal);
				
				x = markerPlace.position.x - referencePointOnParentObject.x - x;
				y = markerPlace.position.y - referencePointOnParentObject.y - y;
			}
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGMarker = super.clone(deep) as SVGMarker;
			c.svgRefX = svgRefX;
			c.svgRefY = svgRefY;
			c.svgMarkerWidth = svgMarkerWidth;
			c.svgMarkerHeight = svgMarkerHeight;
			c.svgOrient = svgOrient;
			return c;
		}
	}
}