package com.lorentz.SVG.display.base {
	import com.lorentz.SVG.drawing.DashedDrawer;
	import com.lorentz.SVG.drawing.GraphicsDrawer;
	import com.lorentz.SVG.drawing.GraphicsPathDrawer;
	import com.lorentz.SVG.drawing.IDrawer;
	
	import flash.display.Graphics;
	import flash.display.GraphicsPathWinding;

	public class SVGShape extends SVGGraphicsElement {
		public function SVGShape(tagName:String){
			super(tagName);
		}
		
		override protected function initialize():void {
			super.initialize();
			this.mouseChildren = false;
		}
		
		protected function draw(drawer:IDrawer):void {
		}
		
		protected function drawToGraphics(graphics:Graphics):void {
			
		}
		
		protected function get hasDrawToGraphics():Boolean {
			return false;
		}
				
		override protected function render():void {
			super.render();
			
			_content.graphics.clear();
			
			var winding:String = finalStyle.getPropertyValue("fill-rule") || "nonzero";
			switch (winding.toLowerCase())
			{
				case GraphicsPathWinding.EVEN_ODD.toLowerCase():
					winding = GraphicsPathWinding.EVEN_ODD;
					break;
				
				case GraphicsPathWinding.NON_ZERO.toLowerCase():
					winding = GraphicsPathWinding.NON_ZERO;
					break;
			}
			
			if(hasFill || (hasStroke && !hasDashedStroke)){					
					if(hasFill)
						beginFill();
					
					if(hasStroke && !hasDashedStroke)
						lineStyle();

					if(hasDrawToGraphics){
						drawToGraphics(_content.graphics);
					} else {
						var graphicsPathDrawer:GraphicsPathDrawer = new GraphicsPathDrawer();
						draw(graphicsPathDrawer);
						_content.graphics.drawPath(graphicsPathDrawer.commands, graphicsPathDrawer.pathData, winding);
					}
					
					_content.graphics.endFill();
			}
			
			if(hasDashedStroke){
				var dashedGraphicsPathDrawer:GraphicsPathDrawer = new GraphicsPathDrawer();
				var dashedDrawer:DashedDrawer = new DashedDrawer(dashedGraphicsPathDrawer);
				configureDashedDrawer(dashedDrawer);
				draw(dashedDrawer);
				
				lineStyle();
				
				_content.graphics.drawPath(dashedGraphicsPathDrawer.commands, dashedGraphicsPathDrawer.pathData, winding);
				_content.graphics.endFill();
			}
		}
	}
}