package com.lorentz.SVG.display {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.geom.Rectangle;
	
	import com.lorentz.SVG.SVGUtil;
	import com.lorentz.SVG.StringUtil;
	
	public class SVGUse extends SVGG implements IViewPort {	
		include "includes/ViewPortProperties.as"
		
		protected var _svgHrefChanged:Boolean = false;
		protected var _svgHref:String;
		public function get svgHref():String {
			return _svgHref;
		}
		public function set svgHref(value:String):void {			
			_svgHref = value;
			_svgHrefChanged = true;
			invalidate();
		}
		
		protected var _includedElement:SVGElement;
		
		public function SVGUse(){
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

			if(_svgHrefChanged){
				_svgHrefChanged = false;
				
				if(_includedElement!=null)
					removeChild(_includedElement);
	
				_includedElement = document.getDefinitionClone(StringUtil.ltrim(svgHref, "#"));
				addChild(_includedElement);
			}
		}
		
		protected function childrenValidated(e:SVGDisplayEvent):void {
			updateView();
		}
		
		protected function updateView():void {
			validate();

			if(svgWidth!=null && svgHeight!=null) {
				var w:Number = getUserUnit(svgWidth, SVGUtil.WIDTH);
				var h:Number = getUserUnit(svgHeight, SVGUtil.HEIGHT);
				
				if((_includedElement is IViewBox) && (_includedElement as IViewBox).viewBox!=null){
					_content.scaleX = w/(_includedElement as IViewBox).viewBox.width;
					_content.scaleY = h/(_includedElement as IViewBox).viewBox.height;
				} else {
					_content.scaleX = w/_includedElement.width;
					_content.scaleY = h/_includedElement.height;
				}
				
				_content.scaleX = Math.min(_content.scaleX, _content.scaleY);
				_content.scaleY = Math.min(_content.scaleX, _content.scaleY);
			} else {
				_content.scaleX = 1;
				_content.scaleY = 1;
			}
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGUse = super.clone(deep) as SVGUse;
			c.svgX = svgX;
			c.svgY = svgY;
			c.svgWidth = svgWidth;
			c.svgHeight = svgHeight;
			c.svgPreserveAspectRatio = svgPreserveAspectRatio;
			
			c.svgHref = svgHref;
			return c;
		}
	}
}