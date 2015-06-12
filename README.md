# godot-plugins

Plugins for the Godot game engine.


All are CC0 1.0 Universal license (which essentially means it's public domain).


## `svg_importer`

Adds a "SVG" title under the "Import" menu.  This allows for importing SVG
files as PNG image resources in your `res://` path, and tying them together.

This runs [Inkscape](https://inkscape.org) in command-line mode to export the
SVG file into an image file.  You'll need to modify the `inkscape_path` variable
to point to your Inkscape install.

Currently, you'll need to monitor the debug output log to identify conversion
issues.

