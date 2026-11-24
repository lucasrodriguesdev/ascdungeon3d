extends Area3D
class_name PSXRoofCutout
## Plug-and-play Roof Cutout / Transparency Controller for ALL village buildings
## (Taverna, Ferraria, Igreja, Escola de Magia, Delegacia, 4 Torres, Boticário, Enfermaria).
##
## Usage in Godot 4:
##   1. Place this Area3D inside your building (with a CollisionShape3D covering the interior).
##   2. Point `building_root` to the imported building node (or leave empty to use parent).
##   3. When the Player enters the Area3D, every child node starting with `Roof_` is hidden or faded!

@export var building_root: Node3D
@export var player_group: StringName = &"player"
@export var use_transparency: bool = false
@export_range(0.0, 1.0) var faded_alpha: float = 0.18

var _roof_nodes: Array[Node3D] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var target := building_root if building_root else get_parent()
	if target:
		_collect_roofs(target)


func _collect_roofs(node: Node) -> void:
	if node is Node3D and node.name.begins_with("Roof_"):
		_roof_nodes.append(node as Node3D)
	for c in node.get_children():
		_collect_roofs(c)


func _on_body_entered(body: Node3D) -> void:
	if player_group.is_empty() or body.is_in_group(player_group):
		_set_roof_hidden(true)


func _on_body_exited(body: Node3D) -> void:
	if player_group.is_empty() or body.is_in_group(player_group):
		_set_roof_hidden(false)


func _set_roof_hidden(hidden: bool) -> void:
	for rn in _roof_nodes:
		if not use_transparency:
			rn.visible = not hidden
		else:
			_apply_fade(rn, faded_alpha if hidden else 1.0)


func _apply_fade(node: Node, alpha: float) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh:
			for i in range(mi.mesh.get_surface_count()):
				var mat := mi.get_active_material(i)
				if mat is BaseMaterial3D:
					var dup := mat.duplicate() as BaseMaterial3D
					dup.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if alpha < 0.99 else BaseMaterial3D.TRANSPARENCY_DISABLED
					dup.albedo_color.a = alpha
					mi.set_surface_override_material(i, dup)
	for c in node.get_children():
		_apply_fade(c, alpha)
