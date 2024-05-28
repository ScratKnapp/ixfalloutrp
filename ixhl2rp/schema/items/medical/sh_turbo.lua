ITEM.name = "Turbo"
ITEM.description = "An amphetamine in an inhaler."
ITEM.longdesc = "A Jet inhaler with some extra chemicals to huff. The feeling is intense, much more so than Jet alone, but barely lasts any longer.\n+1 AP\n+5 Evasion"
ITEM.model = "models/mosi/fnv/props/health/chems/turbo.mdl"
ITEM.width = 1
ITEM.height = 2
ITEM.category = "Medical"
ITEM.price = "4000"
ITEM.flag = "1"
ITEM.quantity = 1
ITEM.sound = "fosounds/fix/npc_human_using_jet.mp3"
ITEM.weight = 0.05
ITEM.duration = 5
ITEM.addictionChance = 20

ITEM.functions.use = {
	name = "Use",
	icon = "icon16/heart.png",
	OnRun = function(item)
		local quantity = item:GetData("quantity", item.quantity)
	
		ix.chat.Send(item.player, "iteminternal", "huffs some "..item.name..".", false)

		curplayer = item.player:GetCharacter()
		item.name = item.name
		duration = item.duration

		curplayer:SetCharapboost(curplayer:GetCharapboost() + 1)
		curplayer:AddSkillBoost("turbo", "evasion", 5)
		curplayer:SetData("usingJet", true)
		curplayer:DrugHandler(item.player, "Jet", item.addictionChance)

		timer.Create(item.name, item.duration, 1, function() 
			curplayer:SetCharapboost(curplayer:GetCharapboost() - 1)
			curplayer:GetPlayer():NewVegasNotify(item.name .. " has worn off.", "messageNeutral", 8)
			curplayer:GetPlayer():EmitSound("cwfallout3/ui/medical/wear_off.wav" or "items/battery_pickup.wav")
			curplayer:RemoveSkillBoost("turbo", "evasion")
			curplayer:SetData("usingJet", false)
			curplayer:ReapplyAddiction(curplayer:GetPlayer(), "Jet")
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
		
		if (curplayer:GetData("usingJet")) then 
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