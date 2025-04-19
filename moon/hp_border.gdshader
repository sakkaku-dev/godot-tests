shader_type canvas_item;

uniform float threshold: hint_range(0.0, 1.0, 0.01) = 1.0;

void fragment() {
	vec2 center = UV - vec2(0.5);
	float dist = length(center);
	COLOR.a *= smoothstep(threshold, 1.0, dist);
}
