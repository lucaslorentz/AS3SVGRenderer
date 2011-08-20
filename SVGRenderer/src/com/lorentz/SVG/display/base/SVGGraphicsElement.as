package com.lorentz.SVG.display.base
{
	import com.lorentz.SVG.data.gradients.SVGGradient;
	import com.lorentz.SVG.data.gradients.SVGLinearGradient;
	import com.lorentz.SVG.data.gradients.SVGRadialGradient;
	import com.lorentz.SVG.display.SVGPattern;
	import com.lorentz.SVG.drawing.DashedDrawer;
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
	import flash.geom.Matrix;

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
					_renderInvalidFlag = true;
					invalidateProperties();
					break;
			}
		}
		
		protected function render():void {
			_renderInvalidFlag = false;
		}
		
		protected function get hasFill():Boolean {
			return _finalStyles["fill"] != "" && _finalStyles["fill"] != "none"; 
		}
		
		protected function get hasStroke():Boolean {
			return _finalStyles["stroke"] != null && _finalStyles["stroke"] != '' && _finalStyles["stroke"] != "none";
		}
		
		protected function get hasDashedStroke():Boolean {
			return _finalStyles["stroke-dasharray"] != null && _finalStyles["stroke-dasharray"] != "none";
		}
		
		protected function configureDashedDrawer(dashedDrawer:DashedDrawer):void {
			if(!hasDashedStroke)
				return;
			
			var strokeDashArray:Array = [];
			for each(var length:String in SVGParserCommon.splitNumericArgs(_finalStyles["stroke-dasharray"])){
				strokeDashArray.push(getUserUnit(length, SVGUtil.WIDTH_HEIGHT));
			}
			
			dashedDrawer.dashArray = strokeDashArray;
			
			dashedDrawer.dashOffset = Number(_finalStyles["stroke-dashoffset"] || 0);
			
			var dashAlign:String = String(_finalStyles["stroke-dashalign"] || "none").toLowerCase();
			dashedDrawer.alignToCorners = dashAlign == "corners";
		}
		
		protected function beginFill(g:Graphics=null):void {
			if(g==null)
				g = _content.graphics;
						
			if(hasFill){
				var fill:String = _finalStyles["fill"];
				
				var fillOpacity:Number = Number(_finalStyles["fill-opacity"] || 1);
				
				if(fill == null){
					g.beginFill(0x000000, fillOpacity); //Default value to fill is black
				}
				else if(fill.indexOf("url")>-1)
				{
					var id:String = SVGUtil.extractUrlId(fill);
					
					var grad:SVGGradient = document.gradients[id];
					var def:SVGElement = document.getDefinitionClone(id);
					
					if(grad != null){
						switch(grad.type){
							case GradientType.LINEAR: {
								doLinearGradient(grad as SVGLinearGradient, g, true);
								return;
							}
							case GradientType.RADIAL: {
								var rgrad:SVGRadialGradient = grad as SVGRadialGradient;
								if(rgrad.r == "0")
									g.beginFill(grad.colors[grad.colors.length-1], grad.alphas[grad.alphas.length-1]);
								else
									doRadialGradient(rgrad, g, true);
								return;
							}
						}
					} else if(def is SVGPattern){
						var bitmap:BitmapData = (def as SVGPattern).getBitmap();
						g.beginBitmapFill(bitmap);
					}
				} else {
					var color:uint = SVGColorUtils.parseToUint(fill);
					g.beginFill(color, fillOpacity);
				}
			}
		}
		
		protected function lineStyle(g:Graphics = null):void {
			if(g == null)
				g = _content.graphics;
					
			if(hasStroke) {
				var strokeOpacity:Number = Number(_finalStyles["stroke-opacity"] || 1);
				
				var strokeWidth:Number = 1;
				if(_finalStyles["stroke-width"])
					strokeWidth = getUserUnit(_finalStyles["stroke-width"], SVGUtil.WIDTH_HEIGHT);
				
				var strokeLineCap:String = CapsStyle.NONE;
				if(_finalStyles["stroke-linecap"]){
					switch(StringUtil.trim(_finalStyles["stroke-linecap"]).toLowerCase()){
						case "round" :
							strokeLineCap = CapsStyle.ROUND;
							break;
						case "square" :
							strokeLineCap = CapsStyle.SQUARE;
							break;
					}
				}
				
				var strokeLineJoin:String = JointStyle.MITER;				
				if(_finalStyles["stroke-linejoin"]){
					switch(StringUtil.trim(_finalStyles["stroke-linejoin"]).toLowerCase()){
						case "round" :
							strokeLineJoin = JointStyle.ROUND;
							break;
						case "bevel" :
							strokeLineJoin = JointStyle.BEVEL;
							break;
					}
				}
				
				if(_finalStyles.stroke.indexOf("url")>-1){
					var id:String = SVGUtil.extractUrlId(_finalStyles.stroke);
					
					var grad:SVGGradient = document.gradients[id];
					var def:SVGElement = document.getDefinitionClone(id);
					
					if(grad != null){
						switch(grad.type){
							case GradientType.LINEAR: {
								doLinearGradient(grad as SVGLinearGradient, g, false);
								break;
							}
							case GradientType.RADIAL: {
								var rgrad:SVGRadialGradient = grad as SVGRadialGradient;
								if(rgrad.r == "0")
									g.lineStyle(strokeWidth, grad.colors[grad.colors.length-1], grad.alphas[grad.alphas.length-1], true, LineScaleMode.NORMAL, strokeLineCap, strokeLineJoin);
								else
									doRadialGradient(rgrad, g, false);
								break;
							}
						}
					} else if(def is SVGPattern){
						var bitmap:BitmapData = (def as SVGPattern).getBitmap();
						g.lineBitmapStyle(bitmap);
					}
					return;
				} else {
					var color:uint = SVGColorUtils.parseToUint(_finalStyles.stroke);
					g.lineStyle(strokeWidth, color, strokeOpacity, true, LineScaleMode.NORMAL, strokeLineCap, strokeLineJoin);
				}
			} else {
				g.lineStyle();
			}
		}
		
		private function doLinearGradient(grad:SVGLinearGradient, g:Graphics, fill:Boolean = true):void {
			var x1:Number = getUserUnit(grad.x1, SVGUtil.WIDTH);
			var y1:Number = getUserUnit(grad.y1, SVGUtil.HEIGHT);
			var x2:Number = getUserUnit(grad.x2, SVGUtil.WIDTH);
			var y2:Number = getUserUnit(grad.y2, SVGUtil.HEIGHT);
			
			var mat:Matrix = SVGUtil.flashLinearGradientMatrix(x1, y1, x2, y2);
			if(grad.transform)
				mat.concat(grad.transform);
			
			if(fill)
				g.beginGradientFill(grad.type, grad.colors, grad.alphas, grad.ratios, mat, grad.spreadMethod, InterpolationMethod.RGB);
			else
				g.lineGradientStyle(grad.type, grad.colors, grad.alphas, grad.ratios, mat, grad.spreadMethod, InterpolationMethod.RGB);
		}
		
		private function doRadialGradient(grad:SVGRadialGradient, g:Graphics, fill:Boolean = true):void {			
			var cx:Number = getUserUnit(grad.cx, SVGUtil.WIDTH);
			var cy:Number = getUserUnit(grad.cy, SVGUtil.HEIGHT);
			var r:Number = getUserUnit(grad.r, SVGUtil.WIDTH);
			var fx:Number = getUserUnit(grad.fx, SVGUtil.WIDTH);
			var fy:Number = getUserUnit(grad.fy, SVGUtil.HEIGHT);
			
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