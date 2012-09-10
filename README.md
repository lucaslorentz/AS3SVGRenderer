AS3SVGRenderer
==============

An AS3 SVG Renderer for Flash Player.

It parses and translates svg elements to Flash display objects. Rendering it and letting you interact with the output.

Requirements:
* Flash Player 10+

Features:
* Supports basic shapes and paths.
* Supports texts, right-to-left scripts, subscript, superscript.
* Has 3 text renderers engines (TextField, TLF, FTE), supports CFF and non-CFF fonts.
* Supports coordinates system rules, transformations and units.
* Supports masking and clipping.
* Supports filling, strokes, gradients.
* Supports marker symbols.
* Supports basic document structure (g, defs, symbol, use, image).
* Rendered display objects keeps the svg structure, so you can code mouse/touch interactions with svg elements.
* AS3 only.
* Flex component.

Missing features:
* Text stroke.
* Filters.
* Scripting.
* Animation.

INTRODUCTION
==============

The library has classes that represents each SVG element.
Those classes and the SVG element has similar properties and styles.
The SVGDocument class is the class responsible to hold the SVG display object tree.
The library has an asynchronously parser that processes the SVG file and create all necessary display objects.
The library also uses deferred rendering. So, the graphics will only have the final rendering after RENDERED event, not after PARSE_COMPLETE event.
You can listen to the RENDERED event to know when graphics was completely rendered for the first time.

USAGE
==============

AS3 only (without flex)
----------

1) The first thing you have to do is initialize the ProcessExecutor, that class is responsible to distribute the library processing between frames, that way the application will not get frozen while showing large SVG files. You have to do that only once in the whole application.

Example:
  ProcessExecutor.instance.initialize(stage);

2) Now you can load any SVG file into the SVGDocument using the load method.
Example:
  var svg:SVGDocument = new SVGDocument();
  svg.load(urlStringOrUrlRequest);
  addChild(svg);

Or if you already have the svg content string, use the parse method of SVGDocument class.
Example:
  var svg:SVGDocument = new SVGDocument();
  svg.parse(myLoadedSVGString);
  addChild(svg);

You can also pass an XML object to the parse method, but it isn't recommended once when the parse method gets a string it does extra things to better parse the string.

Flex component
----------

1) Just add the SVG component to your MXML, and set the property "Source" on the component with:
  * A string with the URL of the SVG file.
  * A urlRequest to achieve the SVG file.
  * A string with the content of the SVG file.
  * A XML object with the content of the SVG file (not recommended).

After that, the SVG file will appear on the screen.

LICENSE
==============
Licensed under the MIT License.
http://opensource.org/licenses/mit-license.php
