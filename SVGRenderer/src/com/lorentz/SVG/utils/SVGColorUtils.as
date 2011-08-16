/* Author: Lucas Lorentz Lara - 25/09/2008
*/

package com.lorentz.SVG.utils{
	import com.lorentz.SVG.parser.SVGParserCommon;

	public class SVGColorUtils {
		private static  var colors:Object = {};
		colors["aliceblue"] = 0xF0F8FF;
		colors["antiquewhite"] = 0xFAEBD7;
		colors["aqua"] = 0x00FFFF;
		colors["aquamarine"] = 0x7FFFD4;
		colors["azure"] = 0xF0FFFF;
		colors["beige"] = 0xF5F5DC;
		colors["bisque"] = 0xFFE4C4;
		colors["black"] = 0x000000;
		colors["blanchedalmond"] = 0xFFEBCD;
		colors["blue"] = 0x0000FF;
		colors["blueviolet"] = 0x8A2BE2;
		colors["brown"] = 0xA52A2A;
		colors["burlywood"] = 0xDEB887;
		colors["cadetblue"] = 0x5F9EA0;
		colors["chartreuse"] = 0x7FFF00;
		colors["chocolate"] = 0xD2691E;
		colors["coral"] = 0xFF7F50;
		colors["cornflowerblue"] = 0x6495ED;
		colors["cornsilk"] = 0xFFF8DC;
		colors["crimson"] = 0xDC143C;
		colors["cyan"] = 0x00FFFF;
		colors["darkblue"] = 0x00008B;
		colors["darkcyan"] = 0x008B8B;
		colors["darkgoldenrod"] = 0xB8860B;
		colors["darkgray"] = 0xA9A9A9;
		colors["darkgrey"] = 0xA9A9A9;
		colors["darkgreen"] = 0x006400;
		colors["darkkhaki"] = 0xBDB76B;
		colors["darkmagenta"] = 0x8B008B;
		colors["darkolivegreen"] = 0x556B2F;
		colors["darkorange"] = 0xFF8C00;
		colors["darkorchid"] = 0x9932CC;
		colors["darkred"] = 0x8B0000;
		colors["darksalmon"] = 0xE9967A;
		colors["darkseagreen"] = 0x8FBC8F;
		colors["darkslateblue"] = 0x483D8B;
		colors["darkslategray"] = 0x2F4F4F;
		colors["darkslategrey"] = 0x2F4F4F;
		colors["darkturquoise"] = 0x00CED1;
		colors["darkviolet"] = 0x9400D3;
		colors["deeppink"] = 0xFF1493;
		colors["deepskyblue"] = 0x00BFFF;
		colors["dimgray"] = 0x696969;
		colors["dimgrey"] = 0x696969;
		colors["dodgerblue"] = 0x1E90FF;
		colors["firebrick"] = 0xB22222;
		colors["floralwhite"] = 0xFFFAF0;
		colors["forestgreen"] = 0x228B22;
		colors["fuchsia"] = 0xFF00FF;
		colors["gainsboro"] = 0xDCDCDC;
		colors["ghostwhite"] = 0xF8F8FF;
		colors["gold"] = 0xFFD700;
		colors["goldenrod"] = 0xDAA520;
		colors["gray"] = 0x808080;
		colors["grey"] = 0x808080;
		colors["green"] = 0x008000;
		colors["greenyellow"] = 0xADFF2F;
		colors["honeydew"] = 0xF0FFF0;
		colors["hotpink"] = 0xFF69B4;
		colors["indianred"] = 0xCD5C5C;
		colors["indigo"] = 0x4B0082;
		colors["ivory"] = 0xFFFFF0;
		colors["khaki"] = 0xF0E68C;
		colors["lavender"] = 0xE6E6FA;
		colors["lavenderblush"] = 0xFFF0F5;
		colors["lawngreen"] = 0x7CFC00;
		colors["lemonchiffon"] = 0xFFFACD;
		colors["lightblue"] = 0xADD8E6;
		colors["lightcoral"] = 0xF08080;
		colors["lightcyan"] = 0xE0FFFF;
		colors["lightgoldenrodyellow"] = 0xFAFAD2;
		colors["lightgray"] = 0xD3D3D3;
		colors["lightgrey"] = 0xD3D3D3;
		colors["lightgreen"] = 0x90EE90;
		colors["lightpink"] = 0xFFB6C1;
		colors["lightsalmon"] = 0xFFA07A;
		colors["lightseagreen"] = 0x20B2AA;
		colors["lightskyblue"] = 0x87CEFA;
		colors["lightslategray"] = 0x778899;
		colors["lightslategrey"] = 0x778899;
		colors["lightsteelblue"] = 0xB0C4DE;
		colors["lightyellow"] = 0xFFFFE0;
		colors["lime"] = 0x00FF00;
		colors["limegreen"] = 0x32CD32;
		colors["linen"] = 0xFAF0E6;
		colors["magenta"] = 0xFF00FF;
		colors["maroon"] = 0x800000;
		colors["mediumaquamarine"] = 0x66CDAA;
		colors["mediumblue"] = 0x0000CD;
		colors["mediumorchid"] = 0xBA55D3;
		colors["mediumpurple"] = 0x9370D8;
		colors["mediumseagreen"] = 0x3CB371;
		colors["mediumslateblue"] = 0x7B68EE;
		colors["mediumspringgreen"] = 0x00FA9A;
		colors["mediumturquoise"] = 0x48D1CC;
		colors["mediumvioletred"] = 0xC71585;
		colors["midnightblue"] = 0x191970;
		colors["mintcream"] = 0xF5FFFA;
		colors["mistyrose"] = 0xFFE4E1;
		colors["moccasin"] = 0xFFE4B5;
		colors["navajowhite"] = 0xFFDEAD;
		colors["navy"] = 0x000080;
		colors["oldlace"] = 0xFDF5E6;
		colors["olive"] = 0x808000;
		colors["olivedrab"] = 0x6B8E23;
		colors["orange"] = 0xFFA500;
		colors["orangered"] = 0xFF4500;
		colors["orchid"] = 0xDA70D6;
		colors["palegoldenrod"] = 0xEEE8AA;
		colors["palegreen"] = 0x98FB98;
		colors["paleturquoise"] = 0xAFEEEE;
		colors["palevioletred"] = 0xD87093;
		colors["papayawhip"] = 0xFFEFD5;
		colors["peachpuff"] = 0xFFDAB9;
		colors["peru"] = 0xCD853F;
		colors["pink"] = 0xFFC0CB;
		colors["plum"] = 0xDDA0DD;
		colors["powderblue"] = 0xB0E0E6;
		colors["purple"] = 0x800080;
		colors["red"] = 0xFF0000;
		colors["rosybrown"] = 0xBC8F8F;
		colors["royalblue"] = 0x4169E1;
		colors["saddlebrown"] = 0x8B4513;
		colors["salmon"] = 0xFA8072;
		colors["sandybrown"] = 0xF4A460;
		colors["seagreen"] = 0x2E8B57;
		colors["seashell"] = 0xFFF5EE;
		colors["sienna"] = 0xA0522D;
		colors["silver"] = 0xC0C0C0;
		colors["skyblue"] = 0x87CEEB;
		colors["slateblue"] = 0x6A5ACD;
		colors["slategray"] = 0x708090;
		colors["slategrey"] = 0x708090;
		colors["snow"] = 0xFFFAFA;
		colors["springgreen"] = 0x00FF7F;
		colors["steelblue"] = 0x4682B4;
		colors["tan"] = 0xD2B48C;
		colors["teal"] = 0x008080;
		colors["thistle"] = 0xD8BFD8;
		colors["tomato"] = 0xFF6347;
		colors["turquoise"] = 0x40E0D0;
		colors["violet"] = 0xEE82EE;
		colors["wheat"] = 0xF5DEB3;
		colors["white"] = 0xFFFFFF;
		colors["whitesmoke"] = 0xF5F5F5;
		colors["yellow"] = 0xFFFF00;
		colors["yellowgreen"] = 0x9ACD32;

		public static function getColorByName(name:String):uint {
			return colors[name.toLowerCase()];
		}
		
		public static function parseToUint(s:String):uint {
			if(s==null)
				return 0x000000;
				
			s = StringUtil.trim(s);
			
			if(s=="none" || s==""){
				return 0x000000;
			} else if(s.charAt(0)=="#") {
				s = s.substring(1);
				if(s.length<6)
					s = s.charAt(0)+s.charAt(0)+s.charAt(1)+s.charAt(1)+s.charAt(2)+s.charAt(2);
				return new uint("0x" + s);
			} else if(s.indexOf("(")>-1){
				s = /\((.*?)\)/.exec(s)[1];
				var args:Vector.<String> = SVGParserCommon.splitNumericArgs(s);
				return uint(args[0]) << 16 | uint(args[1]) << 8 | uint(args[2]);
			} else {
				return getColorByName(s);
			}
		}
		
		public static function uintToSVG(color:uint):String{
			var colorText:String = color.toString(16);
			while (colorText.length < 6) {
				colorText = "0" + colorText;
			}
			return "#"+colorText;
		}
	}
}