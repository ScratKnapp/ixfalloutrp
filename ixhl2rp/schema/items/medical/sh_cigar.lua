ITEM.name = "Cigar"
ITEM.description = "A dignifed cancer stick."
ITEM.longdesc = "A high quality hand-rolled cigar either made locally or imported from Cuba before the war. Its as much a display piece as a smokable, but if used it tends to last far longer than a cigarette and somehow makes you more ponderous. Warning: Known to cause cancer, but you'll look like a total badass.\n+1 CHR\n+1 END\n+1 INT"
ITEM.model = "models/mosi/fallout4/props/junk/cigar.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Medical"
ITEM.price = "4000"
ITEM.flag = "1"
ITEM.quantity = 1
ITEM.sound = "fosounds/fix/npc_human_using_jet.mp3"
ITEM.weight = 0.05
ITEM.duration = 8
ITEM.addictionChance = 20

ITEM.functions.use = {
	name = "Smoke",
	icon = "icon16/heart.png",
	OnRun = function(item)
		local quantity = item:GetData("quantity", item.quantity)
	
		ix.chat.Send(item.player, "iteminternal", "smokes a "..item.name..".", false)

		curplayer = item.player:GetCharacter()
		item.name = item.name
		duration = item.duration
		curplayer:BuffStat("cigarette", "endurance", 1)
		curplayer:BuffStat("cigarette", "charisma", 1)
		curplayer:BuffStat("cigarette", "intelligence", 1)
		curplayer:SetData("usingCigarette", true)
		curplayer:DrugHandler(item.player, "Nicotine", item.addictionChance)

		timer.Create(item.name, item.duration, 1, function()  
			curplayer:RemoveBuff("cigarette", "charisma")
			curplayer:RemoveBuff("cigarette", "endurance")
			curplayer:RemoveBuff("cigarette", "intelligence")
			curplayer:GetPlayer():NewVegasNotify(item.name .. " has worn off.", "messageNeutral", 8)
			curplayer:GetPlayer():EmitSound("cwfallout3/ui/medical/wear_off.wav" or "items/battery_pickup.wav")
			curplayer:SetData("usingCigarette", false)
			curplayer:ReapplyAddiction(curplayer:GetPlayer(), "Nicotine")
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
		
		if (curplayer:GetData("usingCigarette")) then 
			return false
		else 
			return (!IsValid(item.entity))
		end 
	end
}


function ITEM:GetDescription()
	if (!self.entity or !IsValid(self.entity)) then
		return  self.longdesc
	else
		return self.description
	end
end
