package com.lorentz.SVG.display {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	import com.lorentz.SVG.SVGUtil;
	
	public class SVGA extends SVGG {	
		public function SVGA(){
			super();
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