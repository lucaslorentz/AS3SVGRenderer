package com.lorentz.SVG.events
{
	import flash.events.Event;

	public class StyleDeclarationEvent extends Event
	{
		public static const PROPERTY_CHANGE:String = "propertyChange";
		
		private var _propertyName:String;
		private var _oldValue:String;
		private var _newValue:String;
		
		public function StyleDeclarationEvent(type:String, propertyName:String, oldValue:String, newValue:String)
		{
			super(type);
			
			_propertyName = propertyName;
			_oldValue = oldValue;
			_newValue = newValue;
		}
		
		public function get propertyName():String {
			return _propertyName;
		}
		
		public function get oldValue():String {
			return _oldValue;
		}
		
		public function get newValue():String {
			return _newValue;
		}
	}
}