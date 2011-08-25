package com.lorentz.SVG.events {
	import com.lorentz.SVG.display.base.SVGElement;
	
	import flash.events.Event;
	
	public class SVGEvent extends Event {		
		public static const INVALIDATE:String = "invalidate";
		
		public static const SYNC_VALIDATED:String = "syncValidated";
		public static const ASYNC_VALIDATED:String = "asyncValidated";
		public static const VALIDATED:String = "validated";
		
		public static const PARSE_START:String = "parseStart";
		public static const PARSE_COMPLETE:String = "parseComplete";
		public static const ELEMENT_ADDED:String = "elementAdded";
		public static const ELEMENT_REMOVED:String = "elementRemoved";
		
		private var _element:SVGElement;
		public function get element():SVGElement {
			return _element;
		}
		
		public function SVGEvent(type:String, element:SVGElement = null, bubbles:Boolean = false, cancelable:Boolean = false){
			super(type, bubbles, cancelable);
			_element = element;
		}
		
		override public function clone():Event{
			return new SVGEvent(type, element, bubbles, cancelable);
		}
	}
}