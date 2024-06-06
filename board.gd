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

func setup(width,height):
	clear()
	# set up the border
	for w in range(width+2):
		for h in range(height+2):
			set_cell(0,Vector2i(w,h),0,Vector2i.ZERO)
	
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

	var num=rng.randi_range(0,len(piece_templates))
	active_piece=piece_templates[num]
	active_piece_type=num+3 # because there are three non-tetrominoes in the list (the border and the two backgrounds)
	
	for i in active_piece:
		set_cell(1,i,active_piece_type,Vector2i.ZERO)

func next_frame():
	"""
	This method moves the active piece down one block and calles next_piece if needed.
	"""
	# remove the active piece from the board
	for i in active_piece:
		set_cell(1,i,-1,Vector2i.ZERO)
	
	# move the active piece down one space
	var new=[]
	for i in active_piece:
		new.append(i+Vector2i.DOWN)
	active_piece=new
	
	# put the active piece back on the board
	for i in active_piece:
		set_cell(1,i,active_piece_type,Vector2i.ZERO)
	
	check_piece()

func check_piece():
	if len(active_piece)==0:
		next_piece()
	for i in active_piece:
		# if the cell is another active piece cell then ignore
		if i+Vector2i.DOWN in active_piece:
			continue
		# if the cell is occupied by another piece
		if get_cell_source_id(1,i+Vector2i.DOWN)!=-1:
			next_piece()
			return
		# if the cell is a border cell
		elif get_cell_source_id(0,i+Vector2i.DOWN)==0:
			next_piece()
			return

func _on_timer_timeout():
	next_frame()
