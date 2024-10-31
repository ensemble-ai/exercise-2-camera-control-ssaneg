class_name FramingWithHorizontalAutoscroll
extends CameraControllerBase

@export var top_left:Vector2 = Vector2(-10,5)
@export var bottom_right:Vector2 = Vector2(10,-5)
@export var autoscroll_speed:Vector3 = Vector3(25,0,0)

func _ready():
	position = target.position
	
func _process(delta: float):
	if !current:
		return
	if draw_camera_logic:
		draw_logic()
	
	#autoscroll
	global_position += autoscroll_speed*delta
	var box_width = abs(top_left.x - bottom_right.x)
	var box_height = abs(top_left.y - bottom_right.y)
	
	#left edge
	if (target.global_position.x - target.WIDTH / 2.0) < (global_position.x - box_width/2.0):
		target.global_position.x = global_position.x - box_width/2.0 + target.WIDTH / 2.0
		
	#right edge
	if (target.global_position.x + target.WIDTH / 2.0) > (global_position.x + box_width/2.0):
		target.global_position.x = global_position.x + box_width/2.0 - target.WIDTH / 2.0
	
	#top edge
	if (target.global_position.z - target.WIDTH / 2.0) < (global_position.z - box_height/2.0):
		target.global_position.z = global_position.z - box_height/2.0 + target.WIDTH / 2.0
		
	#bottom edge
	if (target.global_position.z + target.WIDTH / 2.0) > (global_position.z + box_height/2.0):
		target.global_position.z = global_position.z + box_height/2.0 - target.WIDTH / 2.0
		
	super(delta)
	
func draw_logic():
	
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var box_width = abs(top_left.x - bottom_right.x)
	var box_height = abs(top_left.y - bottom_right.y)
	
	var left:float = -box_width / 2
	var right:float = box_width / 2
	var top:float = -box_height / 2
	var bottom:float = box_height / 2
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
