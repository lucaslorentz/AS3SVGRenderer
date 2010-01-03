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
		
		protected static const presentationStyles = ["display", "visibility", "opacity", "fill",
													 "fill-opacity", "fill-rule", "stroke", "stroke-opacity",
													 "stroke-width", "stroke-linecap", "stroke-linejoin",
													 "font-size", "font-family", "font-weight", "text-anchor",
													 "dominant-baseline"];
		
		public static function presentationStyleToObject(elt:XML):Object{
			var obj:Object = new Object();
			
			for each(var styleName:String in presentationStyles){
				if("@"+styleName in elt){
					obj[styleName] = elt["@"+styleName];
				}
			}
			
			return obj;
		}
	}
}