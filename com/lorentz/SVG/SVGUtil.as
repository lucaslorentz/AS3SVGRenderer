package com.lorentz.SVG {
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Shape;
	
	import flash.geom.Point;
	import com.lorentz.SVG.PathCommand;
	
	public class SVGUtil {
		public static function styleToObject(style:String):Object{
			style = StringUtil.trim(style);
			style = StringUtil.rtrim(style, ";");
			
			var obj:Object = new Object();
			for each(var prop:String in style.split(";")){
				var split:Array = prop.split(":");
				if(split.length==2)
					obj[StringUtil.trim(split[0])] = StringUtil.trim(split[1]);
			}
			
			return obj;
		}
		
		public static function mergeObjectStyles(obja:Object, objb:Object):Object{
			var temp:Object = new Object();
			for(var prop:String in obja){
				temp[prop] = obja[prop];
			}
			
			for(var p:String in objb){
				temp[p] = objb[p];
			}
			
			return temp;
		}
		
		/*NOT USED
		public static function ObjectToStyle(obj_style:Object):String{
			var style:String = new String();
			
			for(var p_name:String in obj_style){
				style += p_name+":"+obj_style[p_name]+ ";";
			}
			
			return style;
		}*/
		
		public static function presentationStyleToObject(elt:XML):Object{
			var obj:Object = new Object();
			
			if("@display" in elt)
				obj["display"] = elt.@display;
			if("@visibility" in elt)
				obj["visibility"] = elt.@visibility;
			
			if("@fill" in elt)
				obj["fill"] = elt.@fill;
			if("@fill-opacity" in elt)
				obj["fill-opacity"] = elt.@["fill-opacity"];

			if("@stroke" in elt)
				obj["stroke"] = elt.@stroke;
			if("@stroke-opacity" in elt)
				obj["stroke-opacity"] = elt.@["stroke-opacity"];
			if("@stroke-width" in elt)
				obj["stroke-width"] = elt.@["stroke-width"];
			if("@stroke-linecap" in elt)
				obj["stroke-linecap"] = elt.@["stroke-linecap"];
			if("@stroke-linejoin" in elt)
				obj["stroke-linejoin"] = elt.@["stroke-linejoin"];
				
			if("@fill-rule" in elt)
				obj["fill-rule"] = elt.@["fill-rule"];
				
			if("@font-size" in elt)
				obj["font-size"] = elt.@["font-size"];
				
			return obj;
		}
	}
}