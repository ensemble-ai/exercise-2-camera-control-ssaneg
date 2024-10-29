class_name StageFiveCamera
extends CameraControllerBase

@export var push_ratio:float = 0.3
@export var pushbox_top_left:Vector2 = Vector2(-7.5,7.5)
@export var pushbox_bottom_right:Vector2 = Vector2(7.5,-7.5)
@export var speedup_zone_top_left:Vector2 = Vector2(-5,5)
@export var speedup_zone_bottom_right:Vector2 = Vector2(5,-5)

func _ready():
	position = target.position
	
func _process(delta: float):
	if !current:
		return

	if draw_camera_logic:
		draw_logic()
	
	var box_width = pushbox_bottom_right.x - pushbox_top_left.x
	var box_height = pushbox_top_left.y - pushbox_bottom_right.y
	
	var inner_box_width = speedup_zone_bottom_right.x - speedup_zone_top_left.x
	var inner_box_height = speedup_zone_top_left.y - speedup_zone_bottom_right.y
	
	var tpos = target.global_position
	var cpos = global_position
	
	var player_speed = float(target.BASE_SPEED)#50.0
	
	#boundaries of pushbox
	var diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - (cpos.x - box_width / 2.0)
	var diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - (cpos.x + box_width / 2.0)
	var diff_between_top_edges = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - box_height / 2.0)
	var diff_between_bottom_edges = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + box_height / 2.0)
	
	#speedup zone
	var diff_between_left_inner = (tpos.x - target.WIDTH / 2.0) - (cpos.x - inner_box_width / 2.0)
	var diff_between_right_inner = (tpos.x + target.WIDTH / 2.0) - (cpos.x + inner_box_width / 2.0)
	var diff_between_top_inner = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - inner_box_height / 2.0)
	var diff_between_bottom_inner = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + inner_box_height / 2.0)
	
	var temp = player_speed*delta*push_ratio
	
	#print(diff_between_bottom_inner, ' ', diff_between_left_inner, ' ', diff_between_right_inner, ' ', diff_between_top_inner)
	
	#inner-most area
	if diff_between_left_inner > 0 and diff_between_right_inner < 0 and diff_between_top_inner > 0 and diff_between_bottom_inner < 0:
		print("not moving camera in inner most area")
		pass
		
	#1) moving, 2) not touching the outer zone pushbox, and 3) are betwen the speedup zone and the pushbox border -> move at push ratio
	elif target.velocity != Vector3(0,0,0) and (diff_between_left_edges > 0 and diff_between_top_edges > 0 and diff_between_right_edges < 0 and diff_between_bottom_edges < 0) and (diff_between_left_inner < 0 or diff_between_right_inner > 0 or diff_between_top_inner < 0 or diff_between_bottom_inner > 0):
		print("case 1 - push ratio * player speed")
		if target.velocity.x > 0:
			global_position.x += temp
		elif target.velocity.x < 0:
			global_position.x -= temp
		if target.velocity.z > 0:
			global_position.z += temp
		elif target.velocity.z < 0:
			global_position.z -= temp
			
	#full player speed in both x and y directions in corners
	#top left
	elif diff_between_left_edges < 0.1 and diff_between_top_edges < 0.1:
		print("top left")
		global_position.x -= player_speed*delta#diff_between_left_edges
		global_position.z -= player_speed*delta#diff_between_top_edges
	#bottom left
	elif diff_between_left_edges < 0.1 and diff_between_bottom_edges > 0.1:
		print("bottom left")
		global_position.x -= player_speed*delta#diff_between_left_edges
		global_position.z += player_speed*delta#diff_between_bottom_edges
	#top right
	elif diff_between_right_edges > 0.1 and diff_between_top_edges < 0.1:
		print("top right")
		global_position.x += player_speed*delta#diff_between_right_edges
		global_position.z -= player_speed*delta#diff_between_top_edges
	#bottom right
	elif diff_between_right_edges > 0.1 and diff_between_bottom_edges > 0.1:
		print("bottom right")
		global_position.x += player_speed*delta#diff_between_right_edges
		global_position.z += player_speed*delta#diff_between_bottom_edges
	
	#current movement speed in the direction of the touched side of the border box and at the push_ratio in the other direction
	#left edge
	elif diff_between_left_edges < 0:
		print("left edge")
		global_position.x += diff_between_left_edges
		if target.velocity.z > 0:
			global_position.z += temp
		elif target.velocity.z < 0:
			global_position.z -= temp
	#right edge
	elif diff_between_right_edges > 0:
		print("right edge")
		global_position.x += diff_between_right_edges
		if target.velocity.z > 0:
			global_position.z += temp
		elif target.velocity.z < 0:
			global_position.z -= temp
	#bottom edge
	elif diff_between_bottom_edges > 0:
		print("bottom edge")
		global_position.z += diff_between_bottom_edges
		if target.velocity.x > 0:
			global_position.x += temp
		elif target.velocity.x < 0:
			global_position.x -= temp
	#top edge
	elif diff_between_top_edges < 0:
		print("top edge")
		global_position.z += diff_between_top_edges
		if target.velocity.x > 0:
			global_position.x += temp
		elif target.velocity.x < 0:
			global_position.x -= temp
	
	super(delta)
	
func draw_logic():
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	'immediate_mesh.surface_add_vertex(Vector3(-2.5, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(2.5, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, -2.5))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, 2.5))'
	
	#pushbox
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_top_left.y))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_bottom_right.x, 0, pushbox_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_top_left.x, 0, pushbox_top_left.y))
	
	
	#speedup zone
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_top_left.y))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_top_left.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_bottom_right.x, 0, speedup_zone_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_bottom_right.y))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_bottom_right.y))
	immediate_mesh.surface_add_vertex(Vector3(speedup_zone_top_left.x, 0, speedup_zone_top_left.y))
	
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
