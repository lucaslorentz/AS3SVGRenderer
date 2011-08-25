package com.lorentz.SVG.data.style
{
	import com.lorentz.SVG.events.StyleDeclarationEvent;
	import com.lorentz.SVG.utils.StringUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

	[Event(name="propertyChange", type="com.lorentz.SVG.events.StyleDeclarationEvent")]
	public class StyleDeclaration extends EventDispatcher
	{
		private var _propertiesValues:Object = {};
		private var _indexedProperties:Array = [];
		
		public function getPropertyValue(propertyName:String):String {
			return _propertiesValues[propertyName];
		}
		
		public function setProperty(propertyName:String, value:String):void {
			if(_propertiesValues[propertyName] != value){
				var oldValue:String = _propertiesValues[propertyName];
				
				_propertiesValues[propertyName] = value;
				indexProperty(propertyName);
				
				dispatchEvent( new StyleDeclarationEvent(StyleDeclarationEvent.PROPERTY_CHANGE, propertyName, oldValue, value) );
			}
		}
		
		public function removeProperty(propertyName:String):String {
			var oldValue:String = _propertiesValues[propertyName];
			delete _propertiesValues[propertyName];			
			unindexProperty(propertyName);
			
			dispatchEvent( new StyleDeclarationEvent(StyleDeclarationEvent.PROPERTY_CHANGE, propertyName, oldValue, null) );
			
			return oldValue;
		}
		
		public function hasProperty(propertyName:String):Boolean {
			var index:int = _indexedProperties.indexOf(propertyName);
			return index != -1;
		}
		
		public function get length():int {
			return _indexedProperties.length;
		}
		
		public function item(index:int):String {
			return _indexedProperties[index];
		}
		
		public function fromString(styleString:String):void {
			styleString = StringUtil.trim(styleString);
			styleString = StringUtil.rtrim(styleString, ";");
			
			for each(var prop:String in styleString.split(";")){
				var split:Array = prop.split(":");
				if(split.length==2)
					setProperty(StringUtil.trim(split[0]), StringUtil.trim(split[1]));
			}
		}
		
		public static function createFromString(styleString:String):StyleDeclaration {
			var styleDeclaration:StyleDeclaration = new StyleDeclaration();
			styleDeclaration.fromString(styleString);
			return styleDeclaration;
		}
		
		override public function toString():String {
			var styleString:String = "";
			
			for each(var propertyName:String in _indexedProperties){
				styleString += propertyName+":"+_propertiesValues[propertyName]+ "; ";
			}
			
			return styleString;
		}
		
		public function clear():void {
			while(length > 0)
				removeProperty(item(0));
		}
		
		public function copyTo(target:StyleDeclaration, merge:Boolean = true):void {
			var propertyName:String;
			
			for each(propertyName in _indexedProperties){
				target.setProperty(propertyName, getPropertyValue(propertyName));
			}
			
			if(!merge)
			{
				for(var i:int = 0; i < target.length; i++)
				{
					propertyName = target.item(i);
					if(!hasProperty(propertyName))
						target.removeProperty(propertyName);
				}
			}
		}
		
		private function indexProperty(propertyName:String):void {
			if(_indexedProperties.indexOf(propertyName) == -1)
				_indexedProperties.push(propertyName);
		}
		
		private function unindexProperty(propertyName:String):void {
			var index:int = _indexedProperties.indexOf(propertyName);
			if(index != -1)
				_indexedProperties.splice(index, 1);
		}
	}
}