class_name StageThreeCamera
extends CameraControllerBase

@export var follow_speed:float = 8
@export var catchup_speed:float = 15
@export var leash_distance:float = 10

func _ready():
	position = target.position
	
func _process(delta: float):
	if !current:
		return

	if draw_camera_logic:
		draw_logic()
		
	#var term1 = pow(target.global_position.x-global_position.x,2)
	#var term2 = pow(target.global_position.z-global_position.z,2)
	#var distance = sqrt(term1 + term2)
	
	var tpos = target.global_position
	var cpos = global_position
	cpos.y -= 10
	var distance = (tpos-cpos).length()
	
	var xdiff = target.global_position.x-global_position.x
	var ydiff = target.global_position.z-global_position.z
	
	var player_speed = float(target.BASE_SPEED)
	
	if distance >= leash_distance:
		print("leash distance exceeded")
		global_position += (tpos-cpos).normalized()*player_speed*delta
		'''if xdiff > target.WIDTH:#0.1:
			global_position.x += player_speed*delta#(keep_speed/60)
		elif xdiff < -target.WIDTH:#-0.1:
			global_position.x -= player_speed*delta#(keep_speed/60)
		if ydiff > target.HEIGHT:#0.1:
			global_position.z += player_speed*delta#(keep_speed/60)
		elif ydiff < -target.HEIGHT:#-0.1:
			global_position.z -= player_speed*delta#(keep_speed/60)
		'''
		print(global_position)
	
	elif distance < leash_distance and target.velocity != Vector3(0,0,0) and distance > 0.2:
		#print("velocity not zero")
		# move at follow speed
		global_position += (tpos-cpos).normalized()*follow_speed*delta
		'''
		if xdiff > target.WIDTH:#0.1:
			global_position.x += follow_speed*delta#(follow_speed/60)#*xdiff
		elif xdiff < -target.WIDTH:#-0.1:
			global_position.x -= follow_speed*delta#(follow_speed/60)
		if ydiff > target.HEIGHT:#0.1:
			global_position.z += follow_speed*delta#(follow_speed/60)#*ydiff
		elif ydiff < -target.HEIGHT:#-0.1:
			global_position.z -= follow_speed*delta#(follow_speed/60)
		'''
	elif distance < leash_distance and target.velocity == Vector3(0,0,0) and distance > 0.2:
		#print("velocity zero")
		global_position += (tpos-cpos).normalized()*catchup_speed*delta
		'''
		if xdiff > 0.1:
			global_position.x += catchup_speed*delta#(catchup_speed/60)#*xdiff
		elif xdiff < -0.1:
			global_position.x -= catchup_speed*delta#(catchup_speed/60)
		if ydiff > 0.1:
			global_position.z += catchup_speed*delta#(catchup_speed/60)#*ydiff
		elif ydiff < -0.1:
			global_position.z -= catchup_speed*delta#(catchup_speed/60)
		'''
		
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
