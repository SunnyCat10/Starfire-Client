shader_type canvas_item;

const vec4 rust_color = vec4(0.717, 0.255, 0.055, 1.0);
uniform sampler2D erosion;


void fragment() {	
	vec4 input_color = texture(TEXTURE, UV);
	float color_average = (input_color.r + input_color.g + input_color.b) / 8.0;
	vec4 burn_color = vec4(color_average, color_average, color_average, input_color.a);
	vec4 result = mix(burn_color, rust_color, 0.21);
	COLOR = vec4(result.r, result.g, result.b, input_color.a);
	
	vec4 erosion_texture = texture(erosion, UV);
	
	float erosion_min = (sin(TIME * 1.0) + 1.0) * 0.5;
	float erosion_max = erosion_min + 0.3;
	float erosion_value = smoothstep(erosion_min, erosion_max, erosion_texture.r);
	
	if (COLOR.a != 0.0) {
		COLOR.a = erosion_value;
	}
}
