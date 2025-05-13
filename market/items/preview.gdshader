shader_type spatial;
render_mode blend_mix, unshaded;

uniform float grid_size = 1.0; // Controls how big the grid cells are
uniform vec4 line_color : source_color = vec4(0.8, 0.9, 1.0, 1.0); // Bright blue-white lines
uniform float line_width = 0.05; // Thickness of the grid lines
uniform vec3 color: source_color = vec3(0.2, 0.5, 1.0);
uniform float alpha: hint_range(0.0, 1.0, 0.01) = 0.3;

void fragment() {
	// Base blue color with pulse effect
    vec3 base_color = color;
    float base_alpha = alpha;

	// Calculate grid pattern in world space
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 grid = fract(world_pos / grid_size);
    grid = smoothstep(line_width, line_width + 0.01, abs(grid - 0.5) * 2.0);

    // Combine grid lines (1.0 = line, 0.0 = no line)
    float line_pattern = min(grid.x, grid.y);
    line_pattern = min(line_pattern, grid.z); // Optional: add z-axis lines for 3D grid

    // Mix base color with line color
	ALBEDO = base_color;
	ALPHA = base_alpha;
    //ALBEDO = mix(base_color, line_color.rgb, line_pattern * line_color.a);
    //ALPHA = mix(base_alpha, line_color.a, line_pattern * line_color.a * 0.7); // Make lines more opaque
}