package com.lorentz.SVG.utils
{
	import flash.geom.Rectangle;

	public class SVGViewPortUtils
	{
		public static function getContentMetrics(viewPortBox:Rectangle, contentBox:Rectangle, contentAlign:String, meetOrSlice:String):Object
		{		
			var x:Number = viewPortBox.x;
			var y:Number = viewPortBox.y;
			var scaleX:Number = 1; 
			var scaleY:Number = 1;
			
			if(contentAlign == "none"){
				scaleX = viewPortBox.width/contentBox.width;
				scaleY = viewPortBox.height/contentBox.height;
			} else if(meetOrSlice == "meet"){
				scaleX = scaleY = Math.min(viewPortBox.width/contentBox.width, viewPortBox.height/contentBox.height); 
			} else if(meetOrSlice == "slice"){
				scaleX = scaleY = Math.max(viewPortBox.width/contentBox.width, viewPortBox.height/contentBox.height);
			}
			
			var xPart:String = contentAlign.substr(0, 4).toLowerCase();
			var yPart:String = contentAlign.substr(4, 4).toLowerCase();
			
			switch(xPart){
				//case "xmin" : x += 0; break;
				case "xmid" : x += viewPortBox.width/2 - contentBox.width*scaleX/2; break;
				case "xmax" : x += viewPortBox.width - contentBox.width*scaleX; break;
			}
			
			switch(yPart){
				//case "ymin" : y += 0; break;
				case "ymid" : y += viewPortBox.height/2 - contentBox.height*scaleY/2; break;
				case "ymax" : y += viewPortBox.height - contentBox.height*scaleY; break;
			}
			
			return {
				contentScaleX: scaleX,
				contentScaleY: scaleY,
				contentX: x,
				contentY: y
			};
		}
	}
}