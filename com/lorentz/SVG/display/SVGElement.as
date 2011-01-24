package com.lorentz.SVG.display {
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import com.lorentz.SVG.SVGUtil;
	import com.lorentz.SVG.SVGColor;
	import com.lorentz.SVG.StringUtil;
	
	public class SVGElement extends Sprite implements IDocumentSetable {
		public var type:String;
		public var id:String;
		public var svgClass:String;
		
		protected var _svgClipPathChanged:Boolean = false;
		protected var _svgClipPath:String;
		public function get svgClipPath():String {
			return _svgClipPath;
		}
		public function set svgClipPath(value:String):void {
			_svgClipPath = value;
			_svgClipPathChanged = true;
			invalidate();
		}
			
		protected var _style:Object = {};
		protected var _finalStyle:Object; //After inherit parent styles
		public function getStyle(name:String):Object {
			return _style[name];
		}
		public function getFinalStyle(name:String):Object {
			return _finalStyle(name);
		}
		public function setStyle(name:String, value:String):void {
			_style[name] = value;
			invalidate(true);
		}
		public function clearStyle(name:String):void {
			delete _style[name];
			invalidate(true);
		}
		public function getStyles():Object {
			return SVGUtil.cloneObject(_style);
		}
		public function getFinalStyles():Object {
			return SVGUtil.cloneObject(_finalStyle);
		}
		public function setStyles(objectStyles:Object):void {
			for(var p:String in objectStyles)
				_style[p] = objectStyles[p];
			invalidate(true);
		}
		public function clearStyles():void {
			_style = {};
			invalidate(true);
		}
		
		protected var _content:Sprite;
		protected var _mask:SVGElement;
				
		private var _currentViewBox:Rectangle;
		private var _currentFontSize:Number = Number.NaN;
		
		protected var _validateFunctions:Array = [];
		
		public function SVGElement(){
			initialize();
		}
		
		public function clone(deep:Boolean = true):SVGElement {
			var clazz:Class = flash.utils.getDefinitionByName(flash.utils.getQualifiedClassName(this)) as Class;
			
			var c:SVGElement = new clazz();

			if(deep){
				for(var i:int = 0; i<numChildren; i++){
					var child:SVGElement = getChildAt(i) as SVGElement;
					if(child!=null)
						c.addChild(child.clone(deep));
				}
			}
			
			c.type = type;
			c.id = id;
			c.svgClass = svgClass;
			c.svgClipPath = svgClipPath;
			c.setStyles(_style);
			
			c.transform = transform;
			
			return c;
		}
		
		protected function initialize():void {
			_content = new Sprite();
			$addChild(_content);
			
			if(this is SVGDocument)
				setDocument(this as SVGDocument);
				
			_validateFunctions.push(inheritStyles, commitProperties);
				
			addEventListener(Event.ADDED, addedHandler, false, 0, true);
			addEventListener(Event.REMOVED, removedHandler, false, 0, true);
		}
						
		protected function addedHandler(e:Event):void {
			var p:DisplayObjectContainer = this.parent;
			while(!(p is SVGElement) && p!=null)
				p = p.parent;

			_setParentElement(p as SVGElement);
		}
		
		protected function removedHandler(e:Event):void {
			_setParentElement(null);
		}
		
		private var _parentElement:SVGElement;
		public function get parentElement():SVGElement {
			return _parentElement;
		}
		private function _setParentElement(value:SVGElement):void {
			if(_parentElement != value){
				if(_parentElement != null) {
					_parentElement.numInvalidChildren -= _numInvalidChildren + int(_invalidFlag);
					_parentElement.numASyncValidations -= _numASyncValidations;
					if(!(this is SVGDocument))
						_parentElement.removeEventListener(SVGDisplayEvent.DOCUMENT_CHANGED, parentDocumentChangedHandler);
				}
				
				_parentElement = value;
				
				if(_parentElement != null) {
					_parentElement.numInvalidChildren += _numInvalidChildren + int(_invalidFlag);
					_parentElement.numASyncValidations += _numASyncValidations;
					if(!(this is SVGDocument))
						_parentElement.addEventListener(SVGDisplayEvent.DOCUMENT_CHANGED, parentDocumentChangedHandler, false, 0, true);
				}
				
				if(!(this is SVGDocument))
					setDocument(_parentElement!=null ? parentElement.document : null);
					
				invalidate();
				
				dispatchEvent(new SVGDisplayEvent(SVGDisplayEvent.PARENT_CHANGED));
			}
		}
		
		private var _document:SVGDocument;
		public function get document():SVGDocument {
			return _document;
		}
		public function setDocument(value:SVGDocument):void {
			if(_document != value){
				if(_document != null)
					dispatchEvent(new SVGDisplayEvent(SVGDisplayEvent.ELEMENT_REMOVED, true));
					
				_document = value;
				
				if(_document != null)
					dispatchEvent(new SVGDisplayEvent(SVGDisplayEvent.ELEMENT_ADDED, true));
					
				dispatchEvent(new SVGDisplayEvent(SVGDisplayEvent.DOCUMENT_CHANGED));
			}
		}
		
		protected function parentDocumentChangedHandler(e:SVGDisplayEvent):void {
			setDocument(parentElement.document);
		}
		
		private var _numInvalidChildren:int = 0;
		protected function get numInvalidChildren():int {
			return _numInvalidChildren;
		}
		protected function set numInvalidChildren(value:int):void {
			var d = value - _numInvalidChildren;
			_numInvalidChildren = value;
			if(_parentElement != null)
				_parentElement.numInvalidChildren += d;
				
			if(_numInvalidChildren == 0 && d != 0){
				dispatchEvent(new SVGDisplayEvent(SVGDisplayEvent.CHILDREN_SYNC_VALIDATED));
				if(_numASyncValidations == 0)
					dispatchEvent(new SVGDisplayEvent(SVGDisplayEvent.CHILDREN_VALIDATED));
			}
		}
		
		private var _numASyncValidations:int = 0;
		protected function get numASyncValidations():int {
			return _numASyncValidations;
		}
		protected function set numASyncValidations(value:int):void {
			var d = value - _numASyncValidations;
			_numASyncValidations = value;
			if(_parentElement != null)
				_parentElement.numASyncValidations += d;
				
			if(_numASyncValidations == 0 && d != 0) {
				dispatchEvent(new SVGDisplayEvent(SVGDisplayEvent.CHILDREN_ASYNC_VALIDATED));
				if(_numInvalidChildren == 0)
					dispatchEvent(new SVGDisplayEvent(SVGDisplayEvent.CHILDREN_VALIDATED));
			}
		}
				
		private var _invalidFlag:Boolean = false;
		public function get isInvalid():Boolean {
			return _invalidFlag;
		}
		public function invalidate(recursive:Boolean = false):void {
			if(!_invalidFlag){											
				_invalidFlag = true;
								
				if(_parentElement!=null)
					_parentElement.numInvalidChildren += 1;
					
				dispatchEvent(new SVGDisplayEvent(SVGDisplayEvent.INVALIDATE));
			}
			
			if(recursive) {
				for(var i:int = 0; i<numChildren; i++){
					var child:SVGElement = this.getChildAt(i) as SVGElement;
					if(child!=null)
						child.invalidate(recursive);
				}
			}
		}

		public function validate(recursive:Boolean = false):void {
			if(_document==null)
				return;
				
			if(_invalidFlag){
				dispatchEvent(new SVGDisplayEvent(SVGDisplayEvent.BEFORE_VALIDATE));
				
				for(var i:int = 0; i<_validateFunctions.length; i++){
					_validateFunctions[i]();
				}
				
				_invalidFlag = false;
				if(_parentElement!=null)
					_parentElement.numInvalidChildren -= 1;
				
				dispatchEvent(new SVGDisplayEvent(SVGDisplayEvent.VALIDATED));
			}
			
			if(_mask != null)
				_mask.validate(true);
			
			if(recursive && numInvalidChildren>0) {
				for(var j:int = 0; j<numChildren; j++){
					var child:SVGElement = this.getChildAt(j) as SVGElement;
					if(child!=null)
						child.validate(recursive);
				}
			}
		}
		
		protected var runningASyncValidations:Object = {};
		public function beginASyncValidation(validationId:String):void {
			if(runningASyncValidations[validationId]==null){
				runningASyncValidations[validationId] = true;
				numASyncValidations++;
			}
		}
		
		public function endASyncValidation(validationId:String):void {
			if(runningASyncValidations[validationId]!=null){
				numASyncValidations--;
				delete runningASyncValidations[validationId];
			}
		}

		protected function inheritStyles():void {
			if(_parentElement){
				_finalStyle = _parentElement._finalStyle; //Inherits parent style
			} else {
				_finalStyle = {};
			}

			if(document.styles[type]!=null){ //Merge with elements styles
				_finalStyle = SVGUtil.mergeObjects(_finalStyle, document.styles[type]);
			}
			
			if(svgClass){ //Merge with classes styles
				for each(var className:String in svgClass.split(" "))
					_finalStyle = SVGUtil.mergeObjects(_finalStyle, document.styles["."+className]);
			}

			if(_style) //Merge all styles with the style attribute
				_finalStyle = SVGUtil.mergeObjects(_finalStyle, _style);
		}
		
		protected function commitProperties():void {
			if(_finalStyle["display"]=="none" || _finalStyle["visibility"]=="hidden")
				visible = false;
			
			if(_finalStyle["font-size"]!=null)
				_currentFontSize = getUserUnit(_finalStyle["font-size"], SVGUtil.HEIGHT);
				
			if(this is IViewBox && (this as IViewBox).viewBox!=null)
				_currentViewBox = (this as IViewBox).viewBox;
			else if(_parentElement!=null)
				_currentViewBox = _parentElement._currentViewBox;
			
			
			if(_svgClipPathChanged){
				_svgClipPathChanged = false;
				if(_mask!=null) {
					_content.mask = null;
					$removeChild(_mask);
					_mask = null;
				}
					
				if(svgClipPath!=null && svgClipPath!="" && svgClipPath!="none"){
					var cId:String = StringUtil.rtrim(svgClipPath.split("(")[1], ")");
					cId = StringUtil.ltrim(cId, "#");

					_mask = document.getDefinitionClone(cId);
					$addChild(_mask);
					_content.mask = _mask;
				}
			}
		}
		
		protected function lineStyle(g:Graphics=null):void {
			if(g==null)
				g = _content.graphics;
				
			var color:uint = SVGColor.parseToInt(_finalStyle.stroke);
			var noStroke:Boolean = _finalStyle.stroke==null || _finalStyle.stroke == '' || _finalStyle.stroke=="none";

			var stroke_opacity:Number = Number(_finalStyle["opacity"]?_finalStyle["opacity"]: (_finalStyle["stroke-opacity"]? _finalStyle["stroke-opacity"] : 1));
						
			var w:Number = 1;
			if(_finalStyle["stroke-width"])
				w = getUserUnit(_finalStyle["stroke-width"], SVGUtil.WIDTH_HEIGHT);

			var stroke_linecap:String = CapsStyle.NONE;

			if(_finalStyle["stroke-linecap"]){
				var linecap:String = StringUtil.trim(_finalStyle["stroke-linecap"]).toLowerCase(); 
				if(linecap=="round")
					stroke_linecap = CapsStyle.ROUND;
				else if(linecap=="square")
					stroke_linecap = CapsStyle.SQUARE;
			}
				
			var stroke_linejoin:String = JointStyle.MITER;
			
			if(_finalStyle["stroke-linejoin"]){
				var linejoin:String = StringUtil.trim(_finalStyle["stroke-linejoin"]).toLowerCase(); 
				if(linejoin=="round")
					stroke_linejoin = JointStyle.ROUND;
				else if(linejoin=="bevel")
					stroke_linejoin = JointStyle.BEVEL;
			}
			
			if(!noStroke && _finalStyle.stroke.indexOf("url")>-1){
				var id:String = StringUtil.rtrim(String(_finalStyle.stroke).split("(")[1], ")");
				id = StringUtil.ltrim(id, "#");

				var grad:Object = document.gradients[id];
				var def:Object = document.defs[id];
				
				if(grad!=null){
					switch(grad.type){
						case GradientType.LINEAR: {
							calculateLinearGradient(grad);
	
							g.lineGradientStyle(grad.type, grad.colors, grad.alphas, grad.ratios, grad.mat, grad.spreadMethod, "rgb");
							break;
						}
						case GradientType.RADIAL: {
							calculateRadialGradient(grad);
							
							if(grad.r==0)
								g.lineStyle(w, grad.colors[grad.colors.length-1], grad.alphas[grad.alphas.length-1], true, "none", stroke_linecap, stroke_linejoin);
							else
								g.lineGradientStyle(grad.type, grad.colors, grad.alphas, grad.ratios, grad.mat, grad.spreadMethod, "rgb", grad.focalRatio);
								
							break;
						}
					}
				} else if(def is SVGPattern){
					var bitmap:BitmapData = def.getBitmap();
					g.lineBitmapStyle(bitmap);
				}
				return;
			} else if(noStroke)
				g.lineStyle();
			else
				g.lineStyle(w, color, stroke_opacity, true, "normal", stroke_linecap, stroke_linejoin);
		}
		
		protected function beginFill(g:Graphics=null):void {
			if(g==null)
				g = _content.graphics;
				
			var fill_str:String = _finalStyle.fill;
			
			if(fill_str == "" || fill_str=="none"){
				return;
			} else {
				var fill_opacity:Number = Number(_finalStyle["opacity"]?_finalStyle["opacity"]: (_finalStyle["fill-opacity"]? _finalStyle["fill-opacity"] : 1));

				if(fill_str==null){
					g.beginFill(0x000000, fill_opacity); //Initial value to fill is black
					
				} else if(fill_str.indexOf("url")>-1){
					var id:String = StringUtil.rtrim(fill_str.split("(")[1], ")");
					id = StringUtil.ltrim(id, "#");
	
					var grad:Object = document.gradients[id];
					var def:Object = document.defs[id];
					
					if(grad!=null){
						switch(grad.type){
							case GradientType.LINEAR: {
								calculateLinearGradient(grad);
								
								g.beginGradientFill(grad.type, grad.colors, grad.alphas, grad.ratios, grad.mat, grad.spreadMethod, "rgb");
								
								return;
							}
							case GradientType.RADIAL: {
								calculateRadialGradient(grad);
							
								if(grad.r==0)
									g.beginFill(grad.colors[grad.colors.length-1], grad.alphas[grad.alphas.length-1]);
								else
									g.beginGradientFill(grad.type, grad.colors, grad.alphas, grad.ratios, grad.mat, grad.spreadMethod, "rgb", grad.focalRatio);
									
								return;
							}
						}
					} else if(def is SVGPattern){
						var bitmap:BitmapData = def.getBitmap();
						g.beginBitmapFill(bitmap);
					}
				} else {
					var color:uint = SVGColor.parseToInt(fill_str);
					g.beginFill(color, fill_opacity);
				}
			}
		}
		
		private function calculateLinearGradient(grad:Object):void {
			var x1:Number = getUserUnit(grad.x1, SVGUtil.WIDTH);
			var y1:Number = getUserUnit(grad.y1, SVGUtil.HEIGHT);
			var x2:Number = getUserUnit(grad.x2, SVGUtil.WIDTH);
			var y2:Number = getUserUnit(grad.y2, SVGUtil.HEIGHT);
			
			grad.mat = SVGUtil.flashLinearGradientMatrix(x1, y1, x2, y2);
			if(grad.transform)
				grad.mat.concat(grad.transform);
		}
				
		private function calculateRadialGradient(grad:Object):void {
			var cx:Number = getUserUnit(grad.cx, SVGUtil.WIDTH);
			var cy:Number = getUserUnit(grad.cy, SVGUtil.HEIGHT);
			var r:Number = getUserUnit(grad.r, SVGUtil.WIDTH);
			var fx:Number = getUserUnit(grad.fx, SVGUtil.WIDTH);
			var fy:Number = getUserUnit(grad.fy, SVGUtil.HEIGHT);
	
			grad.mat = SVGUtil.flashRadialGradientMatrix(cx, cy, r, fx, fy);
			if(grad.transform)
				grad.mat.concat(grad.transform);
			
			var f:* = { x:fx-cx, y:fy-cy };
			grad.focalRatio = Math.sqrt( (f.x*f.x)+(f.y*f.y) )/r;
		}
				
		protected function styleToTextFormat(style:Object):TextFormat {
			var sFontSize:String = style["font-size"];
			var sFont:String = style["font-family"];

			var tFormat:TextFormat = new TextFormat();
			tFormat.font = sFont == null? "Arial" : sFont;
			//tFormat.font = "Arial";
			tFormat.bold = style["font-weight"] != undefined ? true : false;
			tFormat.size = getFontSize(sFontSize==null ? "medium" : sFontSize);
			tFormat.color = SVGColor.parseToInt(style["fill"])
			
			return tFormat;
		}

		protected function getFontSize(s:String):Number{
			return SVGUtil.getFontSize(s, _currentFontSize, _currentViewBox);
		}
		

		protected function getUserUnit(s:String, viewBoxReference:String):Number {
			return SVGUtil.getUserUnit(s, _currentFontSize, _currentViewBox, viewBoxReference);
		}
		
		protected final function get $numChildren():int
	    {
	        return super.numChildren;
	    }
	    protected final function $addChild(child:DisplayObject):DisplayObject
	    {
	        return super.addChild(child);
	    }
		protected final function $addChildAt(child:DisplayObject, index:int):DisplayObject
	    {
	        return super.addChildAt(child, index);
	    }
	    protected final function $removeChild(child:DisplayObject):DisplayObject
	    {
	        return super.removeChild(child);
	    }
	    protected final function $removeChildAt(index:int):DisplayObject
	    {
	        return super.removeChildAt(index);
	    }
	    protected final function $getChildAt(index:int):DisplayObject
	    {
	        return super.getChildAt(index);
	    }
	    protected final function $getChildByName(name:String):DisplayObject
	    {
	        return super.getChildByName(name);
	    }
	    protected final function $getChildIndex(child:DisplayObject):int
	    {
	        return super.getChildIndex(child);
	    }
	    protected final function $setChildIndex(child:DisplayObject, newIndex:int):void
	    {
	    	super.setChildIndex(child, newIndex);
	    }	    
	    protected final function $contains(child:DisplayObject):Boolean
	    {
			return super.contains(child); 
	    }
	    protected final function $swapChildren(child1:DisplayObject, child2:DisplayObject):void {
	    	super.swapChildren(child1, child2);
	    }
	    protected final function $swapChildrenAt(index1:int, index2:int):void {
	    	super.swapChildrenAt(index1, index2);	
	    }
	    
	    override public function get numChildren():int
	    {
	        return _content.numChildren;
	    }
	    override public function addChild(child:DisplayObject):DisplayObject
	    {
	        return _content.addChild(child);
	    }
	    override public function addChildAt(child:DisplayObject, index:int):DisplayObject
	    {
	        return _content.addChildAt(child, index);
	    }
	    override public function removeChild(child:DisplayObject):DisplayObject
	    {
        	return _content.removeChild(child);
	    }
	    override public function removeChildAt(index:int):DisplayObject
	    {
	        return _content.removeChildAt(index);
	    }
	    override public function getChildAt(index:int):DisplayObject
	    {
	        return _content.getChildAt(index);
	    }
	    override public function getChildByName(name:String):DisplayObject
	    {
	        return _content.getChildByName(name);
	    }
	    override public function getChildIndex(child:DisplayObject):int
	    {
	        return _content.getChildIndex(child);
	    }
	    override public function setChildIndex(child:DisplayObject, newIndex:int):void
	    {
	    	_content.setChildIndex(child, newIndex);
	    }
	    override public function contains(child:DisplayObject):Boolean
	    {
	        return _content.contains(child);
	    }
	    override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void {
	        _content.swapChildren(child1, child2);
	    }
	    override public function swapChildrenAt(index1:int, index2:int):void {
	        _content.swapChildrenAt(index1, index2);	
	    }
	}
}