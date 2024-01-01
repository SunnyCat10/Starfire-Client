extends Resource
class_name UiButtonResource

@export var name : StringName
@export var texture : Texture
@export var texture_shader : Material


func load_as_button() -> TextureButton:
	var output : TextureButton = TextureButton.new()
	output.name = name
	output.texture_normal = texture
	output.material = texture_shader
	output.stretch_mode = TextureButton.STRETCH_SCALE
	return output
