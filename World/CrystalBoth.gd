extends AnimatedSprite


func _ready():
	var rand = rand_range(0,1)
	var frame = int(rand_range(0,30))
	self.set_frame(frame)
	if rand <= 5:
		self.flip_h = true
