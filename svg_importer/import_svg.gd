tool
extends EditorPlugin

# Source boilerplate came from
# https://github.com/TheHX/godot_examples/tree/master/Import%20Object

class EditorImportSvg:
    extends EditorImportPlugin

    #The name of plugin
    func get_importer_name():
        return "inkscapesvg"

    #The name that will appear in Import Menu
    func get_visible_name():
        return "Inkscape SVG"

    func get_recognized_extensions():
        return ["svg"]

    func get_save_extension():
        return "tex"

    func get_resource_type():
        return "ImageTexture"

    func get_preset_count():
        return 0

    func get_import_options(preset):
        return []

    #Here is the import function
    func import(source_file, save_path, options, platform_variants, gen_files):

        var source = File.new()
        source.open(source_file, File.READ)
        source_file = source.get_path_absolute()
        source.close()
        var png = File.new()
        png.open(save_path + ".png", File.WRITE_READ)
        var png_file = png.get_path_absolute()
        png.close()
        var output = []
        var args = PoolStringArray(['--file=' + source_file, '--export-png=' + png_file, '--export-area-page'])

        var retcode = OS.execute("inkscape", args, true, output)
        if retcode == -1:
            printerr("Error converting: ", output)
            return 1

        var img = Image.new()
        var err = img.load(png_file)
        if err != 0:
            # TODO correct error response
            printerr("Failed (", err, ") to load image " + png_file)
            return 1

        var texture = ImageTexture.new()
        texture.create_from_image(img, Image.FORMAT_RGBA8)
        ResourceSaver.save(save_path + "." + get_save_extension(), texture)


var svg_import_plugin

func _enter_tree():
    svg_import_plugin = EditorImportSvg.new()
    add_import_plugin(svg_import_plugin)

func _exit_tree():
    remove_import_plugin(svg_import_plugin)
    svg_import_plugin = null
