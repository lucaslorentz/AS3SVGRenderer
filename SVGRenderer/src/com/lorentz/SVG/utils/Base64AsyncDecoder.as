package com.lorentz.SVG.utils
{
	import com.lorentz.processing.IProcess;
	import com.lorentz.processing.Process;
	import com.lorentz.processing.ProcessExecutor;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.sampler.startSampling;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	/**
	 * A utility class to decode a Base64 encoded String to a ByteArray.
	 */
	public class Base64AsyncDecoder extends EventDispatcher
	{
		public static const COMPLETE:String = "complete";
		public static const ERROR:String = "fail";
		
		public var bytes:ByteArray;
		public var errorMessage:String;
		
		private var encoded:String;
		
		public function Base64AsyncDecoder(encoded:String)
		{
			super();
			this.encoded = encoded;
		}
		
		public function decode():void
		{
			new Process(startFunction, loopFunction, completeFunction).start();
		}
		
		private function startFunction():void
		{
			bytes = new ByteArray();
			count = 0;
			filled = 0;
			index = 0;
			errorMessage = null;
		}
		
		private function loopFunction():int {
			for(var z:int = 0; z < 100; z++){
				if(index == encoded.length)
					return Process.COMPLETE;
				
				var c:Number = encoded.charCodeAt(index++);
				
				if (c == ESCAPE_CHAR_CODE)
					work[count++] = -1;
				else if (inverse[c] != 64)
					work[count++] = inverse[c];
				else
					continue;
				
				if (count == 4)
				{
					count = 0;
					bytes.writeByte((work[0] << 2) | ((work[1] & 0xFF) >> 4));
					filled++;
					
					if (work[2] == -1)
						return Process.COMPLETE;
					
					bytes.writeByte((work[1] << 4) | ((work[2] & 0xFF) >> 2));
					filled++;
					
					if (work[3] == -1)
						return Process.COMPLETE;
					
					bytes.writeByte((work[2] << 6) | work[3]);
					filled++;
				}
			}
			return Process.CONTINUE;
		}
		
		private function completeFunction():void {
			if (count > 0)
			{
				this.errorMessage = "A partial block ("+count+" of 4 bytes) was dropped. Decoded data is probably truncated!";
				dispatchEvent(new Event(ERROR));
			} else {
				dispatchEvent(new Event(COMPLETE));
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private Variables
		//
		//--------------------------------------------------------------------------
		
		private var index:uint = 0;
		private var count:int = 0;
		private var filled:int = 0;
		private var work:Array = [0, 0, 0, 0];
		
		private static const ESCAPE_CHAR_CODE:Number = 61; // The '=' char
		
		private static const inverse:Array =
			[
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 62, 64, 64, 64, 63,
				52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 64, 64, 64, 64, 64, 64,
				64, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
				15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 64, 64, 64, 64, 64,
				64, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
				41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
				64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64
			];
	}	
}