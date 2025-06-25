extends Camera2D

@export var zoom_limits := Vector2(0.5, 1.5) # x = min zoom, y = max zoom
@export var margin := 800.0
@export var max_inclusion_x = 1500
@export var max_inclusion_y = 1000
@export var zoom_speed := 5.0

var players = []

func _process(delta):
	if players.size() == 0:
		return

	# Find center and included players
	var min_pos := Vector2.ZERO
	var max_pos := Vector2.ZERO
	
	for player in players:
		var pos: Vector2 = player.global_position
		if pos.x < -max_inclusion_x:
			min_pos.x = -max_inclusion_x
		elif pos.x > max_inclusion_x:
			max_pos.x = max_inclusion_x
		else:
			min_pos.x = min(min_pos.x, pos.x)
			max_pos.x = max(max_pos.x, pos.x)
		
		if pos.y < -max_inclusion_y:
			min_pos.y = -max_inclusion_y
		elif pos.y > max_inclusion_y:
			max_pos.y = max_inclusion_y
		else:
			min_pos.y = min(min_pos.y, pos.y)
			max_pos.y = max(max_pos.y, pos.y)
		
	var center := (max_pos + min_pos) / 2.0
	var size = max_pos - min_pos + Vector2(margin, margin)

	# Calculate desired zoom: bigger bounding box → zoom out
	var viewport_size = get_viewport_rect().size
	var zoom_x = viewport_size.x / size.x
	var zoom_y = viewport_size.y / size.y
	var desired_zoom = clamp(max(zoom_x, zoom_y), zoom_limits.x, zoom_limits.y)

	# Apply center and zoom smoothly
	global_position = lerp(global_position, center, delta * zoom_speed)
	zoom = lerp(zoom, Vector2.ONE * desired_zoom, delta * zoom_speed)
