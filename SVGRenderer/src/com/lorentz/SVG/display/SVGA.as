package com.lorentz.SVG.display {
	import com.lorentz.SVG.display.base.SVGContainer;
	
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import com.lorentz.SVG.display.base.SVGElement;
	
	public class SVGA extends SVGContainer {	
		public function SVGA(){
			super("a");
		}
		
		public var svgHref:String;
		
		override protected function initialize():void {
			super.initialize();
			
			this.buttonMode = true;
			this.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
		}
		
		protected function clickHandler(e:MouseEvent):void {
			if(svgHref!=null && svgHref!="")
				navigateToURL(new URLRequest(svgHref));
		}
		
		override public function clone(deep:Boolean = true):SVGElement {
			var c:SVGA = super.clone(deep) as SVGA;
			c.svgHref = svgHref;
			return c;
		}
	}
}