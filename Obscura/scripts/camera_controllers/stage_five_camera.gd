class_name StageFiveCamera
extends CameraControllerBase

@export var push_ratio:float = 5
@export var pushbox_top_left:Vector2 = Vector2(-5,5)
@export var pushbox_bottom_right:Vector2 = Vector2(5,-5)
@export var speedup_zone_top_left:Vector2 = Vector2(-2.5,2.5)
@export var speedup_zone_bottom_right:Vector2 = Vector2(2.5,-2.5)

func _ready():
	position = target.position
	
func _process(delta: float):
	if !current:
		return

	if draw_camera_logic:
		draw_logic()
		
	# if target.velocity != Vector3(0,0,0) or #not touching outer zone
	# camera_speed = target.BASE_SPEED*push_ratio in direction of movement
	var tpos = target.global_position
		
	'''
	move at the target_speed*push_ratio  in the direction of target's movement
	 	1) moving 
		2) not touching the outer zone pushbox
		3) between the speedup zone and the pushbox border 
	
	Touching one side of the outer pushbox 
		move at the target's current movement speed in the 
		direction of the touched side of the border box and 
		at the push_ratio in the other direction 
		(e.g., when the target is touching the top middle 
		of the pushing box but is moving to the upper right, 
		the camera will move at the target's speed in the y direction 
		but at the push_ratio in the x direction). 
	'''
	'''	
	If the target touches two sides of the outer pushbox 
	(i.e., the player is in the corner of the box) 
		camera will move at full player speed in both 
		x and y directions.
	''' 
	if (tpos.x == pushbox_bottom_right.x and tpos.z == pushbox_bottom_right.y) or (tpos.x == pushbox_top_left.x and tpos.z == pushbox_top_left.y) or (tpos.x == pushbox_bottom_right.x and tpos.z == pushbox_top_left.y) or (tpos.x == pushbox_top_left.x and tpos.z == pushbox_bottom_right.y):
		pass
	'''
	If the target moves within the inner-most area (i.e., inside the speedup zone's border and not between 
	the speedup zone the outer pushbox), the camera should not move.
	'''
	if tpos.x < speedup_zone_bottom_right.x and tpos.x > speedup_zone_top_left.x and tpos.z > speedup_zone_bottom_right.y and tpos.z < speedup_zone_top_left.y:
		#camera should not move
		pass
	
	
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
