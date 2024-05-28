ITEM.name = "Quick Fixer"
ITEM.description = "A tin of pills for temporarily treating addiction."
ITEM.longdesc = "A set of tablets to take that immediately suppress any mentally or physical dependencies for a fair period of time. However, the effect is only temporary - you'll need to take more in time, or the dependencies will return.."
ITEM.model = "models/mosi/fnv/props/health/chems/fixer.mdl"
ITEM.width = 2
ITEM.height = 1
ITEM.category = "Medical"
ITEM.price = "4000"
ITEM.flag = "1"
ITEM.quantity = 1
ITEM.sound = "fosounds/fix/npc_human_eating_mentats.mp3"
ITEM.weight = 0.05
ITEM.duration = 10

ITEM.functions.use = {
	name = "Use",
	icon = "icon16/heart.png",
	OnRun = function(item)
		local quantity = item:GetData("quantity", item.quantity)
	
		ix.chat.Send(item.player, "iteminternal", "takes some  "..item.name..".", false)

		

		
		curplayer = item.player:GetCharacter()
		item.name = item.name
		duration = item.duration

		

		curplayer:PurgeAddictions(item.player, false)
		curplayer:SetData("usingFixer", true)
	
		timer.Create(item.name, item.duration, 1, function() 
			curplayer:GetPlayer():NewVegasNotify(item.name .. " has worn off.", "messageNeutral", 8)
			curplayer:GetPlayer():EmitSound("cwfallout3/ui/medical/wear_off.wav" or "items/battery_pickup.wav")
			curplayer:SetData("usingFixer", false)
			curplayer:ReapplyAllAddictions(curplayer:GetPlayer())
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
		
		if (curplayer:GetData("usingFixer")) then 
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