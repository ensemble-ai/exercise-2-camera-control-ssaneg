class_name StageThreeCamera
extends CameraControllerBase

@export var follow_speed:float = 8
@export var catchup_speed:float = 15
@export var leash_distance:float = 8

func _ready():
	position = target.position
	
func _process(delta: float):
	if !current:
		return

	if draw_camera_logic:
		draw_logic()
	
	var tpos = target.global_position
	var cpos = global_position
	var distance = (tpos-(Vector3(cpos.x, 20, cpos.z))).length()
	var direction = (tpos-(Vector3(cpos.x, 20, cpos.z))).normalized()	
	var player_speed = target.velocity.length()
	
	#leash distance exceeded
	if distance >= leash_distance:
		global_position += direction*player_speed*delta
	
	#move at follow speed
	elif distance < leash_distance and target.velocity != Vector3(0,0,0) and distance > 0.2:
		global_position += direction*follow_speed*delta
	
	#move at catchup speed
	elif distance < leash_distance and target.velocity == Vector3(0,0,0) and distance > 0.2:
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
