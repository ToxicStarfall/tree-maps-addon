[gd_scene load_steps=3 format=3 uid="uid://bv3rxl15k7bj6"]

[sub_resource type="Theme" id="Theme_qedjm"]

[sub_resource type="Theme" id="Theme_1xn0x"]

[node name="ApiKeyPrompt" type="PopupPanel"]
title = "API key configuration"
initial_position = 1
size = Vector2i(350, 100)
visible = true
content_scale_aspect = 4
content_scale_stretch = 1
theme = SubResource("Theme_qedjm")

[node name="VBoxContainer" type="VBoxContainer" parent="."]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 4.0
offset_top = 4.0
offset_right = -4.0
offset_bottom = -4.0
grow_horizontal = 2
grow_vertical = 2
size_flags_horizontal = 4
size_flags_vertical = 4
theme = SubResource("Theme_1xn0x")

[node name="HBoxContainerTop" type="HBoxContainer" parent="VBoxContainer"]
layout_mode = 2

[node name="LineEdit" type="LineEdit" parent="VBoxContainer/HBoxContainerTop"]
custom_minimum_size = Vector2(200, 25)
layout_mode = 2
size_flags_horizontal = 6
size_flags_vertical = 0
placeholder_text = "Provide Your Wakatime API Key"
expand_to_text_length = true
secret = true

[node name="ShowButton" type="Button" parent="VBoxContainer/HBoxContainerTop"]
layout_mode = 2
size_flags_horizontal = 6
size_flags_vertical = 4
text = "Show"

[node name="HBoxContainerBottom" type="HBoxContainer" parent="VBoxContainer"]
layout_mode = 2

[node name="SubmitButton" type="Button" parent="VBoxContainer/HBoxContainerBottom"]
layout_mode = 2
size_flags_horizontal = 6
size_flags_vertical = 0
text = "Submit"
