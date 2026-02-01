extends Node
class_name SoundManager

var availableSFX : Array = []
var queueSFX : Array = []
var availableBGM = AudioStreamPlayer.new()
var fadingBGM = AudioStreamPlayer.new()
var savedBGM : Array = []
var priorityBGM : Array = []

func _ready():
	# Wait for ready function to finish.
	set_process(false)
	
	# Always runs even when paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Initializes available players for SFX.
	var num_playersSFX : int = 64
	
	for players in num_playersSFX:
		var playerSFX = AudioStreamPlayer.new()
		availableSFX.append(playerSFX)
		playerSFX.finished.connect(_on_SFX_finished.bind(playerSFX))
		playerSFX.volume_db = 0
		playerSFX.bus = "SFX"
		add_child(playerSFX)
		
	# Initializes the BGM players.
	availableBGM.volume_db = 0
	availableBGM.bus = "BGM"
	fadingBGM.volume_db = 0
	fadingBGM.bus = "BGM"
	add_child(fadingBGM)
	add_child(availableBGM)
	
	# Starts the manager.
	set_process(true)

func _on_SFX_finished(stream):
	# Clears player when finished playing SFX.
	availableSFX.append(stream)

func fadeOutBGM(duration : float = 10.0):
	if availableBGM.playing:
		fadingBGM.stream = load(priorityBGM[0])
		fadingBGM.set_volume_db(linear_to_db(priorityBGM[1]))
		fadingBGM.play(availableBGM.get_playback_position())
		availableBGM.stop()

		var tween = create_tween()
		tween.tween_property(fadingBGM, "volume_db", -80, duration)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.connect("finished", Callable(self, "_onFadeOutComplete"))

func _onFadeOutComplete():
	fadingBGM.stop()

func playSFX(filename : String, volume : float = 1):
	# Primary function to call for SFX.
	queueSFX.append([filename, volume])

func playBGM(filename : String, volume : float = 1, time : float = 0.0):
	# Primary function to call to put a BGM onto priority stack. The last called BGM will play. Will not accept BGM that is already on the stack.
	if priorityBGM:
		if priorityBGM[0] == (filename) and priorityBGM[1] == volume:
			print("Already playing BGM: ", filename)
			return
	priorityBGM = [filename, volume, time]
	
func clearBGM():
	# Clears the latest BGM from the priority stack. Resumes next BGM if there is one.
	if priorityBGM : priorityBGM.clear()
	if savedBGM : priorityBGM = savedBGM.pop_back()
	
func clearAllBGM():
	# Clears the entire BGM priority stack.
	savedBGM.clear()
	priorityBGM.clear()

func _process(_delta):
	# Plays queued sound when there is an available slot.
	if queueSFX and availableSFX:
		var playingSFX = queueSFX.pop_front()
		availableSFX[0].stream = load(playingSFX[0])
		availableSFX[0].set_volume_db(linear_to_db(playingSFX[1]))
		availableSFX[0].play()
		availableSFX.pop_front()
	# Plays BGM on top of priority stack.
	if priorityBGM:
		if !savedBGM:
			availableBGM.stream = load(priorityBGM[0])
			availableBGM.set_volume_db(linear_to_db(priorityBGM[1]))
			availableBGM.play(priorityBGM[2])
			savedBGM.append(priorityBGM)
		if savedBGM:
			if priorityBGM[0] != savedBGM.back()[0] and priorityBGM[1] != savedBGM.back()[1]:
				if availableBGM.stream:
					savedBGM.back()[2] = availableBGM.get_playback_position()
					availableBGM.stream = load(priorityBGM[0])
					availableBGM.set_volume_db(linear_to_db(priorityBGM[1]))
					availableBGM.play(priorityBGM[2])
					savedBGM.append(priorityBGM)
			else:
				if !availableBGM:
					availableBGM.stream = load(priorityBGM[0])
					availableBGM.set_volume_db(linear_to_db(priorityBGM[1]))
					availableBGM.play(priorityBGM[2])
	
