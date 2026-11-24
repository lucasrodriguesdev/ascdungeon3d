shader_type spatial;
render_mode cull_disabled, depth_draw_opaque, diffuse_lambert, specular_disabled;

// PS1 Interactive Forest Foliage Shader for Godot 4
// Supports gentle woodland wind sway + real-time bending when the Player walks through tall grass/brush!
// Setup:
//   1. Project Settings -> Globals -> Shader Globals -> add `player_world_pos` (type: vec3)
//   2. Attach `godot_scripts/psx_foliage_interactor.gd` to your Player node!

global uniform vec3 player_world_pos;

uniform sampler2D albedo_tex : source_color, filter_nearest, repeat_disable;
uniform float alpha_scissor : hint_range(0.0, 1.0) = 0.5;
uniform float wind_speed = 2.2;
uniform float wind_strength = 0.08;
uniform float interact_radius = 1.15;
uniform float interact_strength = 0.52;
uniform float jitter_res = 160.0;

void vertex() {
	// Weight = 0 at ground roots (VERTEX.y == 0), smoothly increasing toward grass tips!
	float weight = clamp(VERTEX.y, 0.0, 1.2);
	float w2 = weight * weight;

	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// 1. Gentle ambient forest breeze
	float phase = world_pos.x * 1.7 + world_pos.z * 1.3 + TIME * wind_speed;
	vec3 disp = vec3(sin(phase), 0.0, cos(phase * 0.85)) * wind_strength * w2;

	// 2. Smooth player brush-past interaction (pushes grass tips away from player_world_pos!)
	vec2 to_grass = world_pos.xz - player_world_pos.xz;
	float dist = length(to_grass);
	if (dist < interact_radius && dist > 0.001) {
		float push = (1.0 - dist / interact_radius);
		push = push * push * interact_strength * weight;
		vec2 dir = to_grass / dist;
		disp.x += dir.x * push;
		disp.z += dir.y * push;
		disp.y -= push * 0.35; // Slight downward dip as grass bends aside!
	}

	// Transform world displacement back into local vertex space
	vec3 local_disp = (inverse(MODEL_MATRIX) * vec4(disp, 0.0)).xyz;
	VERTEX += local_disp;

	// Optional subtle PS1 vertex snapping
	if (jitter_res > 0.0) {
		vec4 clip = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
		clip.xy = floor(clip.xy / clip.w * jitter_res + 0.5) / jitter_res * clip.w;
		POSITION = clip;
	}
}

void fragment() {
	vec4 tex = texture(albedo_tex, UV);
	if (tex.a < alpha_scissor) {
		discard;
	}
	ALBEDO = tex.rgb;
}
