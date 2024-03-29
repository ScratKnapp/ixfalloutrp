ITEM.name = "Brahmin Milk"
ITEM.model = "models/mosi/fallout4/props/drink/milkbottle.mdl"
ITEM.thirst = 15
ITEM.hunger = 15
ITEM.description = "A bottle of Brahmin milk."
ITEM.longdesc = "Sourced from the wasteland's favorite bovine, Brahmin milk tastes much like the pre-war drink, complete with small globs of fat. Not only a fairly refreshing milk, but also with bits of protein in there. Tasty!"
ITEM.quantity = 1
ITEM.price = 20
ITEM.width = 1
ITEM.height = 2
ITEM.sound = "fosounds/fix/npc_humandrinking_soda_01.mp3"
ITEM.flag = "5"
ITEM:Hook("use", function(item)
	item.player:EmitSound(item.sound or "items/battery_pickup.wav")
	ix.chat.Send(item.player, "iteminternal", "takes a swig of their "..item.name..".", false)
end)
ITEM.weight = 0.1


ITEM:DecideFunction()