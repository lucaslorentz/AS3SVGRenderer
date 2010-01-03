package com.lorentz.SVG {
	import flash.events.Event;
	
	public class SVGEvent extends Event {
		public static const LOAD_COMPLETE:String = "svgLoadComplete";
		public static const RENDER_COMPLETE:String = "svgRenderComplete";
		public static const PRE_RENDER_OBJECT:String = "preRenderObject";
		
		public function SVGEvent(type:String, item:Object = null){
			super(type);
			_item = item;
		}
		
		// Override clone
		override public function clone():Event{
			return new SVGEvent(type, _item);
		}
		
		protected var _item:Object;
		public function get item():Object {
			return _item;
		}
	}
	
}