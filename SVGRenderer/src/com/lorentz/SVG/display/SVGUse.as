package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.ISVGViewBox;
	import com.lorentz.SVG.display.base.ISVGViewPort;
	import com.lorentz.SVG.display.base.SVGElement;
	import com.lorentz.SVG.utils.SVGUtil;
	import com.lorentz.SVG.utils.StringUtil;
	
	import flash.geom.Rectangle;
	
	public class SVGUse extends SVGElement implements ISVGViewPort {
		protected var _includedElement:SVGElement;
		private var _svgHrefChanged:Boolean = false;
		private var _svgHref:String;
		
		public function get svgHref():String {
			return _svgHref;
		}
		public function set svgHref(value:String):void {			
			_svgHref = value;
			_svgHrefChanged = true;
			invalidateProperties();
		}
		
		public function SVGUse(){
			super("use");
		}
		
		public function get svgPreserveAspectRatio():String {
			return getAttribute("preserveAspectRatio") as String;
		}
		public function set svgPreserveAspectRatio(value:String):void {
			setAttribute("preserveAspectRatio", value);
		}
		
		public function get svgX():String {
			return getAttribute("x") as String;
		}
		public function set svgX(value:String):void {
			setAttribute("x", value);
		}
		
		public function get svgY():String {
			return getAttribute("y") as String;
		}
		public function set svgY(value:String):void {
			setAttribute("y", value);
		}
		
		public function get svgWidth():String {
			return getAttribute("width") as String;
		}
		public function set svgWidth(value:String):void {
			setAttribute("width", value);
		}
		
		public function get svgHeight():String {
			return getAttribute("height") as String;
		}
		public function set svgHeight(value:String):void {
			setAttribute("height", value);
		}
		
		public function get svgOverflow():String {
			return getAttribute("overflow") as String;
		}
		public function set svgOverflow(value:String):void {
			setAttribute("overflow", value);
		}
				
		override protected function commitProperties():void {
			super.commitProperties();

			if(_svgHrefChanged){
				_svgHrefChanged = false;
				
				if(_includedElement != null){
					content.removeChild(_includedElement);
					detachElement(_includedElement);
					_includedElement = null;
				}
					
				if(svgHref){
					_includedElement = document.getElementDefinitionClone(StringUtil.ltrim(svgHref, "#"));
					attachElement(_includedElement);
					content.addChild(_includedElement);
				}
			}
			
			if(_includedElement){
				_includedElement.x = svgX ? getUserUnit(svgX, SVGUtil.WIDTH) : 0;
				_includedElement.y = svgY ? getUserUnit(svgY, SVGUtil.HEIGHT) : 0;
				
				if(_includedElement is SVG)
				{
					var includedSVG:SVG = _includedElement as SVG;
					if(svgWidth)
						includedSVG.svgWidth = svgWidth;
					if(svgHeight)
						includedSVG.svgHeight = svgHeight;
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