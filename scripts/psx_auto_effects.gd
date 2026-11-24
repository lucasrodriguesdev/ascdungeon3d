@tool
extends Node3D
class_name PSXAutoEffects
## Plug-and-play Godot 4 Auto-Configurator for the 705-Asset PSX RPG Pack!
## Attach this script to your World root (or any imported .glb) and all PS1 effects
## (Nearest-Neighbor filtering, Liquid waves/scroll, Swaying interactive grass,
##  Translucent Slimes, and Emissive Magic VFX) are wired automatically!

const SHADER_WATER   := preload("res://shaders/psx_water.gdshader")
const SHADER_FOLIAGE := preload("res://shaders/psx_foliage_sway.gdshader")
const SHADER_SLIME   := preload("res://shaders/psx_slime.gdshader")
const SHADER_MAGIC   := preload("res://shaders/psx_magic_vfx.gdshader")
const SHADER_SPATIAL := preload("res://shaders/psx_spatial.gdshader")

@export var apply_now: bool = false:
	set(value):
		if value:
			apply_all_effects()
		apply_now = false

@export var enable_ps1_nearest_filter: bool = true
@export var enable_liquid_shaders: bool = true
@export var enable_foliage_sway: bool = true
@export var enable_slime_shader: bool = true
## Aplica psx_spatial.gdshader (vertex snap, affine mapping, vertex lighting) em todo o resto.
@export var enable_psx_spatial_shader: bool = true
@export var snap_resolution: Vector2 = Vector2(320.0, 240.0)


func _ready() -> void:
	apply_all_effects()


func apply_all_effects(root: Node = self) -> void:
	_walk(root)


func _walk(node: Node) -> void:
	if node is MeshInstance3D:
		_configure_mesh(node as MeshInstance3D)
	for child in node.get_children():
		_walk(child)


func _configure_mesh(mi: MeshInstance3D) -> void:
	if mi.mesh == null:
		return
	var n_low := mi.name.to_lower()
	var p_low := mi.get_parent().name.to_lower() if mi.get_parent() else ""

	for s_idx in range(mi.mesh.get_surface_count()):
		var mat := mi.get_active_material(s_idx)
		if not (mat is BaseMaterial3D):
			continue
		var std := mat as BaseMaterial3D
		var tex: Texture2D = std.albedo_texture

		# 1. Liquids: Water, Lava, Waterfall, Mud
		if enable_liquid_shaders and n_low in ["liquid_water", "liquid_lava", "liquid_waterfall", "liquid_mud"]:
			var sm := ShaderMaterial.new()
			sm.shader = SHADER_WATER
			if tex:
				sm.set_shader_parameter("albedo_tex", tex)
			if n_low == "liquid_waterfall":
				sm.set_shader_parameter("scroll_speed", Vector2(0.0, -0.75))
				sm.set_shader_parameter("wave_amp", 0.015)
			elif n_low == "liquid_lava":
				sm.set_shader_parameter("scroll_speed", Vector2(0.025, 0.035))
				sm.set_shader_parameter("wave_amp", 0.022)
				sm.set_shader_parameter("is_emissive", true)
			elif n_low == "liquid_mud":
				sm.set_shader_parameter("scroll_speed", Vector2(0.012, 0.016))
				sm.set_shader_parameter("wave_amp", 0.012)
			else:
				sm.set_shader_parameter("scroll_speed", Vector2(0.05, 0.07))
				sm.set_shader_parameter("wave_amp", 0.032)
			mi.set_surface_override_material(s_idx, sm)
			continue

		# 2. Interactive swaying tall grass, low grass & woodland ferns!
		if enable_foliage_sway and (
			"mato_alto" in p_low or "grama_baixa" in p_low or "samambaia" in p_low
			or "mato_alto" in n_low or "grama_baixa" in n_low or "samambaia" in n_low
		):
			var sm := ShaderMaterial.new()
			sm.shader = SHADER_FOLIAGE
			if tex:
				sm.set_shader_parameter("albedo_tex", tex)
			mi.set_surface_override_material(s_idx, sm)
			continue

		# 3. Translucent Slime jelly outer layer
		if enable_slime_shader and n_low == "slime_outer":
			var sm := ShaderMaterial.new()
			sm.shader = SHADER_SLIME
			if tex:
				sm.set_shader_parameter("albedo_tex", tex)
			mi.set_surface_override_material(s_idx, sm)
			continue

		# 4. PS1 spatial shader (vertex snapping + affine texture mapping) on everything else
		if enable_psx_spatial_shader and tex != null and tex.get_width() < 512:
			var sm := ShaderMaterial.new()
			sm.shader = SHADER_SPATIAL
			sm.set_shader_parameter("albedo_texture", tex)
			sm.set_shader_parameter("albedo_color", std.albedo_color)
			sm.set_shader_parameter("snap_resolution", snap_resolution)
			if std.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR:
				sm.set_shader_parameter("alpha_scissor", std.alpha_scissor_threshold)
			elif std.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
				sm.set_shader_parameter("alpha_scissor", 0.5)
			mi.set_surface_override_material(s_idx, sm)
			continue

		# 5. Crisp PS1 Nearest-Neighbor texture filtering (keep Linear on >=512px PS2 test models!)
		if enable_ps1_nearest_filter and tex != null:
			var dup := std.duplicate() as BaseMaterial3D
			if tex.get_width() < 512:
				dup.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			else:
				dup.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			mi.set_surface_override_material(s_idx, dup)
