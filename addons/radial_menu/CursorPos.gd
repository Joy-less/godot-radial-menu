class_name CursorPos
extends Control

signal hovered(index: int)
signal selected(index: int)

var count: int = 0
var touches: int = 0
var last_index: int = 0
var cursor: Vector2 = Vector2(0, 0)

func set_count(new_count: int) -> void:
	self.count = new_count

func get_index_offset() -> float:
	# Whole circle in radians divided by the number of items
	# will give us the radian step of each item
	return (2 * PI) / self.count

func get_cursor_index() -> int:
	if self.count <= 0: return 0
	
	var angle: float = Vector2.ZERO.angle_to_point(cursor.normalized())
	
	# Calculate the angle as a percentage of the entire circle
	# divided up into equal sized arcs based checked the number of items (count)
	var to_return: float = angle / get_index_offset()
	
	# Clip to the min-max of our array of buttons
	to_return = min(to_return, self.count - 1)
	
	return round(to_return)

func compute_index() -> void:
	var current_index: int = self.get_cursor_index()
	if current_index == self.last_index:
		return
	
	self.last_index = current_index
	self.emit_signal(&"hovered", current_index)

func touch_start(_event: InputEventScreenTouch) -> void:
	if touches < 1:
		cursor = Vector2(0, 0)
	touches += 1

func touch_end(_event: InputEventScreenTouch) -> void:
	touches -= 1
	if touches <= 0:
		touches = 0
		self.emit_signal(&"selected", self.get_cursor_index())

func touch_drag(event: InputEventScreenDrag) -> void:
	self.cursor += event.relative
	
	# Check for hover events
	self.compute_index()

func mouse_start(_event: InputEventMouseButton) -> void:
	if touches < 1:
		mouse_drag()
	touches += 1

func mouse_end(_event: InputEventMouseButton) -> void:
	touches -= 1
	if touches <= 0:
		touches = 0
		self.emit_signal(&"selected", self.get_cursor_index())

func mouse_drag(_event: InputEventMouseMotion = null) -> void:
	var parent: Node = self.get_parent()
	var center: Vector2 = self.get_global_position()
	
	self.cursor = -(center - self.get_global_mouse_position())
	
	# Check for hover events
	self.compute_index()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			self.touch_start(event)
		else:
			self.touch_end(event)
	elif event is InputEventScreenDrag:
		self.touch_drag(event)
	elif event is InputEventMouseButton:
		if event.pressed:
			self.mouse_start(event)
		else:
			self.mouse_end(event)
	elif event is InputEventMouseMotion:
		self.mouse_drag(event)
