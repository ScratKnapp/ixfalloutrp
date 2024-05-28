ITEM.name = "Wasteland Tequila"
ITEM.description = "A bottle of liquor."
ITEM.longdesc = "A whiskey bottle filled with a homemade remedy for any poisons that you might encounter on the road, from a Nightstalker’s bite to a Cazador’s sting, this stuff will make you forget you were even poisoned. Drink enough of it and it’ll even make you forget you were doing.\n+2 STR\n+1 CHR\n+-2 INT\nCures Poison"
ITEM.model = "models/fnv/clutter/liquorbottles/whiskeybottle01.mdl"
ITEM.width = 1
ITEM.height = 2
ITEM.category = "Medical"
ITEM.price = "4000"
ITEM.flag = "1"
ITEM.quantity = 1
ITEM.sound = "fosounds/fix/npc_humandrinking_soda_01.mp3"
ITEM.weight = 0.05
ITEM.duration = 6
ITEM.addictionChance = 10

ITEM.functions.use = {
	name = "Use",
	icon = "icon16/heart.png",
	OnRun = function(item)
		local quantity = item:GetData("quantity", item.quantity)
	
		ix.chat.Send(item.player, "iteminternal", "drinks some "..item.name..".", false)
                item.player:GetCharacter():GetInventory():Add("emptybottle", 1)

		item.player:NewVegasNotify("You feel bubbly and bold. +2 Strength, +1 Charisma, -2 Intelligence. You are cured of all Poisons!", "messageNeutral", 8)

		curplayer = item.player:GetCharacter()
		item.name = item.name
		duration = item.duration

		curplayer:BuffStat("wastelandtequila", "strength", 2)
		curplayer:BuffStat("wastelandtequila", "charisma", 1)
		curplayer:BuffStat("wastelandtequila", "intelligence", -2)
		curplayer:DrugHandler(item.player, "Alcohol", item.addictionChance)


		timer.Create(item.name, item.duration, 1, function() 
		curplayer:RemoveBuff("wastelandtequila", "strength")
		curplayer:RemoveBuff("wastelandtequila", "charisma")
		curplayer:RemoveBuff("wastelandtequila", "intelligence")
		curplayer:GetPlayer():NewVegasNotify(item.name .. " has worn off.", "messageNeutral", 8)
		curplayer:GetPlayer():EmitSound("cwfallout3/ui/medical/wear_off.wav" or "items/battery_pickup.wav")
		curplayer:ReapplyAddiction(curplayer:GetPlayer(), "Alcohol")
		end)

			timer.Pause(item.name)
			local drugtable = curplayer:GetData("timertable") or {}
			table.insert(drugtable, item.name)
			curplayer:SetData("timertable", drugtable)
			
			quantity = quantity - 1
			if (quantity >= 1) then
				item:SetData("quantity", quantity)
				return false
			end

			return true
		end,

	OnCanRun = function(item)
		return (!IsValid(item.entity))
	end
}


function ITEM:GetDescription()
	if (!self.entity or !IsValid(self.entity)) then
		local quant = self:GetData("quantity", self.quantity)
		local str = self.longdesc.."\n \nThere's only "..quant.." uses left."

		return str
	else
		return self.desc
	end
end

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)

		draw.SimpleText(item:GetData("quantity", item.quantity).."/"..item.quantity, "DermaDefault", 3, h - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, color_black)
	end
end