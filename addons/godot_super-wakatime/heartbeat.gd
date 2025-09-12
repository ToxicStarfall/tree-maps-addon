const FILE_MODIFIED_DELAY = 120

var file_path
var scene_path
var entity
var type
var category
var time
var is_write
var cursorpos
var lines
var line_no
var line_additions
var line_deletions
var language
var project

func _init(file_path: String = '', time: int = 0, is_write: bool = false):
	self.file_path = file_path
	self.time = time
	self.is_write = is_write
	self.scene_path = scene_path
