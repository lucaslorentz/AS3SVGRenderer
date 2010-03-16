package com.lorentz.SVG.display {
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.events.Event;
	
	import com.lorentz.SVG.SVGUtil;
	
	public class SVG extends SVGG implements IViewBox, IViewPort {	
		include "includes/ViewPortProperties.as"
		include "includes/ViewBoxProperties.as"

		
		public function SVG(){
			super();
		}
		
		override protected function initialize():void {			
			super.initialize();
						
			addEventListener(SVGDisplayEvent.CHILDREN_SYNC_VALIDATED, childrenValidated);
			addEventListener(SVGDisplayEvent.CHILDREN_ASYNC_VALIDATED, childrenValidated);
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
	        if( svgX != null )
                x = getUserUnit(svgX, SVGUtil.WIDTH);
            if( svgY != null )
                y =  getUserUnit(svgY, SVGUtil.HEIGHT);
		}
		
		protected function childrenValidated(e:SVGDisplayEvent):void {
			updateView();
		}
		
		protected function updateView():void {
			validate();
			
			_content.scaleX = 1;
			_content.scaleY = 1;
			
			if(svgWidth!=null && svgHeight!=null && svgWidth.indexOf("%")==-1 && svgHeight.indexOf("%")==-1) {
				var w:Number = getUserUnit(svgWidth, SVGUtil.WIDTH);
				var h:Number = getUserUnit(svgHeight, SVGUtil.HEIGHT);
				
				if(viewBox!=null){				
					_content.scaleX = w/viewBox.width;
					_content.scaleY = h/viewBox.height;
				} else {
					_content.scaleX = w/_content.width;
					_content.scaleY = h/_content.height;
				}
				
				_content.scaleX = Math.min(_content.scaleX, _content.scaleY);
				_content.scaleY = Math.min(_content.scaleX, _content.scaleY);
			}
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVG = super.clone(deep) as SVG;
			c.svgX = svgX;
			c.svgY = svgY;
			c.svgWidth = svgWidth;
			c.svgHeight = svgHeight;
			c.svgPreserveAspectRatio = svgPreserveAspectRatio;
			
			c.viewBox = viewBox.clone();
			return c;
		}
	}
}