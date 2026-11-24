shader_type spatial;
render_mode vertex_lighting, skip_vertex_transform, diffuse_lambert, specular_disabled;

// ============================================================================
// PSX Classic Spatial Shader (Godot 4.x)
// - Vertex snapping (jitter clássico de PS1 em coordenadas de tela)
// - Affine texture mapping (distorção de perspectiva das UVs)
// - Filtragem nearest-neighbor (pixelado)
// - Vertex lighting (iluminação Gouraud por vértice)
// - Suporte a alpha scissor (folhagens, teias, grades) e neblina de distância
// ============================================================================

uniform sampler2D albedo_texture : source_color, filter_nearest, repeat_enable;
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float alpha_scissor : hint_range(0.0, 1.0) = 0.0;

group_uniforms PSX_Effects;
uniform bool enable_vertex_snap = true;
uniform vec2 snap_resolution = vec2(320.0, 240.0);
uniform bool enable_affine_mapping = true;
uniform float affine_strength : hint_range(0.0, 1.0) = 1.0;

group_uniforms PSX_Fog;
uniform bool enable_fog = false;
uniform vec3 fog_color : source_color = vec3(0.08, 0.09, 0.12);
uniform float fog_start = 12.0;
uniform float fog_end = 45.0;

varying vec2 affine_uv;
varying float vertex_w;
varying float fog_factor;

void vertex() {
	// Transformação para view space (necessária com skip_vertex_transform)
	vec4 view_pos = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	VERTEX = view_pos.xyz;
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);

	// Projeção para clip space para aplicar o vertex snap do PS1
	vec4 clip_pos = PROJECTION_MATRIX * view_pos;

	if (enable_vertex_snap && clip_pos.w > 0.0001) {
		vec2 ndc = clip_pos.xy / clip_pos.w;
		vec2 grid = snap_resolution * 0.5;
		ndc = floor(ndc * grid + 0.5) / grid;
		clip_pos.xy = ndc * clip_pos.w;
		// Reconstroi VERTEX aproximado em view space para manter profundidade/luz coerentes
		vec4 snapped_view = INV_PROJECTION_MATRIX * clip_pos;
		VERTEX = snapped_view.xyz / snapped_view.w;
	}

	// Affine texture mapping: multiplica UV por W no vertex e divide no fragment
	// (anula a correção de perspectiva da GPU moderna)
	vertex_w = max(clip_pos.w, 0.0001);
	affine_uv = UV * mix(1.0, vertex_w, affine_strength);

	// Neblina linear por vértice (estilo Silent Hill / PS1)
	float dist = length(view_pos.xyz);
	fog_factor = clamp((dist - fog_start) / max(fog_end - fog_start, 0.001), 0.0, 1.0);
}

void fragment() {
	vec2 uv = enable_affine_mapping
		? affine_uv / mix(1.0, vertex_w, affine_strength)
		: UV;

	vec4 tex = texture(albedo_texture, uv) * albedo_color;

	if (alpha_scissor > 0.0 && tex.a < alpha_scissor) {
		discard;
	}

	vec3 final_col = tex.rgb;
	if (enable_fog) {
		final_col = mix(final_col, fog_color, fog_factor);
	}

	ALBEDO = final_col;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}
