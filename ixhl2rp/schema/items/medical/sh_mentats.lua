ITEM.name = "Mentats"
ITEM.description = "A tin of mind aids."
ITEM.longdesc = "A metallic tin full of tablets, with a mixture scientifically proven to sharpen the senses and increase the mind's comprehension. Favored by intellectuals needing the boost to power through their next breakthrough.\n+2 INT\n+2 PER\n+1 CHR"
ITEM.model = "models/mosi/fnv/props/health/chems/mentats.mdl"
ITEM.width = 2
ITEM.height = 1
ITEM.category = "Medical"
ITEM.price = "4000"
ITEM.flag = "1"
ITEM.quantity = 1
ITEM.sound = "fosounds/fix/npc_human_eating_mentats.mp3"
ITEM.weight = 0.05
ITEM.duration = 350

ITEM.functions.use = {
	name = "Use",
	icon = "icon16/heart.png",
	OnRun = function(item)
		local quantity = item:GetData("quantity", item.quantity)
	
		ix.chat.Send(item.player, "iteminternal", "takes some "..item.name..".", false)

		curplayer = item.player:GetCharacter()
		itemname = item.name
		duration = item.duration
		curplayer:BuffStat("mentats", "perception", 2)
		curplayer:BuffStat("mentats", "intelligence", 2)
		curplayer:BuffStat("mentats", "charisma", 1)

		timer.Simple(duration, function() 
			curplayer:RemoveBuff("mentats", "perception")
			curplayer:RemoveBuff("mentats", "intelligence")
			curplayer:RemoveBuff("mentats", "charisma")
			curplayer:GetPlayer():NewVegasNotify(itemname .. " has worn off.", "messageNeutral", 8)
			curplayer:GetPlayer():EmitSound("cwfallout3/ui/medical/wear_off.wav" or "items/battery_pickup.wav")
		end)


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