shader_type canvas_item;

uniform sampler2D selected_texture : filter_nearest;
uniform vec3 selected_color_1 : source_color;
uniform vec3 selected_color_2 : source_color;
uniform vec3 selected_color_3 : source_color;

const vec3 surface_color = vec3(1., 0., 1.);
const vec3 paint_color_1 = vec3(0., 0., 0.);
const vec3 paint_color_2 = vec3(0.4, 0.4, 0.4);
const vec3 paint_color_3 = vec3(1., 1., 1.);

vec3 create_mask_from_color(vec3 current_color, vec3 target_color) {
	float color_difference = (length(current_color - target_color));
	vec3 color_mask = step(1.0, 1. - vec3(color_difference));
	vec3 mask = vec3(color_difference);
	return mask;
}

vec3 add_color_to_mask(vec3 texture_color, vec3 color_to_replace, vec3 new_selected_color) {
	float color_difference = (length(texture_color - color_to_replace));
	vec3 output_mask = (1. - step(0.1, vec3(color_difference))) * new_selected_color;
	return output_mask;
}

void fragment() {
	vec3 mask = create_mask_from_color(COLOR.rgb, surface_color);

	vec3 texture_color = texture(selected_texture, UV).rgb;
	vec3 colored_texture_mask = 
	add_color_to_mask(texture_color, paint_color_1, selected_color_1) + 
	add_color_to_mask(texture_color, paint_color_2, selected_color_2) + 
	add_color_to_mask(texture_color, paint_color_3, selected_color_3);
	vec3 painting_surface_mask = add_color_to_mask(COLOR.rgb, surface_color, paint_color_3);
	painting_surface_mask *= colored_texture_mask;

	COLOR.rgb *= mask;
	COLOR.rgb += painting_surface_mask;
}