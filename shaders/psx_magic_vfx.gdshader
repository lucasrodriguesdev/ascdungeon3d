shader_type spatial;
render_mode blend_add, unshaded, cull_disabled, depth_draw_never, skip_vertex_transform;

// ============================================================================
// PSX Magic VFX Additive Shader (Godot 4.x)
// - Brilho aditivo estilo PS1 (círculos rúnicos no chão, projéteis e faíscas)
// - Vertex snapping clássico (320x240) + filtragem nearest-neighbor
// - Pulsação luminosa automática para fogo, gelo, veneno, raio e arcano
// ============================================================================

uniform sampler2D albedo_texture : source_color, filter_nearest, repeat_enable;
uniform vec4 glow_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.5, 4.0) = 1.65;
uniform float pulse_speed : hint_range(0.0, 16.0) = 6.0;
uniform float pulse_amount : hint_range(0.0, 0.5) = 0.18;

group_uniforms PSX_Effects;
uniform bool enable_vertex_snap = true;
uniform vec2 snap_resolution = vec2(320.0, 240.0);

void vertex() {
	vec4 view_pos = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	VERTEX = view_pos.xyz;

	vec4 clip_pos = PROJECTION_MATRIX * view_pos;
	if (enable_vertex_snap && clip_pos.w > 0.0001) {
		vec2 ndc = clip_pos.xy / clip_pos.w;
		vec2 grid = snap_resolution * 0.5;
		ndc = floor(ndc * grid + 0.5) / grid;
		clip_pos.xy = ndc * clip_pos.w;
		vec4 snapped_view = INV_PROJECTION_MATRIX * clip_pos;
		VERTEX = snapped_view.xyz / snapped_view.w;
	}
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV) * glow_tint;
	float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_amount;
	ALBEDO = tex.rgb * glow_intensity * pulse;
	ALPHA = tex.a;
}
