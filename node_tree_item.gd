@tool
class_name NodeTreeItem
extends Node2D

#@export_tool_button("None", "ToolSelect") var enable_editing_connection_action = func(): toggle_editing_connection()
@export_tool_button("Edit Connections", "EditAddRemove") var toggle_edit_connections_action = func(): toggle_editing_connections()
#@export_tool_button("Add Connection", "ToolAddNode") var enable_adding_connection_action = enable_adding_connection
#@export_tool_button("Remove Connection", "Remove") var enable_removing_connection_action = enable_removing_connection

signal moved
#signal node_edited
signal connections_edited

enum EditingState { NONE, EDITING, ADDING, REMOVING }

@export var editing_state: EditingState = EditingState.NONE

@export var editing_connections: bool = false

var connecting_node
@export var outputs: Array = []
@export var inputs: Array = []


func _init() -> void:
	pass


func _enter_tree() -> void:
	set_notify_transform(true)


func _draw() -> void:
	for i in outputs:
		draw_set_transform(Vector2(0,0), 0)
		draw_circle(Vector2(0,0), 12, Color.WHITE, true)

		var target_pos = get_parent().get_child(i).global_position
		draw_line(Vector2(0,0) , target_pos - self.global_position, Color.WHITE, 10)
		var arrow_texture = preload("res://arrow_filled.png")
		var arrow_pos = ((target_pos - self.position) / 2)
		#var arrow_ang = get_angle_to(target_pos)
		var arrow_ang = (target_pos - position).angle()
		#draw_set_transform(Vector2(0,0), arrow_ang)
		draw_set_transform(arrow_pos, arrow_ang)
		#draw_texture(arrow_texture, Vector2.ZERO)
		draw_texture(arrow_texture, -arrow_texture.get_size() / 2)


func _notification(what) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		#notification(NOTIFICATION_TRANSFORM_CHANGED)
		#queue_redraw()
		moved.emit(self)


func toggle_editing_connections():
	if editing_state: editing_state = EditingState.NONE
	else: editing_state = EditingState.EDITING
	editing_connections = !editing_connections
	#connecting_node = get_last_selected_node()
	connections_edited.emit(self)


func add_connection():
	pass


func remove_connection():
	pass


func extend():
	pass
