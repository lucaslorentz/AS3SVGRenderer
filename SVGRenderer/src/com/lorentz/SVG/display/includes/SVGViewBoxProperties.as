import com.lorentz.SVG.display.base.ISVGViewPort;

import flash.geom.Rectangle;

private var _svgViewBox:Rectangle;
public function get svgViewBox():Rectangle {
	return _svgViewBox;
}
public function set svgViewBox(value:Rectangle):void {
	_svgViewBox = value;
}