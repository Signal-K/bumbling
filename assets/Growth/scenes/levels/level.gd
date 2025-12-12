extends Node2D

var plant_scene = preload("res://Scenes/Objects/plant.tscn")

func _on_player_tool_use(tool: Enums.Tool, pos: Vector2) -> void:
	# Convert world position to grid coordinates for each layer
	var grass_local_pos = pos - $Layers/GrassLayer.position
	var grass_grid_coord: Vector2i = Vector2i(int(grass_local_pos.x / 16), int(grass_local_pos.y / 16))
	var soil_grid_coord: Vector2i = Vector2i(int(pos.x / 16), int(pos.y / 16))
	var has_soil = soil_grid_coord in $Layers/SoilLayer.get_used_cells()
	
	match tool:
		Enums.Tool.HOE:
			# Can only hoe if there's grass AND no existing soil
			if $Layers/GrassLayer.get_cell_source_id(grass_grid_coord) >= 0 and not has_soil:
				# Place soil on top - grass layer is BELOW soil layer in the hierarchy so soil will show on top
				$Layers/SoilLayer.set_cell(soil_grid_coord, 0, Vector2i(1, 4), 0)
			
		Enums.Tool.WATER:
			if has_soil:
				var water_grid_coord: Vector2i = Vector2i(int(pos.x / 16), int(pos.y / 16))
				$Layers/SoilWaterLayer.set_cell(water_grid_coord, 0, Vector2i(randi_range(0, 2), 0))
		
		Enums.Tool.FISH:
			var water_grid_coord: Vector2i = Vector2i(int(pos.x / 16), int(pos.y / 16))
			if water_grid_coord in $Layers/WaterLayer.get_used_cells():
				pass  # Add fishing logic here
				
		Enums.Tool.SEED:
			if has_soil:
				var plant = plant_scene.instantiate()
				plant.setup(soil_grid_coord, $Objects)
