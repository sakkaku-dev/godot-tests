shader_type spatial;

uniform vec4 indicator_color : source_color = vec4(0.2, 0.2, 1.0, 0.5);
uniform float outline_width = 0.03;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 0.2, 1.0);

void fragment() {
    vec4 base_color = indicator_color;

    vec3 normal = normalize(NORMAL);
    vec3 view_dir = normalize(VIEW);

    float edge = dot(normal, view_dir);
    edge = smoothstep(1.0 - outline_width, 1.0, edge);

    vec4 final_color = mix(base_color, outline_color, edge);

    ALBEDO = final_color.rgb;
    ALPHA = final_color.a;
}