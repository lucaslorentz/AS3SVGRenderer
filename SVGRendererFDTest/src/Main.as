package 
{
	import com.bit101.components.*;
	import com.lorentz.SVG.display.*;
	import com.lorentz.SVG.events.*;
	import com.lorentz.processing.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	
	public class Main extends Sprite 
	{
		private var vbox:VBox;
		private var list:List;
		private var radioSvg:RadioButton;
		private var radioPng:RadioButton;
		private var radioDifference:RadioButton;
		private var svgParent:Sprite;
		private var pngParent:Sprite;
		private var cookie:SharedObject = SharedObject.getLocal("cookie");
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			ProcessExecutor.instance.initialize(stage);
			
			var loader:URLLoader = new URLLoader(new URLRequest("../svglist.txt"));
			loader.addEventListener(Event.COMPLETE, onListLoaded);
			
			vbox = new VBox(this);
			
			new Label(vbox, 0, 0, "Show:");
			var cookieViewType:String = cookie.data.viewType;
			if (!cookieViewType)
				cookieViewType = "svg";
			
			radioSvg = new RadioButton(vbox, 0, 0, "Rendered by library", cookieViewType=="svg", onSmthChanged);
			radioPng = new RadioButton(vbox, 0, 0, "Rendered by inkscape", cookieViewType=="png", onSmthChanged);
			radioDifference = new RadioButton(vbox, 0, 0, "Difference", cookieViewType=="difference", onSmthChanged);
			radioSvg.groupName = radioPng.groupName = radioDifference.groupName = "viewWhat";
			
			
			new Label(vbox, 0, 0, "Svg file:");
			list = new List(vbox);
			vbox.width = list.width = 160;
			
			list.addEventListener(Event.SELECT, onSmthChanged);
			stage.addEventListener(Event.RESIZE, onStageResize);
			
			svgParent = new Sprite;
			svgParent.mouseEnabled = false;
			svgParent.mouseChildren = false;
			addChild(svgParent);

			pngParent = new Sprite;
			pngParent.mouseEnabled = false;
			pngParent.mouseChildren = false;
			addChild(pngParent);
			
			onStageResize(null);
			onSmthChanged(null);
		}
		
		private function onSmthChanged(e:Event):void 
		{
			while (pngParent.numChildren > 0)
				pngParent.removeChildAt(0);
			while (svgParent.numChildren > 0)
				svgParent.removeChildAt(0);
				
			svgParent.graphics.clear();
			pngParent.graphics.clear();
			pngParent.graphics.beginFill(0xFFFFFF)
			pngParent.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			svgParent.graphics.beginFill(0xFFFFFF)
			svgParent.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			var item:FileListItem = list.selectedItem as FileListItem;
			if (item)
			{
				cookie.data.selectedFile = item.label;
				
				item.load();
				
				pngParent.addChild(item.png);
				svgParent.addChild(item.svg);
			}
			
			if (radioSvg.selected)
			{
				cookie.data.viewType = "svg";
				
				svgParent.visible = true;
				svgParent.blendMode = BlendMode.NORMAL;
				pngParent.visible = false;
			}
			else if (radioPng.selected)
			{
				cookie.data.viewType = "png";
				
				pngParent.visible = true;
				pngParent.blendMode = BlendMode.NORMAL;
				svgParent.visible = false;
			}
			else if (radioDifference.selected)
			{
				cookie.data.viewType = "difference";
				
				svgParent.visible = true;
				pngParent.visible = true;
				svgParent.blendMode = BlendMode.NORMAL;
				pngParent.blendMode = BlendMode.DIFFERENCE;
			}
		}
		
		private function onStageResize(e:Event):void 
		{
			vbox.x = stage.stageWidth - vbox.width;
			list.height = stage.stageHeight - list.y;
			svgParent.scrollRect = pngParent.scrollRect = new Rectangle(0, 0, stage.stageWidth - vbox.width, stage.stageHeight);
			onSmthChanged(null);
		}
		
		private function onListLoaded(e:Event):void 
		{
			var loadedString:String = (e.target as URLLoader).data as String;
			loadedString = loadedString.split("\r\n").join("\n");
			loadedString = loadedString.split("\r").join("\n");
			var files:Array = loadedString.split("\n");
			
			for each(var fname:String in files)
				if(fname != "")
					list.addItem(new FileListItem(fname));
			
			if(cookie.data.hasOwnProperty("selectedFile"))
				for each(var item:FileListItem in list.items)
					if (item && item.label == cookie.data.selectedFile)
						list.selectedItem = item;
			if (list.selectedIndex < 0)
				list.selectedIndex = 0;
		}
	}
}

import com.lorentz.SVG.display.SVGDocument;
import flash.display.Loader;
import flash.net.URLRequest;

class FileListItem
{
	public var label:String;
	public var svg:SVGDocument; 
	public var png:Loader;
	
	public function FileListItem(fname:String) 
	{
		label = fname;
	}
	
	public function load():void 
	{
		if (!svg)
		{
			svg = new SVGDocument();
			svg.load("../svg-files/" + label);
		}
		if (!png)
		{
			png = new Loader();
			png.load(new URLRequest("../svg-files/" + label + ".png"));
		}
	}
}

