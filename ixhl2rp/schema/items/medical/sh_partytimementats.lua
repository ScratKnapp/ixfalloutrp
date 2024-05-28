ITEM.name = "Mentats"
ITEM.description = "A homemade flavor of Mentat."
ITEM.longdesc = "A metallic tin full of Mentats, that have been mixed with an improved recipe that is known to improve one's sense of empathy, making them more receptive to the feelings of those around them. Great for parties or a confidence booster, but lasts drastically less than the normal flavor.\n+2 INT\n+2 PER\n+4 CHR"
ITEM.model = "models/mosi/fnv/props/health/chems/mentats.mdl"
ITEM.width = 2
ITEM.height = 1
ITEM.category = "Medical"
ITEM.price = "4000"
ITEM.flag = "1"
ITEM.quantity = 1
ITEM.sound = "fosounds/fix/npc_human_eating_mentats.mp3"
ITEM.weight = 0.05
ITEM.duration = 7
ITEM.addictionChance = 15

ITEM.functions.use = {
	name = "Use",
	icon = "icon16/heart.png",
	OnRun = function(item)
		local quantity = item:GetData("quantity", item.quantity)
	
		ix.chat.Send(item.player, "iteminternal", "takes some "..item.name..".", false)

		item.player:NewVegasNotify("You practically feel your mind expanding, and your senses in tune with other's. +2 INT, +2 PER, +4 CHR", "messageNeutral", 8)

		curplayer = item.player:GetCharacter()
		item.name = item.name
		duration = item.duration
		curplayer:BuffStat("partytimementats", "perception", 2)
		curplayer:BuffStat("partytimementats", "intelligence", 2)
		curplayer:BuffStat("partytimementats", "charisma", 4)
		curplayer:SetData("usingMentats", true)
		curplayer:DrugHandler(item.player, "Mentats", item.addictionChance)

		timer.Create(item.name, item.duration, 1, function()
			curplayer:RemoveBuff("partytimementats", "perception")
			curplayer:RemoveBuff("partytimementats", "intelligence")
			curplayer:RemoveBuff("partytimementats", "charisma")
			curplayer:GetPlayer():NewVegasNotify(item.name .. " has worn off.", "messageNeutral", 8)
			curplayer:GetPlayer():EmitSound("cwfallout3/ui/medical/wear_off.wav" or "items/battery_pickup.wav")
			curplayer:SetData("usingMentats", false)
			curplayer:ReapplyAddiction(curplayer:GetPlayer(), "Mentats")
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
		curplayer = item.player:GetCharacter()
		
		if (curplayer:GetData("usingMentats")) then 
			return false
		else 
			return (!IsValid(item.entity))
		end
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