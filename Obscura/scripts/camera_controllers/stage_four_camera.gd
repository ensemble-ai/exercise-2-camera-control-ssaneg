class_name StageFourCamera
extends CameraControllerBase

@export var lead_speed:float = 60
@export var catchup_delay_duration:float = 75
@export var catchup_speed:float = 75
@export var leash_distance:float = 10

func _ready():
	position = target.position
	
func _process(delta: float):
	if !current:
		return

	if draw_camera_logic:
		draw_logic()
		
	var xdiff = global_position.x-target.global_position.x
	var ydiff = global_position.z-target.global_position.z
	#print(xdiff, ydiff)
	var curr:int
	
	#var term1 = pow(target.global_position.x-global_position.x,2)
	#var term2 = pow(target.global_position.z-global_position.z,2)
	#var distance = sqrt(term1 + term2)
	
	var player_speed = float(target.BASE_SPEED)
	
	var tpos = target.global_position
	var cpos = global_position
	cpos.y -= 10
	var distance = (tpos-cpos).length()
	
	if distance >= leash_distance:
		print("leash")
		global_position += (tpos-cpos).normalized()*player_speed*delta
		'''if target.velocity.x > 0:
			global_position.x += player_speed*delta#(keep_speed/60)
		elif target.velocity.x < 0:
			global_position.x -= player_speed*delta#(keep_speed/60)
		if target.velocity.z > 0:
			global_position.z += player_speed*delta#(keep_speed/60)
		elif target.velocity.z < 0:
			global_position.z -= player_speed*delta#(keep_speed/60)
		'''
	
	elif distance < leash_distance and target.velocity != Vector3(0,0,0):# and distance > 5:
		#move cross ahead
		#print("lead speed")
		global_position += (target.velocity.normalized())*lead_speed*delta
		
		'''
		if target.velocity.x > 0:
			global_position.x += lead_speed*delta#(lead_speed/60)
		elif target.velocity.x < 0:
			global_position.x -= lead_speed*delta#(lead_speed/60)
		if target.velocity.z > 0:
			global_position.z += lead_speed*delta#(lead_speed/60)
		elif target.velocity.z < 0:
			global_position.z -= lead_speed*delta#(lead_speed/60)
		'''
		curr = catchup_delay_duration

	elif distance < leash_distance and target.velocity == Vector3(0,0,0):# and distance > 0.2:
		#catch up speed after delay
		if curr>0:
			curr -= 1
		elif (tpos-cpos).length() > target.WIDTH / 2.0:
			global_position += (tpos-cpos).normalized()*catchup_speed*delta
			'''if xdiff > (target.WIDTH/2.0):
				global_position.x -= catchup_speed*delta
			elif xdiff < -(target.WIDTH/2.0):
				global_position.x += catchup_speed*delta
			if ydiff > (target.HEIGHT/2.0):
				global_position.z -= catchup_speed*delta
			elif ydiff < -(target.HEIGHT/2.0):	
				global_position.z += catchup_speed*delta'''
			
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
