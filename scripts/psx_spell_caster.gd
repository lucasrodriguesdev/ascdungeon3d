class_name PSXSpellCaster
extends Node3D

## Controlador Plug-and-Play de Conjuração de Magias PS1 para Godot 4.x
## Como usar:
##   1. Adicione este nó como filho de qualquer Mago (.glb) na sua cena.
##   2. Chame: $PSXSpellCaster.cast_spell("fogo")  # "fogo", "gelo", "veneno", "raio", "arcano"
##   O script toca automaticamente `Cast_Spell`, instancia o círculo rúnico + projétil (.glb),
##   aplica o shader aditivo PS1, acende a OmniLight3D dinâmica e dispara GPUParticles3D!

@export_enum("fogo", "gelo", "veneno", "raio", "arcano") var default_element: String = "fogo"
@export var vfx_base_path: String = "res://assets/magic_vfx/"
@export var magic_shader_path: String = "res://shaders/psx_magic_vfx.gdshader"
@export var enable_dynamic_light: bool = true
@export var enable_gpu_particles: bool = true

const SPELL_CONFIG := {
	"fogo":   { "file": "magia_bola_de_fogo.glb",   "color": Color(1.0, 0.42, 0.12), "glow": Color(1.0, 0.85, 0.30) },
	"gelo":   { "file": "magia_lamina_de_gelo.glb", "color": Color(0.35, 0.86, 1.0), "glow": Color(0.85, 0.98, 1.0) },
	"veneno": { "file": "magia_bola_de_veneno.glb", "color": Color(0.55, 0.95, 0.22), "glow": Color(0.80, 1.0, 0.40) },
	"raio":   { "file": "magia_raio_eletrico.glb",  "color": Color(1.0, 0.92, 0.28), "glow": Color(0.75, 0.96, 1.0) },
	"arcano": { "file": "magia_arcano.glb",         "color": Color(0.76, 0.34, 1.0), "glow": Color(1.0, 0.72, 1.0) },
}

var _cached_shader: Shader = null


func cast_spell(element: String = "") -> void:
	var elem := element if SPELL_CONFIG.has(element) else default_element
	var cfg: Dictionary = SPELL_CONFIG[elem]

	# 1. Toca a animação Cast_Spell no AnimationPlayer do Mago pai
	var anim_player := _find_animation_player(get_parent())
	if anim_player and anim_player.has_animation("Cast_Spell"):
		anim_player.play("Cast_Spell")

	# 2. Instancia o VFX 3D animado (.glb: MagicCircle + SpellProjectile + Spark_0..7)
	var glb_path: String = vfx_base_path + cfg["file"]
	var packed := load(glb_path) as PackedScene
	if packed == null:
		push_warning("PSXSpellCaster: Não foi possível carregar " + glb_path)
		return

	var vfx_inst := packed.instantiate() as Node3D
	add_child(vfx_inst)
	_apply_additive_shader(vfx_inst)

	var vfx_anim := _find_animation_player(vfx_inst)
	if vfx_anim and vfx_anim.has_animation("Cast_VFX"):
		vfx_anim.play("Cast_VFX")

	# 3. Cria luz dinâmica real (OmniLight3D) acompanhando o projétil + pulso no disparo!
	if enable_dynamic_light:
		var proj_node := vfx_inst.find_child("SpellProjectile", true, false) as Node3D
		var light := OmniLight3D.new()
		light.light_color = cfg["color"]
		light.omni_range = 6.5
		light.light_energy = 0.0
		light.shadow_enabled = false  # Estilo PS1 leve e rápido
		if proj_node:
			proj_node.add_child(light)
		else:
			vfx_inst.add_child(light)

		var tw := create_tween()
		tw.tween_property(light, "light_energy", 2.2, 0.35)
		tw.tween_property(light, "light_energy", 4.5, 0.65)
		tw.tween_property(light, "light_energy", 6.0, 0.08)  # Flash no disparo (1.06s)!
		tw.tween_property(light, "light_energy", 0.0, 0.42)

	# 4. Cria GPUParticles3D automaticamente com cor do elemento (espiral + rastro)
	if enable_gpu_particles:
		var particles := _create_elemental_particles(cfg["color"], cfg["glow"])
		var proj_node := vfx_inst.find_child("SpellProjectile", true, false) as Node3D
		if proj_node:
			proj_node.add_child(particles)
		else:
			vfx_inst.add_child(particles)

	# 5. Limpa o VFX automaticamente após o término da animação (1.55s)
	get_tree().create_timer(1.55).timeout.connect(func():
		if is_instance_valid(vfx_inst):
			vfx_inst.queue_free()
	)


func _apply_additive_shader(root: Node) -> void:
	if _cached_shader == null and ResourceLoader.exists(magic_shader_path):
		_cached_shader = load(magic_shader_path) as Shader
	if _cached_shader == null:
		return
	for child in root.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		var mat := mi.get_active_material(0)
		if mat is StandardMaterial3D and mat.albedo_texture != null:
			var sm := ShaderMaterial.new()
			sm.shader = _cached_shader
			sm.set_shader_parameter("albedo_texture", mat.albedo_texture)
			mi.set_surface_override_material(0, sm)


func _create_elemental_particles(col: Color, glow: Color) -> GPUParticles3D:
	var gp := GPUParticles3D.new()
	gp.amount = 28
	gp.lifetime = 0.55
	gp.one_shot = false
	gp.emitting = true

	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = 0.25
	pm.direction = Vector3(0, 1, -1)
	pm.spread = 45.0
	pm.initial_velocity_min = 0.6
	pm.initial_velocity_max = 1.8
	pm.gravity = Vector3(0, 0.4, 0)
	pm.scale_min = 0.05
	pm.scale_max = 0.12
	pm.color = glow
	gp.process_material = pm

	var quad := QuadMesh.new()
	quad.size = Vector2(0.10, 0.10)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_color = col
	quad.material = mat
	gp.draw_pass_1 = quad
	return gp


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node == null:
		return null
	if node is AnimationPlayer:
		return node
	return node.find_child("AnimationPlayer", true, false) as AnimationPlayer
