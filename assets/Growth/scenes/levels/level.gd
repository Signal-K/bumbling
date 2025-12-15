extends Node2D

var plant_scene = preload("res://Scenes/Objects/plant.tscn")
var used_cells: Array[Vector2i]
@onready var player = $Objects/Player

func _on_player_tool_use(tool: Enums.Tool, pos: Vector2) -> void:
	# Convert world position to grid coordinates for each layer
	# Layers with offset (GrassLayer, SoilLayer, SoilWaterLayer) at position (186, 342)
	var layer_offset = $Layers/GrassLayer.position
	var grid_coord: Vector2i = Vector2i(int(pos.x / Data.TILE_SIZE), int(pos.y / Data.TILE_SIZE))
	grid_coord.x += -1 if pos.x < 0 else 0
	grid_coord.y += -1 if pos.x < 0 else 0
	
	# WaterLayer has no position offset
	var water_grid_coord: Vector2i = Vector2i(
		floor(pos.x / Data.TILE_SIZE),
		floor(pos.y / Data.TILE_SIZE)
	)
	
	var has_soil = grid_coord in $Layers/SoilLayer.get_used_cells()
	
	match tool:
		Enums.Tool.HOE:
			var grass_cells = $Layers/GrassLayer.get_used_cells()
			var has_grass = grid_coord in grass_cells
			
			if has_grass:
				# Remove grass and place soil at the same coordinate
				$Layers/GrassLayer.erase_cell(grid_coord)
				# Also erase water that might be below
				$Layers/WaterLayer.erase_cell(water_grid_coord)
				$Layers/SoilLayer.set_cell(grid_coord, 0, Vector2i(1, 1))
			
		Enums.Tool.WATER:
			if has_soil:
				# Remove any layers that might be underneath
				$Layers/GrassLayer.erase_cell(grid_coord)
				$Layers/WaterLayer.erase_cell(water_grid_coord)
				# Place watered soil tile on top of the existing soil
				$Layers/SoilWaterLayer.set_cell(grid_coord, 0, Vector2i(randi_range(0, 2), 0))
		
		Enums.Tool.FISH: 
			if not grid_coord in  $Layers/GrassLayer.get_used_cells():
				pass 
				
		Enums.Tool.SEED:
			if has_soil and grid_coord not in used_cells:
				var plant = plant_scene.instantiate()
				# Calculate the center of the tile
				var tile_center = Vector2(grid_coord) * Data.TILE_SIZE + Vector2(Data.TILE_SIZE / 2, Data.TILE_SIZE / 2) + layer_offset
				plant.position = tile_center
				$Objects.add_child(plant)
				plant.coord = grid_coord
				used_cells.append(grid_coord)
		
		Enums.Tool.AXE, Enums.Tool.SWORD:
			for object in get_tree().get_nodes_in_group("Objects"):
				if object.position.distance_to(pos) < 20:
					object.hit(tool)
