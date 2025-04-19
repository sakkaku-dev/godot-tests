//	Radar shader v2 by Brian Smith (steampunkdemon.itch.io)
//	MIT Licence

shader_type canvas_item;

// Replace the below references to source_color with hint_color if you are using a version of Godot before 4.
uniform vec4 line_color : source_color = vec4(0.0, 0.4, 0.0, 1.0);
uniform vec4 beam_color : source_color = vec4(0.5, 1.0, 0.5, 1.0);
uniform vec4 trail_color : source_color = vec4(0.0, 0.5, 0.0, 1.0);
uniform bool show_edges = false;
uniform float range_lines : hint_range(0.0, 10.0, 1.0) = 4.0;
uniform float sector_lines : hint_range(0.0, 10.0, 1.0) = 4.0;
uniform float line_width : hint_range(0.01, 0.1) = 0.01;
uniform float beam_angle : hint_range(0.0, 1.0) = 0.2;
uniform float beam_width : hint_range(0.0, 0.05) = 0.003;
uniform float trail_width : hint_range(0.0, 1.0) = 0.5;

group_uniforms Blip;
uniform vec4 blip_color : source_color = vec4(0.5, 1.0, 0.5, 1.0);
uniform float blip_size : hint_range(0.1, 0.5) = 0.1;
uniform float blip_softness : hint_range(0.0, 1.0) = 0.4;
uniform float blip_presistence : hint_range(1.0, 5.0) = 2.0;
uniform vec2 blip_position = vec2(0.5, 0.5);

float greater_than(float x, float y) {
  return max(sign(x - y), 0.0);
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float a = (atan(uv.y, uv.x) + 3.141592656) / 6.283185312;
	float l = length(uv);

//	Uncomment the following line if you are applying the shader to a TextureRect and using a version of Godot before 4.
//	COLOR = texture(TEXTURE,UV);

//	If you do not want to render the range and sector lines remove the following line of code.
//	If you want to only render the range lines replace the following line of code with:
//	COLOR.rgb = mix(COLOR.rgb, line_color.rgb, line_color.a * greater_than(mod(l, 1.0 / range_lines) * range_lines, 1.0 - line_width * range_lines));
//	If you only want to render the sector lines replace the following line of code with:
//	COLOR.rgb = mix(COLOR.rgb, line_color.rgb, line_color.a * greater_than(abs(mod(a, 1.0 / sector_lines) * sector_lines * 2.0 - 1.0), 1.0 - (line_width / 6.283185312 / l) * sector_lines));
	COLOR.rgb = mix(COLOR.rgb, line_color.rgb, line_color.a * max(greater_than(mod(l, 1.0 / range_lines) * range_lines, 1.0 - line_width * range_lines), greater_than(abs(mod(a, 1.0 / sector_lines) * sector_lines * 2.0 - 1.0), 1.0 - (line_width / 6.283185312 / l) * sector_lines)));

//	When using this shader in a game I suggest removing the following line of code and
//	replacing all occurrences of 'current_beam_angle' with 'beam_angle'.
//	You should then manually set the shader's beam_angle parameter so you know where the beam is
//	and therefore when the blip is not visible and its position can be updated.
	float current_beam_angle = mod(beam_angle * TIME, 1.0);

	a = a - 1.0 * greater_than(a, current_beam_angle);

//	If you do not want to render the trail remove the following line of code.
	COLOR.rgb = mix(COLOR.rgb, trail_color.rgb, trail_color.a * max(0.0, (1.0 - (current_beam_angle - a) / trail_width)));

//	If you do not want to render the beam remove the following line of code.
	COLOR.rgb = mix(COLOR.rgb, beam_color.rgb, beam_color.a * greater_than(a, current_beam_angle - beam_width));

//	If you do not want to render the blip remove the following code block.
//	The blip's x and y coordinates should be within the range -1.0 to 1.0.
//	The blip will not be displayed if it is exactly in the centre at 0.0, 0.0.
	float bl = length(blip_position - uv);
	float blip_angle = (atan(blip_position.y, blip_position.x) + 3.141592656) / 6.283185312;
	blip_angle = blip_angle - 1.0 * greater_than(blip_angle, current_beam_angle);
	COLOR.rgb = mix(COLOR.rgb, blip_color.rgb, blip_color.a * max(0.0, pow((blip_size - bl) / blip_size, blip_softness) - min(1.0, (current_beam_angle - blip_angle) * blip_presistence)));

//	If you do not want the edges to be transparent remove the following line of code.
//	If you always want the edges to be transparent replace the following line of code with:
//	COLOR.a *= greater_than(1.0, l);
	COLOR.a *= max(sign(1.0 - l), float(show_edges));
}