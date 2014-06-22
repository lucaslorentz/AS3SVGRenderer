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
					_includedElement = document.getDefinitionClone(StringUtil.ltrim(svgHref, "#")) as SVGElement;
					if(_includedElement != null){
						attachElement(_includedElement);
						content.addChild(_includedElement);
					}
				}
			}
			
			if(_includedElement){
				if(svgTransform) {
					svgX = svgY = null;
					svgWidth = svgHeight = null;
				}
				_includedElement.x = svgX ? getViewPortUserUnit(svgX, SVGUtil.WIDTH) : 0;
				_includedElement.y = svgY ? getViewPortUserUnit(svgY, SVGUtil.HEIGHT) : 0;
				_includedElement.svgTransform += " " + svgTransform;
				
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
		
		override protected function get shouldApplySvgTransform():Boolean {
			return false;
		}
		
		override protected function getContentBox():Rectangle {
			if(_includedElement is ISVGViewBox)
				return (_includedElement as ISVGViewBox).svgViewBox;
			
			return null;
		}
		
		override public function clone():Object {
			var c:SVGUse = super.clone() as SVGUse;
			c.svgHref = svgHref;
			return c;
		}
	}
}