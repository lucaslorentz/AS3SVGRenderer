package com.lorentz.SVG.utils
{

	public class StringUtil
	{
		/**
		*	Removes whitespace from the front and the end of the specified
		*	string.
		* 
		*	@param input The String whose beginning and ending whitespace will
		*	will be removed.
		*
		*	@returns A String with whitespace removed from the begining and end	
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/
		public static function trim(input:String, char:String=" "):String
		{
			return StringUtil.ltrim(StringUtil.rtrim(input, char), char);
		}

		/**
		*	Removes whitespace from the front of the specified string.
		* 
		*	@param input The String whose beginning whitespace will will be removed.
		*
		*	@returns A String with whitespace removed from the begining	
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/	
		public static function ltrim(input:String, char:String=" "):String
		{
			var size:Number = input.length;
			for(var i:Number = 0; i < size; i++)
			{
				if(input.charAt(i) != char)
				{
					return input.substring(i);
				}
			}
			return "";
		}

		/**
		*	Removes whitespace from the end of the specified string.
		* 
		*	@param input The String whose ending whitespace will will be removed.
		*
		*	@returns A String with whitespace removed from the end	
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/	
		public static function rtrim(input:String, char:String=" "):String
		{
			var size:Number = input.length;
			for(var i:Number = size; i > 0; i--)
			{
				if(input.charAt(i-1) != char)
				{
					return input.substring(0, i);
				}
			}

			return "";
		}

		/**
		*	Removes all instances of the remove string in the input string.
		* 
		*	@param input The string that will be checked for instances of remove
		*	string
		*
		*	@param remove The string that will be removed from the input string.
		*
		*	@returns A String with the remove string removed.
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/	
		public static function remove(input:String, remove:String):String
		{
			return StringUtil.replace(input, remove, "");
		}

		/**
		*	Replaces all instances of the replace string in the input string
		*	with the replaceWith string.
		* 
		*	@param input The string that instances of replace string will be 
		*	replaces with removeWith string.
		*
		*	@param replace The string that will be replaced by instances of 
		*	the replaceWith string.
		*
		*	@param replaceWith The string that will replace instances of replace
		*	string.
		*
		*	@returns A new String with the replace string replaced with the 
		*	replaceWith string.
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 9.0
		*	@tiptext
		*/
		public static function replace(input:String, replace:String, replaceWith:String):String
		{
			//change to StringBuilder
			var sb:String = new String();
			var found:Boolean = false;

			var sLen:Number = input.length;
			var rLen:Number = replace.length;

			for (var i:Number = 0; i < sLen; i++)
			{
				if(input.charAt(i) == replace.charAt(0))
				{   
					found = true;
					for(var j:Number = 0; j < rLen; j++)
					{
						if(!(input.charAt(i + j) == replace.charAt(j)))
						{
							found = false;
							break;
						}
					}

					if(found)
					{
						sb += replaceWith;
						i = i + (rLen - 1);
						continue;
					}
				}
				sb += input.charAt(i);
			}
			//TODO : if the string is not found, should we return the original
			//string?
			return sb;
		}
		
			
		/**
		* @method shrinkSequencesOf (Groleau)
		* @description Shrinks all sequences of a given character in a string to one
		* @param s (String) original string
		* @param ch (String) character to be found
		* @returns (String) string with sequences shrunk
		*/
		public static function shrinkSequencesOf(s:String, ch:String):String {
			var len:int = s.length;
			var idx:int = 0;
			var idx2:int = 0;
			var rs:String = "";
			
			while ((idx2 = s.indexOf(ch, idx) + 1) != 0) {
				// include string up to first character in sequence
				rs += s.substring(idx, idx2);
				idx = idx2;
				
				// remove all subsequent characters in sequence
				while ((s.charAt(idx) == ch) && (idx < len)) idx++;
			}
			return rs + s.substring(idx, len);	
		}
	}
}