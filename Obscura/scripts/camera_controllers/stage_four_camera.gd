class_name StageFourCamera
extends CameraControllerBase

@export var lead_speed:float = 70
@export var catchup_delay_duration:float = 7
@export var catchup_speed:float = 30
@export var leash_distance:float = 7

func _ready():
	position = target.position
	
func _process(delta: float):
	if !current:
		return

	if draw_camera_logic:
		draw_logic()
	
	var player_speed = target.velocity.length()
	var tpos = target.global_position
	var cpos = global_position
	var distance = (tpos-Vector3(cpos.x, 20, cpos.z)).length()
	var direction = (tpos-Vector3(cpos.x, 20, cpos.z)).normalized()
	
	#leash exceeded
	if distance >= leash_distance:
		global_position += direction*(distance-leash_distance)
	
	#move camera ahead
	if target.velocity != Vector3(0,0,0):
		global_position += (target.velocity.normalized())*lead_speed*delta
		#set catchup delay
		target.delay = catchup_delay_duration
	
	#catchup camera to target
	elif target.velocity == Vector3(0,0,0) and distance > 0.25:
		#wait the length of delay
		if target.delay>0:
			target.delay -= 1
		#catchup camera
		elif (tpos-cpos).length() > target.WIDTH / 4.0:
			global_position += direction*catchup_speed*delta
		
	super(delta)
	
func draw_logic():
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	immediate_mesh.surface_add_vertex(Vector3(-2.5, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(2.5, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, -2.5))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, 2.5))
	
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
