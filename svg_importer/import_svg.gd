tool
extends EditorPlugin

# Source boilerplate came from
# https://github.com/TheHX/godot_examples/tree/master/Import%20Object

class EditorImportDialog:
    extends ConfirmationDialog
    
    var import_path
    var save_path
    
    var file_select
    var save_select
    
    var plugin
    
    func popup_import(from):
        import_path.set_text('')
        save_path.set_text('')
        
        show()
        popup_centered()
        
    func _source_path():
        file_select.show()
        file_select.popup_centered(Vector2(480, 560))
        
    func _choose_file(path):
        import_path.set_text(path)
        
    func _save_path():
        save_select.show()
        save_select.popup_centered(Vector2(480, 560))
        
    func _choose_save_dir(dir):
        save_path.set_text(dir)
        
    func _import():
        var path = import_path.get_text()
        
        var res_metadata = ResourceImportMetadata.new()
        
        res_metadata.add_source(path)
        
        var name = path.get_file()
        
        var target_path = save_path.get_text() + "/" + name.substr(0, name.find_last('.')) + '.png'
        print("Source path: " + path + ", name: " + name + ", target path: " + target_path)
        
        plugin.import(target_path, res_metadata)
        
    func _init(import_plugin):
        plugin = import_plugin
        
        set_title("Import SVG as PNG")
        
        var vbox = VBoxContainer.new()
        vbox.set_area_as_parent_rect(get_constant("margin","Dialogs"))
        vbox.set_margin(MARGIN_BOTTOM, get_constant("button_margin","Dialogs")+10)
        
        var hbox = HBoxContainer.new()
        hbox.set_h_size_flags(SIZE_EXPAND_FILL)
        
        var label = Label.new()
        label.set_text("Source SVG: ")
        vbox.add_child(label)
        
        import_path = LineEdit.new()
        import_path.set_h_size_flags(SIZE_EXPAND_FILL)
        hbox.add_child(import_path)
        var button_choose = Button.new()
        button_choose.set_text('...')
        hbox.add_child(button_choose)
        
        button_choose.connect("pressed", self, "_source_path")
        
        vbox.add_child(hbox)
        
        hbox = HBoxContainer.new()
        hbox.set_h_size_flags(SIZE_EXPAND_FILL)
        
        label = Label.new()
        label.set_text("Target Path: ")
        vbox.add_child(label)
        
        save_path = LineEdit.new()
        save_path.set_h_size_flags(SIZE_EXPAND_FILL)
        hbox.add_child(save_path)
        var button_save = Button.new()
        button_save.set_text('...')
        hbox.add_child(button_save)
        
        button_save.connect("pressed", self, "_save_path")
        
        vbox.add_child(hbox)
        
        add_child(vbox)
        
        set_size(Vector2(300, 140))
        
        file_select = FileDialog.new()
        file_select.set_access(file_select.ACCESS_FILESYSTEM)
        add_child(file_select)
        
        file_select.set_mode(file_select.MODE_OPEN_FILE)
        file_select.add_filter("*.svg;Scalable Vector Graphics")
        
        file_select.connect("file_selected", self, "_choose_file")
        
        save_select = FileDialog.new()
        add_child(save_select)
        
        save_select.set_mode(save_select.MODE_OPEN_DIR)
        #save_select.add_filter("*.png;Image")
        
        save_select.connect("dir_selected", self, "_choose_save_dir")
        
        get_ok().connect("pressed", self, "_import")
        
class EditorImportSvg:
    extends EditorImportPlugin
    
    
    
    var source_screen_res = Vector2(1280, 800)

    # TODO pull from the project settings the display/width and display/height
    # For now, this is hard-coded
    var dest_screen_res = Vector2(1280, 800)

    var inkscape_path = "C:/Program Files (x86)/Inkscape/inkscape.exe"
    
    
    
    var dialog
    var has_index_data = false
    
    #The name of plugin
    func get_name():
        return "SVG"
        
    #The name that will appear in Import Menu
    func get_visible_name():
        return "SVG"
        
    #This is what the plugin will do when it was selected on menu
    func import_dialog(from):
        print(from)
        dialog.popup_import(from)
        
    #Here is the import function
    func import(path, from):
        assert( from.get_source_count() == 1 )
        
        # TODO inspect the SVG file in case the src/dest image sizes don't
        # match, and compute the screen scaling ratio.
        # That will be passed in under the "--export-width=" argument.
        
        var output_file = Globals.globalize_path(path)
        print("Converting " + from.get_source_path(0) + " to " + output_file)
        
        var args = StringArray(['--file=' + from.get_source_path(0), '--export-png=' + output_file, '--export-area-page'])
        
        var retcode = OS.execute(inkscape_path, args, true)
        if retcode != 0 and retcode < 10000:
            # TODO correct error response
            print("Error converting: " + str(retcode))
            return 1
        
        var img = ResourceLoader.load(path)
        if img == null:
            # TODO correct error response
            print("Could not load file from " + path)
            return 1
        img.set_import_metadata(from)
        ResourceSaver.save(path, img)
        
    func _init(editor_node):
        dialog = EditorImportDialog.new(self)
        editor_node.get_gui_base().add_child(dialog)
        

var svg_import_plugin

func _enter_tree():
    var editor_node = get_node("/root/EditorNode")
    svg_import_plugin = EditorImportSvg.new(editor_node)
    editor_node.add_editor_import_plugin(svg_import_plugin)
    
func _exit_tree():
    var editor_node = get_node("/root/EditorNode")
    editor_node.remove_editor_import_plugin(svg_import_plugin)
