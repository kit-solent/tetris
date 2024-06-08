extends TileMap
@export var acceleration:int=0
@export var speed:int=1
@export var width:int=10
@export var height:int=24

var active_piece:Array # An array of the cell coordinates of the active piece
var active_piece_type:int
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
		print("hmm")
		if can_move_piece(Vector2i.LEFT):
			print("humm")
			move_piece(Vector2i.LEFT)
	if Input.is_action_just_pressed("move right"):
		if can_move_piece(Vector2i.RIGHT):
			move_piece(Vector2i.RIGHT)

func move_piece(direction:Vector2i):
	# remove the active piece from the board
	for i in active_piece:
		set_cell(1,i,-1,Vector2i.ZERO)
	
	# move the active piece
	var new=[]
	for i in active_piece:
		new.append(i+direction)
	active_piece=new
	
	# put the active piece back on the board
	for i in active_piece:
		set_cell(1,i,active_piece_type,Vector2i.ZERO)

func can_move_piece(direction:Vector2i):
	for i in active_piece:
		# if the cell is part of this piece
		if i+direction in active_piece:
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
	
	# set up the piece templates so that they start in the middle.
	var new=[]
	for i in piece_templates:
		new.append([])
		for a in i: #                 floor because tiles should tend left
			new[-1].append(a+Vector2i(floor(width/2)+1,0))
	piece_templates=new

func next_piece():
	"""
	This method freezes the active piece and moves on to the next one.
	"""
	for i in active_piece:
		set_cell(1,i,active_piece_type,Vector2i.ZERO)

	var num=rng.randi_range(0,len(piece_templates)-1)
	active_piece=piece_templates[num]
	active_piece_type=num+3 # because there are three non-tetrominoes in the list (the border and the two backgrounds)
	
	for i in active_piece:
		set_cell(1,i,active_piece_type,Vector2i.ZERO)

func next_frame():
	"""
	This method moves the active piece down one block and calles next_piece if needed.
	"""
	if can_move_piece(Vector2i.DOWN):
		move_piece(Vector2i.DOWN)
	else:
		next_piece()

func _on_timer_timeout():
	next_frame()
