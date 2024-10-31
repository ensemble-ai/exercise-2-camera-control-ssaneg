class_name FourWaySpeedupPushZone
extends CameraControllerBase

@export var push_ratio:float = 0.4
@export var pushbox_top_left:Vector2 = Vector2(-7,7)
@export var pushbox_bottom_right:Vector2 = Vector2(7,-7)
@export var speedup_zone_top_left:Vector2 = Vector2(-4,4)
@export var speedup_zone_bottom_right:Vector2 = Vector2(4,-4)

func _ready():
	position = target.position
	
func _process(delta: float):
	if !current:
		return

	if draw_camera_logic:
		draw_logic()
	
	#pushbox height and width
	var box_width = pushbox_bottom_right.x - pushbox_top_left.x
	var box_height = pushbox_top_left.y - pushbox_bottom_right.y
	
	#inner box height and width
	var inner_box_width = speedup_zone_bottom_right.x - speedup_zone_top_left.x
	var inner_box_height = speedup_zone_top_left.y - speedup_zone_bottom_right.y
	
	var tpos = target.global_position
	var cpos = global_position
	
	var player_speed = target.velocity.length()
	var direction = target.velocity.normalized()
	
	#boundaries of pushbox
	var diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - (cpos.x - box_width / 2.0)
	var diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - (cpos.x + box_width / 2.0)
	var diff_between_top_edges = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - box_height / 2.0)
	var diff_between_bottom_edges = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + box_height / 2.0)
	
	#inner boundaries of speedup zone
	var diff_between_left_inner = (tpos.x - target.WIDTH / 2.0) - (cpos.x - inner_box_width / 2.0)
	var diff_between_right_inner = (tpos.x + target.WIDTH / 2.0) - (cpos.x + inner_box_width / 2.0)
	var diff_between_top_inner = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - inner_box_height / 2.0)
	var diff_between_bottom_inner = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + inner_box_height / 2.0)
	
	#booleans for corners
	var bottom_right = diff_between_right_edges >= 0 and diff_between_bottom_edges >= 0 
	var top_right = (diff_between_right_edges > 0 or diff_between_right_edges == 0) and (diff_between_top_edges < 0 or diff_between_top_edges == 0)
	var bottom_left = diff_between_left_edges <= 0 and diff_between_bottom_edges >= 0
	var top_left = diff_between_left_edges <= 0 and diff_between_top_edges <= 0
		
	#speedup zone
	if target.velocity != Vector3(0,0,0) and (diff_between_left_edges > 0 and diff_between_top_edges > 0 and diff_between_right_edges < 0 and diff_between_bottom_edges < 0) and (diff_between_left_inner < 0 or diff_between_right_inner > 0 or diff_between_top_inner < 0 or diff_between_bottom_inner > 0):
		global_position += direction*player_speed*push_ratio*delta
	
	#corners
	elif top_left or top_right or bottom_left or bottom_right:
		if top_left:
			global_position.x += diff_between_left_edges
			global_position.z += diff_between_top_edges
		if top_right:
			global_position.x += diff_between_right_edges
			global_position.z += diff_between_top_edges
		if bottom_left:
			global_position.x += diff_between_left_edges
			global_position.z += diff_between_bottom_edges
		if bottom_right:
			global_position.x += diff_between_right_edges
			global_position.z += diff_between_bottom_edges
	
	elif diff_between_left_edges <= 0 or diff_between_right_edges >= 0 or diff_between_bottom_edges >= 0 or diff_between_top_edges <= 0:
		#left edge
		if diff_between_left_edges <= 0:
			global_position.x += diff_between_left_edges
			global_position.z += direction.z*player_speed*push_ratio*delta
		#right edge
		elif diff_between_right_edges >= 0:
			global_position.x += diff_between_right_edges
			global_position.z += direction.z*player_speed*push_ratio*delta
		#bottom edge
		elif diff_between_bottom_edges >= 0:
			global_position.z += diff_between_bottom_edges
			global_position.x += direction.x*player_speed*push_ratio*delta
		#top edge
		elif diff_between_top_edges <= 0:
			global_position.z += diff_between_top_edges
			global_position.x += direction.x*player_speed*push_ratio*delta
		
	#inner-most area
	elif diff_between_left_inner > 0 and diff_between_right_inner < 0 and diff_between_top_inner > 0 and diff_between_bottom_inner < 0:
		pass
		
	super(delta)
	
func draw_logic():
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
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
