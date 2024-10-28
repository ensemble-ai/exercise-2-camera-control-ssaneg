class_name StageFourCamera
extends CameraControllerBase

@export var lead_speed:float
@export var catchup_delay_duration:float
@export var catchup_speed:float
@export var leash_distance:float

func _ready():
	position = target.position
	
func _process(delta: float):
	if !current:
		return

	if draw_camera_logic:
		draw_logic()
		
	
	super(delta)
	
func draw_logic():
	pass
