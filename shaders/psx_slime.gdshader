shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back, vertex_lighting, skip_vertex_transform, diffuse_lambert;

// ============================================================================
// PSX Translucent Slime Shader (Godot 4.x)
// - Transparência gelatinosa (blend_mix) preservando o alpha da textura 128x128
// - Vertex snapping clássico de PS1 (320x240) + Affine UV mapping
// - Brilho gelatinoso nas bordas (Fresnel suave) + pulsação orgânica opcional
// ============================================================================

uniform sampler2D albedo_texture : source_color, filter_nearest, repeat_enable;
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float opacity_scale : hint_range(0.1, 1.5) = 1.0;
uniform float rim_strength : hint_range(0.0, 1.0) = 0.35;
uniform float jelly_wobble : hint_range(0.0, 0.08) = 0.015;

group_uniforms PSX_Effects;
uniform bool enable_vertex_snap = true;
uniform vec2 snap_resolution = vec2(320.0, 240.0);
uniform bool enable_affine_mapping = true;
uniform float affine_strength : hint_range(0.0, 1.0) = 0.75;

varying vec2 affine_uv;
varying float vertex_w;

void vertex() {
	vec3 pos = VERTEX;
	if (jelly_wobble > 0.0) {
		pos.x += sin(TIME * 3.8 + pos.y * 7.0) * jelly_wobble * pos.y;
		pos.z += cos(TIME * 3.4 + pos.y * 6.5) * jelly_wobble * pos.y;
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

	vertex_w = max(clip_pos.w, 0.0001);
	affine_uv = UV * mix(1.0, vertex_w, affine_strength);
}

void fragment() {
	vec2 uv = enable_affine_mapping
		? affine_uv / mix(1.0, vertex_w, affine_strength)
		: UV;

	vec4 tex = texture(albedo_texture, uv) * tint_color;
	float fresnel = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 2.2);

	ALBEDO = mix(tex.rgb, min(tex.rgb * 1.45 + vec3(0.12), vec3(1.0)), fresnel * rim_strength);
	ALPHA = clamp(tex.a * opacity_scale + fresnel * 0.22, 0.0, 1.0);
	ROUGHNESS = 0.25;
	METALLIC = 0.0;
}
