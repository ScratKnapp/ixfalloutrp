ITEM.name = "Buffout"
ITEM.description = "A bottle of steroids."
ITEM.longdesc = "A pre war steroid often used by athletes to enhance their physical performance. Abuse tends to result in heart problems."
ITEM.model = "models/mosi/fnv/props/health/chems/buffout.mdl"
ITEM.width = 1
ITEM.height = 2
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

		item.player:NewVegasNotify("You feel ready to take on the world! +3 END, +2 STR", "messageNeutral", 8)

		curplayer = item.player:GetCharacter()
		itemname = item.name
		duration = item.duration
		curplayer:AddBoost("buffout", "strength", 2)
		curplayer:AddBoost("buffout", "endurance", 2)


		timer.Simple(duration, function() 
			curplayer:RemoveBoost("buffout", "strength")
			curplayer:RemoveBoost("buffout", "endurance")
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