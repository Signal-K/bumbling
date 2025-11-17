extends PanelContainer

signal slot_selected(slot_pos)

@onready var itemInfo = $ItemInfo

var seedDataResource: SeedData

func setup(value):
	seedDataResource = value
	seedDataResource.quantity_changed.connect(_on_quantity_changed)
	itemInfo.set_item_info(seedDataResource.get_texture(), seedDataResource.get_quantity())

func _on_texture_button_button_down():
	if seedDataResource.seed_left(): Global.emit_signal("seed_changed", seedDataResource)
	emit_signal("slot_selected", position)
	
func update_quantity() -> void:
	itemInfo.set_label(seedDataResource.get_quantity())
	
func _on_quantity_changed(new_quantity) -> void:
	itemInfo.set_label(new_quantity)
