shader_type canvas_item;

// ============================================================================
// PSX Classic Post-Process Shader (Godot 4.x)
// Aplicar em um ColorRect dentro de um CanvasLayer cobrindo a tela inteira.
// - Downscale para resolução PS1 (ex: 320x240 ou 480x270)
// - Matriz de Bayer 4x4 (dithering clássico de hardware PS1)
// - Quantização de cor para 15-bit (RGB555 = 32 níveis por canal)
// ============================================================================

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform vec2 target_resolution = vec2(320.0, 240.0);
uniform bool enable_pixelation = true;
uniform bool enable_dithering = true;
uniform float color_depth : hint_range(4.0, 64.0, 1.0) = 32.0; // 32 = 5 bits/canal (PS1 RGB555)
uniform float dither_strength : hint_range(0.0, 1.0) = 0.85;

const mat4 BAYER_4X4 = mat4(
	vec4( 0.0,  8.0,  2.0, 10.0),
	vec4(12.0,  4.0, 14.0,  6.0),
	vec4( 3.0, 11.0,  1.0,  9.0),
	vec4(15.0,  7.0, 13.0,  5.0)
) / 16.0 - 0.5;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 pixel_coord = uv * target_resolution;

	if (enable_pixelation) {
		uv = (floor(pixel_coord) + 0.5) / target_resolution;
	}

	vec3 col = texture(screen_texture, uv).rgb;

	if (enable_dithering) {
		ivec2 bayer_idx = ivec2(mod(floor(pixel_coord), 4.0));
		float threshold = BAYER_4X4[bayer_idx.y][bayer_idx.x];
		col += (threshold / color_depth) * dither_strength;
	}

	col = floor(col * color_depth + 0.5) / color_depth;
	COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
}
