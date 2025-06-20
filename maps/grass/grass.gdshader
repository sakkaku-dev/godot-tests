// https://www.youtube.com/watch?v=3ftcGTp-Se8
shader_type spatial;
render_mode cull_disabled, unshaded;

uniform vec3 color: source_color;
uniform vec3 color2: source_color;
uniform sampler2D noise;
uniform float noise_scale = 20.0;

group_uniforms displacement;
uniform vec3 character_position;
uniform float character_radius = 0.5;
uniform float character_push_strength = 0.2;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// https://godotshaders.com/shader/stylized-grass-with-wind-and-deformation/
	// we displace only the top part of the mesh
	// note that this means that the mesh needs to have UV in a way that the bottom of UV space
	// is at the top of the mesh
	float displacement_affect = (1.0 - UV.y);

	vec3 dir_to_character = character_position - MODEL_MATRIX[3].xyz;
	float distance_to_character = length(dir_to_character);
	float falloff = 1.0 - smoothstep(0.0, 1.0, distance_to_character/character_radius);
	// Because we operate in vertex space, we need to convert the direction to the character
	// in vertex space. Otherwise, it wouldn't work for rotated blades of grass.
	// comment the next line to observe how the blades are not all facing away from the character.
	dir_to_character = (inverse(MODEL_MATRIX) * vec4(dir_to_character, 0.0)).xyz;
	dir_to_character = normalize(dir_to_character);

	// direction to character is inverted because we want to point away from it
	VERTEX += normalize(-dir_to_character) * falloff * character_push_strength * displacement_affect;

	// https://godotshaders.com/shader/pixel-art-wind-sway-meshinstance3d-godot-4-0/
	NORMAL = vec3(0.0, 1.0, 0.0);
	VERTEX.x += sin(NODE_POSITION_WORLD.x + TIME * 1.25 + UV.y) * ( 1.0 - UV.y) * 0.1;
	VERTEX.z += cos(NODE_POSITION_WORLD.z + TIME * 0.45 + UV.y) * ( 1.0 - UV.y) * 0.01;
}

void fragment() {
	vec3 noise_level = texture(noise, world_pos.xz / noise_scale).rgb;
	ALBEDO = mix(color, color2, UV.y) * mix(color, color2, noise_level.r);
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
}
