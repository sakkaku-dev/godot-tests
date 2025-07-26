shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_toon, specular_toon;

uniform vec2 TextureScale = vec2(1.000000, 1.000000);
uniform sampler2D DissolverTex : source_color;

uniform float Light_attenuation = 1.3;
uniform float Shadow_roundness = 1.0;
uniform sampler2D Color_1D_Gradient : source_color, hint_default_black;

void fragment() {
	vec4 color = COLOR;
	float alpha = color.a;

	vec2 uv = UV * TextureScale;
	vec4 dissolve_tex = texture(DissolverTex, uv);
	
	ALBEDO = vec3(color.xyz);
	ALPHA = dissolve_tex.r;
	ALPHA_SCISSOR_THRESHOLD = alpha;
}

void light() {
	float dot_result = dot(NORMAL, LIGHT);
	float add_some_math = (clamp(dot_result, -0.90, 0.90) + 1.0)*0.47*Light_attenuation;
	float fresnel = pow(clamp(dot(NORMAL, VIEW), 0.0, 1.0), Shadow_roundness);
	float round_cell_shade = clamp(add_some_math,0.04, 0.98) * fresnel;
	vec4 color_1D_gradient = texture(Color_1D_Gradient, vec2(round_cell_shade));
	DIFFUSE_LIGHT = clamp(LIGHT_COLOR * vec3(color_1D_gradient.xyz), vec3(0), vec3(1));
}
