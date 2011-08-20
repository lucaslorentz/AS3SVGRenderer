package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.ISVGViewPort;
	import com.lorentz.SVG.utils.StringUtil;
	
	import flash.geom.Rectangle;
	import com.lorentz.SVG.display.base.SVGElement;
	
	public class SVGUse extends SVGElement implements ISVGViewPort {
		include "includes/SVGViewPortProperties.as"
		
		protected var _svgHrefChanged:Boolean = false;
		protected var _svgHref:String;
		public function get svgHref():String {
			return _svgHref;
		}
		public function set svgHref(value:String):void {			
			_svgHref = value;
			_svgHrefChanged = true;
			invalidateProperties();
		}
		
		protected var _includedElement:SVGElement;
		
		public function SVGUse(){
			super("use");
		}
				
		override protected function commitProperties():void {
			super.commitProperties();

			if(_svgHrefChanged){
				_svgHrefChanged = false;
				
				if(_includedElement != null){
					_content.removeChild(_includedElement);
					detachElement(_includedElement);
					_includedElement = null;
				}
					
				if(svgHref){
					_includedElement = document.getDefinitionClone(StringUtil.ltrim(svgHref, "#"));
					attachElement(_includedElement);
					_content.addChild(_includedElement);
				}
			}
		}
		
		override protected function getViewPortContentBox():Rectangle {
			if(_includedElement is ISVGViewBox)
				return (_includedElement as ISVGViewBox).svgViewBox;
			
			return null;
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGUse = super.clone(deep) as SVGUse;
			c.svgHref = svgHref;
			return c;
		}
	}
}