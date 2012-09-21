package com.lorentz.SVG.utils
{
	import flash.geom.Rectangle;

	public class SVGViewPortUtils
	{
		public static function getContentMetrics(viewPortRect:Rectangle, contentBox:Rectangle, contentAlign:String, meetOrSlice:String):Object
		{		
			var scaleX:Number = 1; 
			var scaleY:Number = 1;
			
			if(contentAlign == "none"){
				scaleX = viewPortRect.width/contentBox.width;
				scaleY = viewPortRect.height/contentBox.height;
			} else if(meetOrSlice == "meet"){
				scaleX = scaleY = Math.min(viewPortRect.width/contentBox.width, viewPortRect.height/contentBox.height); 
			} else if(meetOrSlice == "slice"){
				scaleX = scaleY = Math.max(viewPortRect.width/contentBox.width, viewPortRect.height/contentBox.height);
			}
			
			var xPart:String = contentAlign.substr(0, 4).toLowerCase();
			var yPart:String = contentAlign.substr(4, 4).toLowerCase();
			
			var x:Number = -contentBox.left*scaleX;
			var y:Number = -contentBox.top*scaleY;
			
			switch(xPart){
				//case "xmin" : x += 0; break;
				case "xmid" : x += viewPortRect.width/2 - contentBox.width*scaleX/2; break;
				case "xmax" : x += viewPortRect.width - contentBox.width*scaleX; break;
			}
			
			switch(yPart){
				//case "ymin" : y += 0; break;
				case "ymid" : y += viewPortRect.height/2 - contentBox.height*scaleY/2; break;
				case "ymax" : y += viewPortRect.height - contentBox.height*scaleY; break;
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