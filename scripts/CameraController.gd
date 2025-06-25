extends Camera2D

@export var zoom_limits := Vector2(0.5, 1.5) # x = min zoom, y = max zoom
@export var margin := 300.0
@export var max_inclusion_distance := 1500.0
@export var zoom_speed := 5.0

var players = []

func _process(delta):
	if players.size() == 0:
		return

	# Find center and included players
	var center := Vector2.ZERO
	var included_players: Array[Node2D]= []
	for player in players:
		if player.global_position.distance_to(global_position) < max_inclusion_distance:
			included_players.append(player)
			center += player.global_position

	if included_players.size() == 0:
		return

	center /= included_players.size()

	# Calculate bounds around included players
	var min_pos := included_players[0].global_position
	var max_pos := included_players[0].global_position

	for player in included_players:
		var pos := player.global_position
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		max_pos.x = max(max_pos.x, pos.x)
		max_pos.y = max(max_pos.y, pos.y)

	var size = max_pos - min_pos + Vector2(margin, margin)

	# Calculate desired zoom: bigger bounding box → zoom out
	var viewport_size = get_viewport_rect().size
	var zoom_x = size.x / viewport_size.x
	var zoom_y = size.y / viewport_size.y
	var desired_zoom = clamp(max(zoom_x, zoom_y), zoom_limits.x, zoom_limits.y)

	# Apply center and zoom smoothly
	global_position = lerp(global_position, center, delta * zoom_speed)
	zoom = lerp(zoom, Vector2.ONE * desired_zoom, delta * zoom_speed)
