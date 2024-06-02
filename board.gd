extends TileMap
@export var acceleration:int=0
@export var speed:int=1
@export var width:int=10
@export var height:int=24

func _ready():
	setup_board()

func setup_board():
	clear()
	# set up the background
	for w in range(width+2):
		for h in range(height+2):
			set_cell(0,Vector2i(w,h),(((h%2)+w)%2)+1)
			print(tile_set.get_source((((h%2)+w)%2)+1).resource_name)

func _process(delta):
	pass
