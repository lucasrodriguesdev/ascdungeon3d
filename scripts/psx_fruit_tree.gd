@tool
extends Node3D
class_name PSXFruitTree
## Plug-and-play Godot 4 controller for any 2-node Fruit Tree (.glb with Tree_Body + Fruits).
## Use with `arvore_frutifera_base_tintavel.glb` to switch between ANY fruit color at runtime,
## or with any fruit tree variant to toggle harvesting (`harvest()` / `regrow()`).

enum FruitType {
	MACA,
	LARANJA,
	LIMAO,
	PESSEGO,
	AMEIXA,
	DOURADA,
	CUSTOM,
}

const FRUIT_COLORS := {
	FruitType.MACA:    Color(0.92, 0.18, 0.18),
	FruitType.LARANJA: Color(0.98, 0.54, 0.10),
	FruitType.LIMAO:   Color(0.95, 0.88, 0.18),
	FruitType.PESSEGO: Color(0.98, 0.66, 0.48),
	FruitType.AMEIXA:  Color(0.52, 0.22, 0.66),
	FruitType.DOURADA: Color(1.00, 0.84, 0.24),
}

@export var fruit_type: FruitType = FruitType.MACA:
	set(value):
		fruit_type = value
		_apply_fruit_color()

@export var custom_fruit_color: Color = Color(0.95, 0.25, 0.45):
	set(value):
		custom_fruit_color = value
		if fruit_type == FruitType.CUSTOM:
			_apply_fruit_color()

@export var has_fruits: bool = true:
	set(value):
		has_fruits = value
		var fruits_node := _get_fruits_mesh()
		if fruits_node:
			fruits_node.visible = has_fruits


func _ready() -> void:
	_apply_fruit_color()
	var fruits_node := _get_fruits_mesh()
	if fruits_node:
		fruits_node.visible = has_fruits


func harvest() -> bool:
	if not has_fruits:
		return false
	has_fruits = false
	return true


func regrow() -> void:
	has_fruits = true


func _get_fruits_mesh() -> MeshInstance3D:
	var n := find_child("Fruits", true, false)
	return n as MeshInstance3D


func _apply_fruit_color() -> void:
	var fruits_node := _get_fruits_mesh()
	if not fruits_node:
		return
	var base_mat := fruits_node.get_active_material(0)
	if base_mat == null:
		return
	var mat := base_mat.duplicate() as StandardMaterial3D
	if mat:
		mat.albedo_color = custom_fruit_color if fruit_type == FruitType.CUSTOM else FRUIT_COLORS.get(fruit_type, Color.WHITE)
		fruits_node.set_surface_override_material(0, mat)
