extends CanvasLayer

func setup_inventory() -> void:
	$Inventory.initialize()

func inventory_is_slot_empty(seed) -> void:
	$Inventory.is_slot_empty(seed)
