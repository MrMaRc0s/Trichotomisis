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

var level := 1
var xp := 0

var strenght = Ability.new(2.0, 12.0) #extra damage
var speed = Ability.new(3.0, 7.0) #meters/sec
var endurance = Ability.new(5.0, 25.0) #extra hp
var agility = Ability.new(0.05, 0.25) #crit and cooldown for dash

func get_base_strenght() -> float:
	return strenght.get_modifier()

func get_base_endurance() -> float:
	return endurance.get_modifier()

func get_base_speed() -> float:
	return speed.get_modifier()

func get_base_agility() -> float:
	return agility.get_modifier()
