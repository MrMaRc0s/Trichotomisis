extends Resource
class_name CharacterStats

class Ability:
	var min_modifier : float
	var max_modifier : float
	
	var ability_score : int = 25:
		set(value):
			ability_score = clamp(value, 0, 100)
			
	func _init(min: float, max: float) -> void:
		min_modifier = min
		max_modifier = max
		
	func percentile_lerp(min_bound: float, max_bound: float) -> float:
		return lerp(min_bound, max_bound, ability_score / 100.0)
		
	func get_modifier() -> float:
		return percentile_lerp(min_modifier, max_modifier)
		
	func increase_ability_score() -> void:
		ability_score += randi_range(2, 5)

var level := 1
var xp := 0:
	set(value):
		xp = value
		var boundary = cubic_level_up()
		
		while xp > boundary:
			xp -= boundary
			level_up()
			boundary = cubic_level_up()

var strenght = Ability.new(2.0, 12.0) #extra damage
var endurance = Ability.new(5.0, 25.0) #extra hp
var speed = Ability.new(3.0, 7.0) #meters/sec
var agility = Ability.new(0.05, 0.25) #crit and cooldown for dash

func get_base_strenght() -> float:
	return strenght.get_modifier()

func get_base_endurance() -> float:
	return endurance.get_modifier()

func get_base_speed() -> float:
	return speed.get_modifier()

func get_base_agility() -> float:
	return agility.get_modifier()
	
func level_up() -> void:
	level+=1
	strenght.increase_ability_score()
	endurance.increase_ability_score()
	speed.increase_ability_score()
	agility.increase_ability_score()
	print("level up")
	
func percentage_level_up() -> int:
	return int(50 * pow(1.2, level))
	
func cubic_level_up() -> int:
	return int(50 + pow(level, 3))
	
#level percentage_xp_req cubic_xp_req
# 1               60           51
# 2               72           58
# 3               86           77
# 4              103          114
# 5              124          175
# 6              149          266
# 7              179          393
# 8              214          562
# 9              257          779
# 10             309         1050
