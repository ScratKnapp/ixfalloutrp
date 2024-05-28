ITEM.name = "Rocket"
ITEM.description = "An inhalant device."
ITEM.longdesc = "An intense variant of jet with highs that can fly you to space and lows that crash you back down to Earth. It’s a potent Chem that any Jet addict would seek.\n+2 AP\n+10 Evasion"
ITEM.model = "models/fallout/clutter/chems/jet.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Medical"
ITEM.price = "4000"
ITEM.flag = "1"
ITEM.quantity = 1
ITEM.sound = "fosounds/fix/npc_human_using_jet.mp3"
ITEM.weight = 0.05
ITEM.duration = 5
ITEM.addictionChance = 30

ITEM.functions.use = {
	name = "Use",
	icon = "icon16/heart.png",
	OnRun = function(item)
		local quantity = item:GetData("quantity", item.quantity)
	
		ix.chat.Send(item.player, "iteminternal", "takes some "..item.name..".", false)

		item.player:NewVegasNotify("Your heart rate spikes and your pupils dialate. +2 AP, +10 Evasion", "messageNeutral", 8)

		local curplayer = item.player:GetCharacter()
		local itemname = item.name
		local duration = item.duration
        curplayer:SetCharapboost(curplayer:GetCharapboost() + 2)
		curplayer:AddSkillBoost("rocket", "evasion", 10)
		curplayer:SetData("usingJet", true)
		curplayer:DrugHandler(item.player, "Jet", item.addictionChance)


		timer.Create(item.name, item.duration, 1, function() 
		    curplayer:RemoveSkillBoost("rocket", "evasion")
			curplayer:SetCharapboost(curplayer:GetCharapboost() - 2)
			curplayer:GetPlayer():NewVegasNotify(item.name .. " has worn off.", "messageNeutral", 8)
			curplayer:GetPlayer():EmitSound("cwfallout3/ui/medical/wear_off.wav" or "items/battery_pickup.wav")
			curplayer:SetData("usingJet", false)
			curplayer:ReapplyAddiction(curplayer:GetPlayer(), "Jet")
		end)


		timer.Pause(item.name)
		local drugtable = curplayer:GetData("timertable") or {}
		table.insert(drugtable, item.name)
		curplayer:SetData("timertable", drugtable)

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