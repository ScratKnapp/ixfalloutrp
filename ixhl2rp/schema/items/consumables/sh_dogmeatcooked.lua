ITEM.name = "Dog Steak"
ITEM.model = "models/mosi/fallout4/props/food/dogmeat.mdl"
ITEM.hunger = 20
ITEM.description = "A chunk of cooked dog meat."
ITEM.longdesc = "Meat taken from a canine, and cooked to remove bacteria, making it safe to eat."
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