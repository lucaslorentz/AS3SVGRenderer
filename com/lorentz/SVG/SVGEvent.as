package com.lorentz.SVG {
	import flash.events.Event;
	
	public class SVGEvent extends Event {
		public static const LOAD_COMPLETE:String = "svgLoadComplete";
		public static const RENDER_COMPLETE:String = "svgRenderComplete";
		public static const PRE_RENDER_ELEMENT:String = "preRenderElement";
		public static const POS_RENDER_ELEMENT:String = "posRenderElement";
		
		public function SVGEvent(type:String, element:Object = null, renderedObject:Object = null){
			super(type);
			_element = element;
			_renderedObject = renderedObject;
		}
		
		// Override clone
		override public function clone():Event{
			return new SVGEvent(type, _element, _renderedObject);
		}
		
		protected var _element:Object;
		public function get element():Object {
			return _element;
		}
		
		protected var _renderedObject:Object;
		public function get renderedObject():Object {
			return _renderedObject;
		}
	}
	
}