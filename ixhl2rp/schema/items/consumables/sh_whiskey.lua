ITEM.name = "Whiskey"
ITEM.model = "models/fnv/clutter/liquorbottles/whiskeybottle01.mdl"
ITEM.thirst = 18
ITEM.description = "A bottle of amber Whiskey."
ITEM.longdesc = "A square-shaped bottle of Olde Royale Premium whiskey. Perfectly sized to fit in a jacket pocket to make the day just slightly more bearable in moments."
ITEM.quantity = 1
ITEM.price = 5
ITEM.width = 2
ITEM.height = 1
ITEM.sound = "fosounds/fix/npc_humandrinking_soda_01.mp3"
ITEM.flag = "5"
ITEM:Hook("use", function(item)
	item.player:EmitSound(item.sound or "items/battery_pickup.wav")
	item.player:addRadiation(10)
	ix.chat.Send(item.player, "iteminternal", "takes a swig of their "..item.name..".", false)
end)
ITEM.weight = 0.1


ITEM:DecideFunction()