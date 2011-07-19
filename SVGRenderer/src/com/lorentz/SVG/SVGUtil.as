package com.lorentz.SVG {
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Shape;
	
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
		
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
		
		public static function objectToStyle(obj_style:Object):String{
			var style:String = "";
			
			for(var p_name:String in obj_style){
				style += p_name+":"+obj_style[p_name]+ "; ";
			}
			
			return style;
		}
		
		public static function mergeObjects(obja:Object, objb:Object):Object{
			var temp:Object = new Object();
			for(var prop:String in obja){
				temp[prop] = obja[prop];
			}
			for(var p:String in objb){
				temp[p] = objb[p];
			}			
			return temp;
		}
		
		public static function cloneObject(obj:Object):Object 
		{
			var c:Object = {};
			for(var p:String in obj)
				c[p] = obj[p];
			return c;
		}
		
		public static function cloneArray(arr:Array):Array {
			return arr.slice();
		}
		
		protected static const presentationStyles:Array = ["display", "visibility", "opacity", "fill",
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
		
		
		public static function flashRadialGradientMatrix( cx:Number, cy:Number, r:Number, fx:Number, fy:Number ):Matrix { 
			var d:Number = r*2; 
			var mat:Matrix = new flash.geom.Matrix(); 
			mat.createGradientBox( d, d, 0, 0., 0. ); 
			
			var a:Number = Math.atan2(fy-cy,fx-cx); 
			mat.translate( -cx, -cy ); 
			mat.rotate( -a );
			mat.translate( cx, cy ); 
			
			mat.translate( cx-r, cy-r ); 
			
			return mat; 
        }
		
		public static function flashLinearGradientMatrix( x1:Number, y1:Number, x2:Number, y2:Number ):Matrix { 
			var w:Number = x2-x1;
			var h:Number = y2-y1; 
			var a:Number = Math.atan2(h,w); 
			var vl:Number = Math.sqrt( Math.pow(w,2) + Math.pow(h,2) ); 
			
			var matr:Matrix = new flash.geom.Matrix(); 
			matr.createGradientBox( 1, 1, 0, 0., 0. ); 
			
			matr.rotate( a ); 
			matr.scale( vl, vl ); 
			matr.translate( x1, y1 ); 
			
			return matr; 
        } 
		
		
		
		
		public static const WIDTH:String = "width";
		public static const HEIGHT:String = "height";
		public static const WIDTH_HEIGHT:String = "width_height";
		
		public static function getFontSize(s:String, currentFontSize:Number, currentViewBox:Rectangle):Number{
			switch(s){
				case "xx-small" : s = "6.94pt"; break;
				case "x-small" : s = "8.33pt"; break;
				case "small" : s = "10pt"; break;
				case "medium" : s = "12pt"; break;
				case "large" : s = "14.4pt"; break;
				case "x-large" : s = "17.28pt"; break;
				case "xx-large" : s = "20.736pt"; break;
			}
			return getUserUnit(s, currentFontSize, currentViewBox, WIDTH);
		}
		
		public static function getUserUnit(s:String, currentFontSize:Number, currentViewBox:Rectangle, viewBoxReference:String):Number {
			var value:Number;
			
			if(s.indexOf("pt")!=-1){
				value = Number(StringUtil.remove(s, "pt"));
				return value*1.25;
			} else if(s.indexOf("pc")!=-1){
				value = Number(StringUtil.remove(s, "pc"));
				return value*15;
			} else if(s.indexOf("mm")!=-1){
				value = Number(StringUtil.remove(s, "mm"));
				return value*3.543307;
			} else if(s.indexOf("cm")!=-1){
				value = Number(StringUtil.remove(s, "cm"));
				return value*35.43307;
			} else if(s.indexOf("in")!=-1){
				value = Number(StringUtil.remove(s, "in"));
				return value*90;
			} else if(s.indexOf("px")!=-1){
				value = Number(StringUtil.remove(s, "px"));
				return value;
				
			//Relative
			} else if(s.indexOf("em")!=-1){
				value = Number(StringUtil.remove(s, "em"));
				return value*currentFontSize;
				
			//Percentage
			} else if(s.indexOf("%")!=-1){
				value = Number(StringUtil.remove(s, "%"));
				
				switch(viewBoxReference){
					case WIDTH : return value/100 * currentViewBox.width;
							break;
					case HEIGHT : return value/100 * currentViewBox.height;
							break;
					default : return value/100 * Math.sqrt(Math.pow(currentViewBox.width,2)+Math.pow(currentViewBox.height,2))/Math.sqrt(2)
							break;
				}
			} else {
				return Number(s);
			}
		}
	}
}