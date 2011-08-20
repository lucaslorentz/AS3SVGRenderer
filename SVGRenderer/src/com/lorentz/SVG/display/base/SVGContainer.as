package com.lorentz.SVG.display.base
{

	public class SVGContainer extends SVGElement
	{
		private var _invalidElements:Boolean = false;
		private var _elements:Vector.<SVGElement> = new Vector.<SVGElement>();
		
		public function SVGContainer(tagName:String)
		{
			super(tagName);
		}
		
		protected function invalidateElements():void {
			if(!_invalidElements)
			{
				_invalidElements = true;
				invalidateProperties();
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_invalidElements){
				_invalidElements = false;
				
				while(_content.numChildren > 0)
					_content.removeChildAt(0);
				
				for each(var element:SVGElement in _elements){
					_content.addChild(element);
				}
			}
		}
		
		public function addElement(element:SVGElement):void {
			_elements.push(element);
			invalidateElements();
			attachElement(element);
		}
		
		public function getElementAt(index:int):SVGElement {
			return _elements[index];
		}
		
		public function get numElements():int {
			return _elements.length;
		}
		
		public function removeElement(element:SVGElement):void {
			var index:int = _elements.indexOf(element);
			if(index != -1){
				_elements.splice(index, 1);
				invalidateElements();
				detachElement(element);
			}
		}
		
		public function removeElementAt(index:int):void {
			if(index >= 0 && index < numElements){				
				var element:SVGElement = _elements.splice(index, 1)[0];
				invalidateElements();
				detachElement(element);
			}
		}
		
		override public function clone(deep:Boolean=true):SVGElement {
			var c:SVGContainer = super.clone(deep) as SVGContainer;
			if(deep){
				for(var i:int = 0; i < numElements; i++){
					c.addElement(getElementAt(i).clone(true));
				}
			}
			return c;
		}
	}
}