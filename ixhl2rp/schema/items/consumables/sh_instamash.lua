ITEM.name = "Instamash"
ITEM.model = "models/fnv/clutter/junk/instamash01.mdl"
ITEM.hunger = 10
ITEM.description = "A box of mash potato mix."
ITEM.longdesc = "Just add water and you've got surprisingly tasty mashed taters."
ITEM.quantity = 1
ITEM.price = 20
ITEM.width = 1
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