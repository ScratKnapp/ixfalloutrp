ITEM.name = "Pinto Beans"
ITEM.model = "models/mosi/fnv/props/food/crops/pinto.mdl"
ITEM.hunger = 5
ITEM.description = "A pod of pinto beans."
ITEM.longdesc = "A simple pod of wild pinto beans. A small snack, but sometimes used in other recipes."
ITEM.quantity = 1
ITEM.price = 20
ITEM.width = 1
ITEM.height = 1
ITEM.sound = "fosounds/fix/npc_human_eating_food_chewy_02.mp3"
ITEM.flag = "5"
ITEM:Hook("use", function(item)
	item.player:EmitSound(item.sound or "items/battery_pickup.wav")
	ix.chat.Send(item.player, "iteminternal", "takes a bite of their "..item.name..".", false)
end)
ITEM.weight = 0.1


ITEM:DecideFunction()