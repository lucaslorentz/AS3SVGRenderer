package com.lorentz.SVG {
	import flash.events.Event;
	
	public class SVGEvent extends Event {
		public static const LOAD_COMPLETE:String = "svgLoadComplete";
		public static const RENDER_COMPLETE:String = "svgRenderComplete";
		
		public function SVGEvent(type:String){
			super(type);
		}
		
		// Override clone
		override public function clone():Event{
			return new SVGEvent(type);
		}
	}
	
}