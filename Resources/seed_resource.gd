extends Resource

class_name SeedResource

@export var seedList: Array[SeedData]

func get_seed_data(value) -> SeedData:
	for child in seedList:
		if child.get_seed_name() == value:
			return child
	return null
	
func get_size() -> int:
	return seedList.size()
	
func get_seed_list() -> Array[SeedData]:
	return seedList
