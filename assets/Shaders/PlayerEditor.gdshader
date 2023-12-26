shader_type canvas_item;

uniform vec3 new_color : source_color;

void fragment() {
	float color_difference = (length(COLOR.rgb - vec3(1.,0.,1.)));
	vec3 color_mask = step(1.0, 1. - vec3(color_difference));
	vec3 mask = vec3(color_difference);
	COLOR.rgb *= mask;
	COLOR.rgb += color_mask * new_color;
}
