extends CanvasLayer

@onready var ip_field : LineEdit = %IpField
@onready var port_field : LineEdit = %PortField
@onready var local_host_button : Button = %LocalHostBtn
@onready var dedicated_host_button : Button = %DedicatedBtn

func _ready():
	local_host_button.pressed.connect(local_host_pressed)
	dedicated_host_button.pressed.connect(dedicated_host_pressed)


func local_host_pressed():
	Server.connect_to_server()
	local_host_button.disabled = true
	dedicated_host_button.disabled = true


func dedicated_host_pressed():
	if (ip_field.text.is_empty() or port_field.text.is_empty()):
		print("Error: empty ip or gateway")
	else:
		Server.ip = ip_field.text
		Server.port = port_field.text.to_int()
		Server.connect_to_server()
		local_host_button.disabled = true
		dedicated_host_button.disabled = true
