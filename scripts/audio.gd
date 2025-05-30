extends Node

@onready var rifle = $Rifle
@onready var door = $Door
@onready var broken_glass = $"Broken Glass"
@onready var pistol = $Pistol
@onready var silenced_pistol = $"Silenced Pistol"
@onready var turn = $Turn
@onready var rifle_reload = $"Rifle Reload"
@onready var pistol_reload = $"Pistol Reload"
@onready var pistol_switch = $"Pistol Switch"
@onready var rifle_switch = $"Rifle Switch"
@onready var flashbang = $Flashbang
@onready var glass_shatter = $"Glass Shatter"
@onready var broken_door = $"Broken Door"
@onready var ricochet = $Ricochet
@onready var human_pain = $"Human Pain"
@onready var human_death = $"Human Death"
@onready var flashbang_deploy = $"Flashbang Deploy"
var sfx_dict := {}

func _ready():
	sfx_dict["rifle"] = rifle
	sfx_dict["door"] = door
	sfx_dict["broken_glass"] = broken_glass
	sfx_dict["pistol"] = pistol
	sfx_dict["silenced_pistol"] = silenced_pistol
	sfx_dict["turn"] = turn
	sfx_dict["rifle_reload"] = rifle_reload
	sfx_dict["pistol_reload"] = pistol_reload
	sfx_dict["pistol_switch"] = pistol_switch
	sfx_dict["rifle_switch"] = rifle_switch
	sfx_dict["flashbang"] = flashbang
	sfx_dict["glass_shatter"] = glass_shatter
	sfx_dict["broken_door"] = broken_door
	sfx_dict["ricochet"] = ricochet
	sfx_dict["human_pain"] = human_pain
	sfx_dict["human_death"] = human_death
	sfx_dict["flashbang_deploy"] = flashbang_deploy

func play_sound(sfx : String):
	if sfx in sfx_dict:
		sfx_dict[sfx].play()
	else:
		print("Sound effect not found: " + sfx)
