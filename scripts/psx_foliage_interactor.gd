extends Node3D
class_name PSXFoliageInteractor
## Attach to your Player (CharacterBody3D) in Godot 4.
## Feeds the player's world position into the global shader uniform `player_world_pos`
## so all tall grass (`mato_alto_denso`, `mato_alto_capim_dourado`) and low grass
## using `shaders/psx_foliage_sway.gdshader` bend smoothly as the player walks through!

@export var height_offset: float = 0.25

func _process(_delta: float) -> void:
	RenderingServer.global_shader_parameter_set(
		"player_world_pos",
		global_position + Vector3(0.0, height_offset, 0.0)
	)
