package com.lorentz.SVG.display.base
{
	import com.lorentz.SVG.data.gradients.SVGGradient;
	import com.lorentz.SVG.data.gradients.SVGLinearGradient;
	import com.lorentz.SVG.data.gradients.SVGRadialGradient;
	import com.lorentz.SVG.display.SVGPattern;
	import com.lorentz.SVG.drawing.DashedDrawer;
	import com.lorentz.SVG.events.SVGEvent;
	import com.lorentz.SVG.parser.SVGParserCommon;
	import com.lorentz.SVG.utils.SVGColorUtils;
	import com.lorentz.SVG.utils.SVGUtil;
	import com.lorentz.SVG.utils.StringUtil;
	
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.InterpolationMethod;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class SVGGraphicsElement extends SVGElement {
		private var _renderInvalidFlag:Boolean = false;
		
		public function SVGGraphicsElement(tagName:String){
			super(tagName);
		}
		
		public function invalidateRender():void {
			if(!_renderInvalidFlag)
			{
				_renderInvalidFlag = true;
				invalidateProperties();
			}
		}
		
		override protected function commitProperties():void {
			super.commitProperties();
			
			if(_renderInvalidFlag)
				render();
		}
		
		override protected function onStyleChanged(styleName:String, oldValue:String, newValue:String):void {
			super.onStyleChanged(styleName, oldValue, newValue);
			
			switch(styleName){
				case "stroke" :
				case "stroke-opacity" :
				case "stroke-width" :
				case "stroke-linecap" :
				case "stroke-linejoin" :
				case "stroke-dasharray" :
				case "stroke-dashoffset" :
				case "stroke-dashalign" :
				case "fill" :
				case "marker" :
				case "marker-start" :
				case "marker-mid" :
				case "marker-end" :
					invalidateRender();
					break;
			}
		}
		
		protected function render():void {
			_renderInvalidFlag = false;
		}
		
		protected function get hasFill():Boolean {
			var fill:String = finalStyle.getPropertyValue("fill"); 
			return fill != "" && fill != "none" || isInClipPath(); 
		}
		
		protected function get hasStroke():Boolean {
			var stroke:String = finalStyle.getPropertyValue("stroke");
			return stroke != null && stroke != "" && stroke != "none" && !isInClipPath();
		}
		
		protected function get hasDashedStroke():Boolean {
			var strokeDashArray:String = finalStyle.getPropertyValue("stroke-dasharray");
			return strokeDashArray != null && strokeDashArray != "none";
		}
		
		protected function configureDashedDrawer(dashedDrawer:DashedDrawer):void {
			if(!hasDashedStroke)
				return;
			
			var strokeDashArray:Array = [];
			for each(var length:String in SVGParserCommon.splitNumericArgs(finalStyle.getPropertyValue("stroke-dasharray"))){
				strokeDashArray.push(getViewPortUserUnit(length, SVGUtil.WIDTH_HEIGHT));
			}
			
			dashedDrawer.dashArray = strokeDashArray;
			
			dashedDrawer.dashOffset = Number(finalStyle.getPropertyValue("stroke-dashoffset") || 0);
			
			var dashAlign:String = String(finalStyle.getPropertyValue("stroke-dashalign") || "none").toLowerCase();
			dashedDrawer.alignToCorners = dashAlign == "corners";
		}
		
		protected function beginFill(g:Graphics = null, callBack:Function = null):void {
			if(hasFill){
				var fill:String = finalStyle.getPropertyValue("fill");
				
				var fillOpacity:Number = Number(finalStyle.getPropertyValue("fill-opacity") || 1);
				
				if(fill == null){
					g.beginFill(0x000000, fillOpacity); //Default value to fill is black
				}
				else if(fill.indexOf("url") > -1)
				{
					var id:String = SVGUtil.extractUrlId(fill);
					
					var grad:SVGGradient = document.getDefinition(id) as SVGGradient;										
					if(grad != null){
						switch(grad.type){
							case GradientType.LINEAR:
								doLinearGradient(grad as SVGLinearGradient, g, true);
								break;

							case GradientType.RADIAL:
								var rgrad:SVGRadialGradient = grad as SVGRadialGradient;
								if(rgrad.r == "0")
									g.beginFill(grad.colors[grad.colors.length-1], grad.alphas[grad.alphas.length-1]);
								else
									doRadialGradient(rgrad, g, true);
								break;
						}
						
						if(callBack != null)
							callBack();
						
						return;
					}
					
					var pattern:SVGPattern = document.getDefinitionClone(id) as SVGPattern;
					if(pattern){
						attachElement(pattern);
						
						var patternValidated:Function = function(e:Event):void {
							pattern.removeEventListener(SVGEvent.VALIDATED, patternValidated);
							
							pattern.beginFill(g);
							
							detachElement(pattern);
							if(callBack != null)
								callBack();
						};
						pattern.addEventListener(SVGEvent.VALIDATED, patternValidated);
						pattern.validate();
						return;
					}
				} else {
					var color:uint = SVGColorUtils.parseToUint(fill);
					g.beginFill(color, fillOpacity);
				}
			}
			
			if(callBack != null)
				callBack();
		}
		
		protected function lineStyle(g:Graphics):void {
			if(hasStroke) {
				var strokeOpacity:Number = Number(finalStyle.getPropertyValue("stroke-opacity") || 1);
				
				var strokeWidth:Number = 1;
				if(finalStyle.getPropertyValue("stroke-width"))
					strokeWidth = getViewPortUserUnit(finalStyle.getPropertyValue("stroke-width"), SVGUtil.WIDTH_HEIGHT);
				
				var strokeLineCap:String = CapsStyle.NONE;
				if(finalStyle.getPropertyValue("stroke-linecap")){
					switch(StringUtil.trim(finalStyle.getPropertyValue("stroke-linecap")).toLowerCase()){
						case "round" :
							strokeLineCap = CapsStyle.ROUND;
							break;
						case "square" :
							strokeLineCap = CapsStyle.SQUARE;
							break;
					}
				}
				
				var strokeLineJoin:String = JointStyle.MITER;				
				if(finalStyle.getPropertyValue("stroke-linejoin")){
					switch(StringUtil.trim(finalStyle.getPropertyValue("stroke-linejoin")).toLowerCase()){
						case "round" :
							strokeLineJoin = JointStyle.ROUND;
							break;
						case "bevel" :
							strokeLineJoin = JointStyle.BEVEL;
							break;
					}
				}
				
				var strokeMiterlimit:Number = Number(finalStyle.getPropertyValue("stroke-miterlimit") || 4);
				
				var stroke:String = finalStyle.getPropertyValue("stroke");
				
				var color:uint = SVGColorUtils.parseToUint(stroke);
				g.lineStyle(strokeWidth, color, strokeOpacity, true, LineScaleMode.NORMAL, strokeLineCap, strokeLineJoin, strokeMiterlimit);
				
				if(stroke.indexOf("url") > -1){
					var id:String = SVGUtil.extractUrlId(stroke);
					
					var grad:SVGGradient = document.getDefinition(id) as SVGGradient;
					
					if(grad != null){
						switch(grad.type){
							case GradientType.LINEAR: {
								doLinearGradient(grad as SVGLinearGradient, g, false);
								break;
							}
							case GradientType.RADIAL: {
								var rgrad:SVGRadialGradient = grad as SVGRadialGradient;
								if(rgrad.r == "0")
									g.lineStyle(strokeWidth, grad.colors[grad.colors.length-1], grad.alphas[grad.alphas.length-1], true, LineScaleMode.NORMAL, strokeLineCap, strokeLineJoin, strokeMiterlimit);
								else
									doRadialGradient(rgrad, g, false);
								break;
							}
						}
					}
				} 
			} else {
				g.lineStyle();
			}
		}
		
		protected function getObjectBounds():Rectangle {
			return new Rectangle();
		}
		
		private function doLinearGradient(grad:SVGLinearGradient, g:Graphics, fill:Boolean = true):void {
			var x1:Number;
			var y1:Number;
			var x2:Number;
			var y2:Number;
			
			if(grad.gradientUnits.toLowerCase() == "objectboundingbox") {
				var bounds:Rectangle = getObjectBounds();
				
				x1 = SVGUtil.getUserUnit(grad.x1, currentFontSize, bounds.width, bounds.height, SVGUtil.WIDTH) + bounds.x;
				y1 = SVGUtil.getUserUnit(grad.y1, currentFontSize, bounds.width, bounds.height, SVGUtil.HEIGHT) + bounds.y;
				x2 = SVGUtil.getUserUnit(grad.x2, currentFontSize, bounds.width, bounds.height, SVGUtil.WIDTH) + bounds.x;
				y2 = SVGUtil.getUserUnit(grad.y2, currentFontSize, bounds.width, bounds.height, SVGUtil.HEIGHT) + bounds.y;
			} else {
				x1 = getViewPortUserUnit(grad.x1, SVGUtil.WIDTH);
				y1 = getViewPortUserUnit(grad.y1, SVGUtil.HEIGHT);
				x2 = getViewPortUserUnit(grad.x2, SVGUtil.WIDTH);
				y2 = getViewPortUserUnit(grad.y2, SVGUtil.HEIGHT);
			}
			
			var mat:Matrix = SVGUtil.flashLinearGradientMatrix(x1, y1, x2, y2);
			if(grad.transform)
				mat.concat(grad.transform);
			
			if(fill)
				g.beginGradientFill(grad.type, grad.colors, grad.alphas, grad.ratios, mat, grad.spreadMethod, InterpolationMethod.RGB);
			else
				g.lineGradientStyle(grad.type, grad.colors, grad.alphas, grad.ratios, mat, grad.spreadMethod, InterpolationMethod.RGB);
		}
		
		private function doRadialGradient(grad:SVGRadialGradient, g:Graphics, fill:Boolean = true):void {			
			var cx:Number = getViewPortUserUnit(grad.cx, SVGUtil.WIDTH);
			var cy:Number = getViewPortUserUnit(grad.cy, SVGUtil.HEIGHT);
			var r:Number = getViewPortUserUnit(grad.r, SVGUtil.WIDTH);
			var fx:Number = getViewPortUserUnit(grad.fx, SVGUtil.WIDTH);
			var fy:Number = getViewPortUserUnit(grad.fy, SVGUtil.HEIGHT);
			
			var mat:Matrix = SVGUtil.flashRadialGradientMatrix(cx, cy, r, fx, fy);
			if(grad.transform)
				mat.concat(grad.transform);
			
			var dx:Number = fx-cx;
			var dy:Number = fy-cy;
			var focalRatio:Number = Math.sqrt( (dx*dx)+(dy*dy) )/r;
			
			if(fill)
				g.beginGradientFill(grad.type, grad.colors, grad.alphas, grad.ratios, mat, grad.spreadMethod, InterpolationMethod.RGB, focalRatio);
			else
				g.lineGradientStyle(grad.type, grad.colors, grad.alphas, grad.ratios, mat, grad.spreadMethod, InterpolationMethod.RGB, focalRatio);
		}
	}
}