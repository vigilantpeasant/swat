extends Node

@onready var rifle := $Rifle
@onready var door := $Door
@onready var broken_glass := $"Broken Glass"
@onready var pistol := $Pistol
@onready var silenced_pistol := $"Silenced Pistol"
@onready var turn := $Turn
@onready var rifle_reload := $"Rifle Reload"
@onready var pistol_reload := $"Pistol Reload"
@onready var smg_reload := $"SMG Reload"
@onready var pistol_switch := $"Pistol Switch"
@onready var rifle_switch := $"Rifle Switch"
@onready var smg_switch := $"SMG Switch"
@onready var smg_shoot := $"SMG Shoot"
@onready var flashbang := $Flashbang
@onready var glass_shatter := $"Glass Shatter"
@onready var broken_door := $"Broken Door"
@onready var door_hit := $"Door Hit"
@onready var ricochet := $Ricochet
@onready var human_pain := $"Human Pain"
@onready var human_death := $"Human Death"
@onready var flashbang_deploy := $"Flashbang Deploy"
@onready var handcuffing := $Handcuffing
@onready var handcuffed := $Handcuffed
@onready var grunt := $Grunt
@onready var evidence_pickup := $"Evidence Pickup"
@onready var drop_the_weapon := $"Drop The Weapon"
@onready var hands_in_the_air := $"Hands In The Air"
@onready var show_me_your_hands := $"Show Me Your Hands"
@onready var dont_shoot_im_unarmed := $"Dont Shoot Im Unarmed"
@onready var im_just_civilian_i_swear := $"Im Just Civilian I Swear"
@onready var i_didnt_do_anything := $"I Didnt Do Anything"
@onready var i_just_wanna_go_home := $"I Just Wanna Go Home"
@onready var alright_dont_shoot_i_give_up := $"Alright Dont Shoot I Give Up"
@onready var chill_man_im_done := $"Chill Man Im Done"
@onready var i_dont_want_any_trouble := $"I Dont Want Any Trouble"
@onready var kk_you_got_me := $"KK You Got Me"
@onready var k_im_dropping_the_weapon := $"K Im Dropping The Weapon"
@onready var walk := $Walk
@onready var metal_hit = $"Metal Hit"

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
	sfx_dict["door_hit"] = door_hit
	sfx_dict["ricochet"] = ricochet
	sfx_dict["human_pain"] = human_pain
	sfx_dict["human_death"] = human_death
	sfx_dict["flashbang_deploy"] = flashbang_deploy
	sfx_dict["handcuffing"] = handcuffing
	sfx_dict["handcuffed"] = handcuffed
	sfx_dict["grunt"] = grunt
	sfx_dict["evidence_pickup"] = evidence_pickup
	sfx_dict["drop_the_weapon"] = drop_the_weapon
	sfx_dict["hands_in_the_air"] = hands_in_the_air
	sfx_dict["show_me_your_hands"] = show_me_your_hands
	sfx_dict["dont_shoot_im_unarmed"] = dont_shoot_im_unarmed
	sfx_dict["im_just_civilian_i_swear"] = im_just_civilian_i_swear
	sfx_dict["i_didnt_do_anything"] = i_didnt_do_anything
	sfx_dict["i_just_wanna_go_home"] = i_just_wanna_go_home
	sfx_dict["alright_dont_shoot_i_give_up"] = alright_dont_shoot_i_give_up
	sfx_dict["chill_man_im_done"] = chill_man_im_done
	sfx_dict["i_dont_want_any_trouble"] = i_dont_want_any_trouble
	sfx_dict["kk_you_got_me"] = kk_you_got_me
	sfx_dict["k_im_dropping_the_weapon"] = k_im_dropping_the_weapon
	sfx_dict["smg_shoot"] = smg_shoot
	sfx_dict["smg_reload"] = smg_reload
	sfx_dict["smg_switch"] = smg_switch
	sfx_dict["walk"] = walk
	sfx_dict["metal_hit"] = metal_hit

func play_sound(sfx : String):
	if not GameState.sfx:
		return
	
	if sfx in sfx_dict:
		sfx_dict[sfx].play()

func play_random_sound(sfx_list: Array):
	if not GameState.sfx or sfx_list.size() == 0:
		return
	
	if sfx_list.size() == 0:
		return
	
	var available_sfx := []
	for sfx in sfx_list:
		if sfx in sfx_dict:
			available_sfx.append(sfx)
	
	if available_sfx.size() > 0:
		var index := randi() % available_sfx.size()
		play_sound(available_sfx[index])

func stop(sfx : String):
	if sfx in sfx_dict:
		sfx_dict[sfx].stop()
