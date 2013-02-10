package com.lorentz.SVG.display.base {
	import com.lorentz.SVG.data.MarkerPlace;
	import com.lorentz.SVG.display.SVGMarker;
	import com.lorentz.SVG.drawing.DashedDrawer;
	import com.lorentz.SVG.drawing.GraphicsPathDrawer;
	import com.lorentz.SVG.drawing.IDrawer;
	import com.lorentz.SVG.drawing.MarkersPlacesCapturerDrawer;
	import com.lorentz.SVG.utils.SVGUtil;
	
	import flash.display.Graphics;
	import flash.display.GraphicsPathWinding;
	import flash.geom.Rectangle;

	public class SVGShape extends SVGGraphicsElement {
		private var _markers:Vector.<SVGMarker> = new Vector.<SVGMarker>();		
		private var _markersPlaces:Vector.<MarkerPlace>;
		
		public function SVGShape(tagName:String){
			super(tagName);
		}
		
		override protected function initialize():void {
			super.initialize();
			this.mouseChildren = false;
		}
						
		override protected function render():void {
			super.render();
			
			_markersPlaces = null;
			
			beforeDraw();
						
			content.graphics.clear();
			
			if(hasStroke && !hasDashedStroke)
				lineStyle(content.graphics);
			
			beginFill(content.graphics, function():void {
				drawWithAppropriateMethod();
				content.graphics.endFill();
			});
			
			if(hasDashedStroke){
				var dashedGraphicsPathDrawer:GraphicsPathDrawer = new GraphicsPathDrawer();
				var dashedDrawer:DashedDrawer = new DashedDrawer(dashedGraphicsPathDrawer);
				configureDashedDrawer(dashedDrawer);
				drawToDrawer(dashedDrawer);
				
				lineStyle(content.graphics);
				
				content.graphics.drawPath(dashedGraphicsPathDrawer.commands, dashedGraphicsPathDrawer.pathData);
				content.graphics.endFill();
			}
			
			renderMarkers();
		}
		
		private function drawWithAppropriateMethod():void {
			var captureMarkers:Boolean = hasMarkers && _markersPlaces == null;
						
			if(!captureMarkers && hasDrawDirectlyToGraphics){
				drawDirectlyToGraphics(content.graphics);
			} else {
				var graphicsPathDrawer:GraphicsPathDrawer = new GraphicsPathDrawer();
				
				if(captureMarkers) {
					var extractMarkersInfoInterceptor:MarkersPlacesCapturerDrawer = new MarkersPlacesCapturerDrawer(graphicsPathDrawer);
					content.graphics.drawPath(graphicsPathDrawer.commands, graphicsPathDrawer.pathData, getFlashWinding());
					drawToDrawer(extractMarkersInfoInterceptor);
					_markersPlaces = extractMarkersInfoInterceptor.getMarkersInfo();
				} else {
					drawToDrawer(graphicsPathDrawer);
				}

				content.graphics.drawPath(graphicsPathDrawer.commands, graphicsPathDrawer.pathData, getFlashWinding());
			}
		}
		
		protected function beforeDraw():void { }
		
		protected function drawToDrawer(drawer:IDrawer):void { }
		
		protected function drawDirectlyToGraphics(graphics:Graphics):void { }
		
		protected function get hasDrawDirectlyToGraphics():Boolean {
			return false;
		}
		
		private function get hasMarkers():Boolean {
			return hasStroke && (style.getPropertyValue("marker")
				|| style.getPropertyValue("marker-start")
				|| style.getPropertyValue("marker-mid")
				|| style.getPropertyValue("marker-end"));
		}
		
		private function getFlashWinding():String {
			var winding:String = finalStyle.getPropertyValue("fill-rule") || "nonzero";
			switch (winding.toLowerCase())
			{
				case GraphicsPathWinding.EVEN_ODD.toLowerCase():
					return GraphicsPathWinding.EVEN_ODD;
					break;
				
				case GraphicsPathWinding.NON_ZERO.toLowerCase():
					return GraphicsPathWinding.NON_ZERO;
					break;
			}
			return GraphicsPathWinding.NON_ZERO;
		}
		
		private function renderMarkers():void {
			for each(var oldMarker:SVGMarker in _markers){
				detachElement(oldMarker);
				content.removeChild(oldMarker);
			}
			
			if(_markersPlaces){
				for each(var markerPlace:MarkerPlace in _markersPlaces){
					var markerStyle:String = "marker-" + markerPlace.type;
					
					var markerLink:String = finalStyle.getPropertyValue(markerStyle) || finalStyle.getPropertyValue("marker");
					
					if(!markerLink)
						continue;
					
					var markerId:String = SVGUtil.extractUrlId(markerLink);
					if(!markerId)
						continue;
					
					var marker:SVGMarker = document.getDefinitionClone(markerId) as SVGMarker;
					
					if(!marker)
						continue;
					
					var strokeWidth:Number = 1;
					if(finalStyle.getPropertyValue("stroke-width"))
						strokeWidth = getViewPortUserUnit(finalStyle.getPropertyValue("stroke-width"), SVGUtil.WIDTH_HEIGHT);
					
					markerPlace.strokeWidth = strokeWidth;
					marker.markerPlace = markerPlace;
					content.addChild(marker);
					attachElement(marker);
					_markers.push(marker);
				}
			}
		}
		
		override protected function getObjectBounds():Rectangle {
			graphics.beginFill(0);
			drawWithAppropriateMethod();
			return content.getBounds(this);
		}
	}
}