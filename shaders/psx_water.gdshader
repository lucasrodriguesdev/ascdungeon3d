shader_type spatial;
render_mode blend_mix, cull_disabled, vertex_lighting, skip_vertex_transform, unshaded;

// ============================================================================
// PSX Liquids & Ice Shader (Godot 4.x)
// Funciona para:
//   - Água (pesca) : scroll_speed = (0.04, 0.06), wave_amplitude = 0.035, emissive_boost = 0.0
//   - Lava         : scroll_speed = (0.02, 0.03), wave_amplitude = 0.025, emissive_boost = 0.45
//   - Cachoeira    : scroll_speed = (0.00, -0.65), wave_amplitude = 0.020, emissive_boost = 0.1
//   - Gelo         : scroll_speed = (0.00, 0.00), wave_amplitude = 0.000, fresnel_glare = 0.35
// ============================================================================

uniform sampler2D albedo_texture : source_color, filter_nearest, repeat_enable;
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec2 scroll_speed = vec2(0.04, 0.06);
uniform float wave_amplitude : hint_range(0.0, 0.15) = 0.035;
uniform float wave_frequency : hint_range(0.5, 8.0) = 2.8;
uniform float emissive_boost : hint_range(0.0, 2.0) = 0.0;
uniform float fresnel_glare : hint_range(0.0, 1.0) = 0.15;

group_uniforms PSX_Effects;
uniform bool enable_vertex_snap = true;
uniform vec2 snap_resolution = vec2(320.0, 240.0);

void vertex() {
	vec3 pos = VERTEX;
	if (wave_amplitude > 0.0001) {
		pos.y += sin(pos.x * wave_frequency + TIME * 2.2) * wave_amplitude;
		pos.y += cos(pos.z * wave_frequency + TIME * 1.8) * wave_amplitude * 0.7;
	}

	vec4 view_pos = MODELVIEW_MATRIX * vec4(pos, 1.0);
	VERTEX = view_pos.xyz;
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);

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
	vec2 uv = UV + scroll_speed * TIME;
	vec4 tex = texture(albedo_texture, uv) * tint_color;
	float fresnel = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 2.5);

	ALBEDO = tex.rgb * (1.0 + emissive_boost) + vec3(fresnel * fresnel_glare);
	ALPHA = tex.a;
}
