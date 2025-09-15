@tool
class_name TreeMapNode
extends Node2D

#@export_tool_button("None", "ToolSelect") var enable_editing_connection_action = func(): toggle_editing_connection()
#@export_tool_button("Edit Connections", "EditAddRemove") var toggle_edit_connections_action = func(): toggle_editing_connections()

signal moved
#signal node_edited
signal connections_edited

enum EditingState { NONE, EDITING, ADDING, REMOVING }

#@export_category("Setup")
@export var editing_state: EditingState = EditingState.NONE
@export var editing_connections: bool = false

@export var outputs: Array[int] = []
@export var inputs: Array[int] = []

const DEFAULT_ARROW_TEXTURE = preload("res://addons/new_folder/icons/arrow_filled.png")
var arrow_texture: Texture2D = DEFAULT_ARROW_TEXTURE
#@export var arrow_texture: Texture2D
#@export_category("Customization")
#@export var data: Resource
@export_group("Overrides")
#@export var a = 0


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)


func _draw() -> void:
	_draw_node()
	_draw_connection()


func _draw_connection():
	for i in outputs:
		draw_set_transform(Vector2(0,0), 0)  # Reset drawing position
		var target_pos = get_parent().get_child(i).global_position
		draw_line(Vector2(0,0) , target_pos - self.global_position, Color.WHITE, 10)
		var arrow_texture = DEFAULT_ARROW_TEXTURE
		var arrow_pos = (target_pos - self.position) / 2  # Get half-way point between nodes
		var arrow_ang = (target_pos - position).angle()   # Get angle pointing towards next connecting node
		draw_set_transform(arrow_pos, arrow_ang)  # Set draw offset to arrow position to make it the center rotating point
		draw_texture(arrow_texture, -arrow_texture.get_size() / 2)


func _draw_node():
	draw_circle(Vector2(0,0), 12, Color.WHITE, true)


func _notification(what) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		moved.emit(self)


func toggle_editing_connections():
	if editing_state: editing_state = EditingState.NONE
	else: editing_state = EditingState.EDITING
	editing_connections = !editing_connections
	connections_edited.emit(self)


## Adds a idx for node connections. [br]
## - If output is false, then add a connection as input
func add_connection(idx, output: bool = true):
	var new_connections = outputs.duplicate()
	new_connections.append(idx)
	if output:
		self.outputs = new_connections
	else:
		self.inputs = new_connections
	queue_redraw()
	#var connection_target = get_last_selected_node()
	#var connection_target_idx = connection_target.get_index()
	## prevent duplicate and self from being included
	#if !new_connections.has(connection_target_idx) and !(selected_node == connection_target):
		#new_connections.append( connection_target.get_index() )


func remove_connection():
	pass


func extend():
	pass
