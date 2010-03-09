/* Author: Lucas Lorentz Lara - 25/09/2008
*/

package com.lorentz.SVG {
	public class PathCommand {
		import flash.geom.Point;
		
		public var type:String;
		public var _args:Array;
		
		public function PathCommand(type:String = null, args:Array = null){
			this.type = type;
			this._args = args;
		}
		

		public function get args():Array{
			if(_args==null){
				_args = new Array();
			}
			return _args;
		}
		
		public function set args(value:*):void{
			_args = value;
		}
		
		public function clone():PathCommand {
			var c:PathCommand = new PathCommand();
			c.type = type;
			c._args = SVGUtil.cloneArray(_args);
			return c;
		}
	}
}