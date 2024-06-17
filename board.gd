extends TileMap
@export var acceleration:int=0
@export var speed:int=1
@export var width:int=10
@export var height:int=24

const pieces_ofset=3
const rotations=[0,0.5*PI,PI,1.5*PI]
var active_piece_id:int # an int reperesenting the index of the active piece in the template list.
var active_piece_position:Vector2i # reperesents the active pieces location.
var active_piece_rotation:int # 0=no rotation 1=90deg clockwise 2=180 flip 3=90deg anticlockwise
var piece_templates:Array=[
	[   # I
		Vector2i(-2,0),
		Vector2i(-1,0),
		Vector2i(0,0),
		Vector2i(1,0),
	],
	[   # J
		Vector2i(-2,-1),
		Vector2i(-2,0),
		Vector2i(-1,0),
		Vector2i(0,0),
	],
	[   # L
		Vector2i(-2,0),
		Vector2i(-1,0),
		Vector2i(0,0),
		Vector2i(0,-1),
	],
	[   # O
		Vector2i(-1,0),
		Vector2i(0,0),
		Vector2i(-1,-1),
		Vector2i(0,-1),
	],
	[   # S
		Vector2i(-2,0),
		Vector2i(-1,0),
		Vector2i(-1,-1),
		Vector2i(0,-1),
	],
	[   # T
		Vector2i(-2,0),
		Vector2i(-1,0),
		Vector2i(0,0),
		Vector2i(-1,-1),
	],
	[   # Z
		Vector2i(-2,-1),
		Vector2i(-1,0),
		Vector2i(-1,-1),
		Vector2i(0,0),
	],
]

var rng=RandomNumberGenerator.new()

func _ready():
	setup(width,height)
	next_piece()

func _process(delta):
	if Input.is_action_just_pressed("move left"):
		if can_move_piece(Vector2i.LEFT):
			move_piece(Vector2i.LEFT)
	if Input.is_action_just_pressed("move right"):
		if can_move_piece(Vector2i.RIGHT):
			move_piece(Vector2i.RIGHT)
	if Input.is_action_just_pressed("move down"):
		if can_move_piece(Vector2i.DOWN):
			move_piece(Vector2i.DOWN)
	if Input.is_action_just_pressed("rotate anticlockwise"): # Z
		if can_rotate_piece(-1):
			rotate_piece(-1)
	if Input.is_action_just_pressed("rotate clockwise"): # UP ARROW
		if can_rotate_piece(1):
			rotate_piece(1)
	if Input.is_action_just_pressed("harddrop"): # SPACE
		while can_move_piece(Vector2i.DOWN):
			move_piece(Vector2i.DOWN)
		next_piece()

func rotate_piece(rot:int):
	# this order is important.
	remove_active_piece() # first the piece must be removed so it can be moved.
	active_piece_rotation=circularify(active_piece_rotation+rot) # rotate the piece.
	place_hint() # place the hint before placing the piece.
	place_active_piece() # then place the piece.
	# placing the piece after the hint means that when the piece and hint overlap, as
	# they do when the piece is at the bottom, the piece is drawn over the top.

func circularify(index:int):
	while index<0:
		index+=4
	while index>3:
		index-=4
	return index

func can_rotate_piece(rot:int):
	return true # TODO

func move_after_rotating():
	for i in rotated_array(piece_templates[active_piece_id],active_piece_rotation):
		i=i+active_piece_position
		if get_cell_source_id(0,i)==0 or get_cell_source_id(1,i) in [3,4,5,6,7,8,9]:
			var x=1
			while true:
				
				
				assert(x!=0,"x cannot be 0. Somethings wrong. 🎷")
				if x>0:
					x=-x
				elif x<0:
					x=-x+1

func rotated_array(array,rotation_rad):
	var x=[]
	for i in array:
		i=Vector2(i)
		i=i.rotated(rotation_rad)
		x.append(Vector2i(i))
	return x

func place_active_piece():
	# draw the active piece to the board.
	for i in rotated_array(piece_templates[active_piece_id],rotations[active_piece_rotation]):
		set_cell(1,i+active_piece_position,active_piece_id+pieces_ofset,Vector2i.ZERO)

func remove_active_piece():
	# remove the active piece from the board.
	for i in rotated_array(piece_templates[active_piece_id],rotations[active_piece_rotation]):
		set_cell(1,i+active_piece_position,-1)

func move_piece(direction:Vector2i):
	# this order is important.
	remove_active_piece() # first the piece must be removed so it can be moved.
	active_piece_position+=direction # move the piece.
	place_hint() # place the hint before placing the piece.
	place_active_piece() # then place the piece.
	# placing the piece after the hint means that when the piece and hint overlap, as
	# they do when the piece is at the bottom, the piece is drawn over the top.

var current_hint=[]
func place_hint():
	for i in current_hint:
		set_cell(1,i,-1)
	current_hint=[]
	for i in rotated_array(piece_templates[active_piece_id],rotations[active_piece_rotation]).duplicate():
		current_hint.append(i+active_piece_position)
	while can_move_piece(Vector2i.DOWN,current_hint):
		var x=[]
		for i in current_hint:
			x.append(i+Vector2i.DOWN)
		current_hint=x
	for i in current_hint:
		set_cell(1,i,active_piece_id+pieces_ofset+8,Vector2i.ZERO)

func can_move_piece(direction:Vector2i,piece=null):
	if piece==null:
		# default to the active piece
		piece=[]
		for i in rotated_array(piece_templates[active_piece_id],rotations[active_piece_rotation]):
			piece.append(i+active_piece_position)
	for i in piece:
		# if the cell is part of this piece
		if i+direction in piece:
			continue
		
		# if the cell is a wall
		if get_cell_source_id(0,i+direction)==0:
			return false
		
		# if the cell is another piece
		if get_cell_source_id(1,i+direction) in [3,4,5,6,7,8,9]:
			return false
	return true

func setup(width,height):
	clear()
	# set up the border
	for w in range(width+2):
		for h in range(height+1): # the plus on on the heights is so that there is no border at the top.
			set_cell(0,Vector2i(w,h+1),0,Vector2i.ZERO)
	
	# set up the background
	for h in range(height):
		for w in range(width):
			set_cell(0,Vector2i(w+1,h+1),((((h+1)%2)+(w+1))%2)+1,Vector2i.ZERO)

func next_piece():
	"""
	This method freezes the active piece and moves on to the next one.
	"""
	# note the lack of the usual removing of the active piece.
	active_piece_id=rng.randi_range(0,len(piece_templates)-1)
	active_piece_position=Vector2i(floor(width/2)+1,0)
	place_active_piece()
	current_hint=[]

func check_rows_for_deletion():
	for row in range(1,height+1): # because second arg is exclusive and we want to start at 1.
		var all_full=true
		for cell in range(1,width+1): # same reason
			if not get_cell_source_id(1,Vector2i(cell,row)) in range(pieces_ofset,len(piece_templates)+pieces_ofset):
				all_full=false
		if all_full:
			for x in range(1,width+1):
				if Vector2i(x,row)-active_piece_position in rotated_array(piece_templates[active_piece_id],rotations[active_piece_rotation]):
					continue
				set_cell(1,Vector2i(x,row),get_cell_source_id(1,Vector2i(x,row-1)),Vector2i.ZERO)
				set_cell(1,Vector2i(x,row-1),-1)

func next_frame():
	"""
	This method moves the active piece down one block and calles next_piece if needed.
	It also handles the clearing of rows.
	"""
	if can_move_piece(Vector2i.DOWN):
		move_piece(Vector2i.DOWN)
	else:
		next_piece()
	check_rows_for_deletion()

func _on_timer_timeout():
	next_frame()
