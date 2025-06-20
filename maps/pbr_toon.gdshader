// https://www.artstation.com/artwork/wJZ4Gg
shader_type spatial;

render_mode depth_draw_opaque, cull_disabled;

uniform sampler2D main_texture;
//uniform sampler2D normal_texture: hint_normal;

group_uniforms colors;
uniform float offset = 0.2;
uniform float dist = 0.1;
uniform float light_smooth = 0.1;
uniform vec3 shadow_color: source_color = vec3(0.0);
uniform vec3 base_color: source_color = vec3(1.0);
uniform vec3 second_color: source_color = vec3(1.0);

uniform float brightness: hint_range(-1.0, 1.0, 0.01) = 0.0;
uniform float contrast: hint_range(-10.0, 10.0, 0.01) = 1.0;
uniform float saturation: hint_range(-10.0, 10.0, 0.10) = 1.0;
uniform vec3 color_dodge_color: source_color;

group_uniforms terminal_shadow;
uniform vec3 terminal_shadow_color: source_color;
uniform float terminal_shadow_size = 0.0;
uniform float terminal_light_smooth = 0.1;

mat4 brightness_matrix(float b) {
	return mat4(
		vec4(1, 0, 0, 0),
		vec4(0, 1, 0, 0),
		vec4(0, 0, 1, 0),
		vec4(b, b, b, 1)
	);
}

mat4 contrast_matrix(float c) {
	float t = (1.0 - c) / 2.0;
	return mat4(
		vec4(c, 0, 0, 0),
		vec4(0, c, 0, 0),
		vec4(0, 0, c, 0),
		vec4(t, t, t, 1)
	);
}

mat4 saturation_matrix(float s) {
	vec3 lum = vec3(0.3086, 0.6094, 0.0820);
	float sr = (1.0 - s) * lum.r;
	float sb = (1.0 - s) * lum.g;
	float sg = (1.0 - s) * lum.b;
	return mat4(
		vec4(sr + s, sr, sr, 0),
		vec4(sg, sg + s, sg, 0),
		vec4(sb, sb, sb + s, 0),
		vec4(0, 0, 0, 1)
	);
}

vec3 color_dodge(vec3 base, vec3 blend){
	return base / (1.0 - blend);
}

void fragment() {
	vec4 albedo_tex = texture(main_texture, UV);
	mat4 matrix = brightness_matrix(brightness) * contrast_matrix(contrast) * saturation_matrix(saturation);
	vec4 c = matrix * albedo_tex;

	vec3 grayscale = mix(vec3((c.r + c.g + c.b) / 3.0),  vec3(0.299 * c.r + 0.587 * c.g + 0.114 * c.b), 0.0);
	vec3 cleaned = smoothstep(vec3(offset), vec3(offset + dist), grayscale);


	ALBEDO = color_dodge(albedo_tex.rgb, color_dodge_color); // mix(second_color, base_color, cleaned);
	ALPHA = albedo_tex.a;
}

void light() {
	//vec3 normal_from_texture = texture(normal_texture, UV).rgb;
	//vec3 normal = vec3(normal_from_texture.x * NORMAL.x, normal_from_texture.y * NORMAL.y, normal_from_texture.z);
	//normal = NORMAL - normal_from_texture;

	float lDot = dot(NORMAL, LIGHT);
	float lSmooth = smoothstep(0, terminal_light_smooth, lDot);
	vec3 iLerp = mix(terminal_shadow_color, base_color, lSmooth);

	//float lDot_b = dot(NORMAL, LIGHT);
	float lSmooth_b = smoothstep(0, light_smooth, lDot + terminal_shadow_size);
	vec3 iLerp_b = mix(shadow_color, ALBEDO * iLerp, lSmooth_b);

	DIFFUSE_LIGHT = ALBEDO * iLerp_b;

	// TODO:
	// Metallic
	// Fix Face Normals
	// Hair Highlight ??
}