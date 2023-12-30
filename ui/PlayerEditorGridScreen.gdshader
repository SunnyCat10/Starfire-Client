shader_type canvas_item;

uniform float line_size : hint_range(0, 1);


void fragment() {
	float line_speed = 0.1;
	float line_brightness = 0.05;
	float y_line = -mod(SCREEN_UV.y - TIME * line_speed, line_size) * line_brightness;

	vec3 glow = vec3(abs(sin(TIME)) * 0.05);

	vec3 top_lighting = vec3(1. - (SCREEN_UV.y + 0.05), 1. - (SCREEN_UV.y + 0.05), 0.);
	COLOR.rgb += top_lighting / 1.8 + y_line - glow;
	//COLOR.grb = vec3(y_line * 0.2);
}
