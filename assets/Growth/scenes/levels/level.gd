extends Node2D

func _on_player_tool_use(tool: Enums.Tool, pos: Vector2) -> void:
	var grid_coord: Vector2i = Vector2i(int(pos.x / Data.TILE_SIZE), int(pos.y / Data.TILE_SIZE))
	
	match tool:
		Enums.Tool.HOE:
			%Layers/SoilLayer.set_cells_terrain_connect([grid_coord], 0, 0)
