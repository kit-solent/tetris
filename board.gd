extends TileMap
@export var acceleration:int=0
@export var speed:int=1
@export var width:int=10
@export var height:int=24

func _ready():
	setup_board()

func setup_board():
	for w in range(width):
		for h in range(height):
			set_cell(0,Vector2i(w,h),)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
