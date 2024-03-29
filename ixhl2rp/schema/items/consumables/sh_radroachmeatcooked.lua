ITEM.name = "Radroach Steak"
ITEM.model = "models/fnv/clutter/food/roachmeat.mdl"
ITEM.hunger = 15
ITEM.description = "A cut of Radroach Steak."
ITEM.longdesc = "Meat taken from a radroach, fried up. Gritty taste and not terribly satisfying, but often plentiful due to the damned pests being everywhere."
ITEM.quantity = 1
ITEM.price = 20
ITEM.width = 2
ITEM.height = 1
ITEM.sound = "fosounds/fix/npc_human_eating_food_chewy_02.mp3"
ITEM.flag = "5"
ITEM:Hook("use", function(item)
	item.player:addRadiation(5)
	item.player:EmitSound(item.sound or "items/battery_pickup.wav")
	ix.chat.Send(item.player, "iteminternal", "takes a bite of their "..item.name..".", false)
end)
ITEM.weight = 0.1


ITEM:DecideFunction()