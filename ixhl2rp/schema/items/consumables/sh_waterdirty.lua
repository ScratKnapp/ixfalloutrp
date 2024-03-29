ITEM.name = "Dirty Water"
ITEM.model = "models/mosi/fallout4/props/drink/dirtywater.mdl"
ITEM.thirst = 15
ITEM.description = "A carton of unclean water."
ITEM.longdesc = "A carton full of water collected from a radioactive or otherwise unclean water source. Preferable to death by dehydration, but not very quenching as a result."
ITEM.quantity = 1
ITEM.price = 5
ITEM.width = 1
ITEM.height = 2
ITEM.sound = "fosounds/fix/npc_humandrinking_soda_01.mp3"
ITEM.flag = "5"
ITEM:Hook("use", function(item)
	item.player:addRadiation(15)
	item.player:EmitSound(item.sound or "items/battery_pickup.wav")
	ix.chat.Send(item.player, "iteminternal", "takes a swig of their "..item.name..".", false)
	item.player:GetCharacter():GetInventory():Add("emptybottle", 1)
end)
ITEM.weight = 0.1


ITEM:DecideFunction()