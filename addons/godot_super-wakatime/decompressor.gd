var Utils = preload("res://addons/godot_super-wakatime/utils.gd").new()

func decompressor_cli(current_decompressor, platform: String, plugin_path: String) -> String:
	"""Get path to the decompressor cli"""
	var build = Utils.get_ouch_build(platform)
	var ext: String = ".exe" if platform == "windows" else ""
		
	if current_decompressor == null:
		if platform == "windows":
			current_decompressor = "%s/%s%s" % [plugin_path, build, ext]
		else:
			current_decompressor = "%s%s" % [build, ext]
	else:
		current_decompressor = "%s%s" % [build, ext]
		
	return current_decompressor
	
func lib_exists(current_decompressor, platform: String, plugin_path: String) -> bool:
	"""Return if ouch already exists"""
	return FileAccess.file_exists(decompressor_cli(current_decompressor, platform, plugin_path));
	
