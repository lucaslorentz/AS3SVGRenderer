package com.lorentz.SVG.display {
	import flash.events.Event;
	
	public class SVGDisplayEvent extends Event {
		public static const INVALIDATE:String = "invalidate";
		public static const BEFORE_VALIDATE:String = "beforeValidate";
		public static const VALIDATED:String = "validated";
		public static const CHILDREN_SYNC_VALIDATED:String = "childrenSyncValidated";
		public static const CHILDREN_ASYNC_VALIDATED:String = "childrenASyncValidated";
		public static const CHILDREN_VALIDATED:String = "childrenValidated";
		public static const ELEMENT_ADDED:String = "elementAdded";
		public static const ELEMENT_REMOVED:String = "elementRemoved";
		public static const PARENT_CHANGED:String = "parentChanged";
		public static const DOCUMENT_CHANGED:String = "documentChanged";
		
		public function SVGDisplayEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false){
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event{
			return new SVGDisplayEvent(type, bubbles, cancelable);
		}
	}
	
}