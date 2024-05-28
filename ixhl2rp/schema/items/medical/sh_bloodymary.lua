ITEM.name = "Bloody Mary"
ITEM.description = "An injector device that resembles Psycho."
ITEM.longdesc = "A local Chem that has only recently started circulating in Mesquite. It seems to be a Psycho derivative, causing mind numbing fits of rage for users, but has the side effects of uncontrollable sudden and jerky movements along with minor respiratory bleeding, from which its name comes from. It’s often used as a cheaper alternative to the real stuff by low lifes."
ITEM.model = "models/mosi/fallout4/props/aid/pyscho.mdl"
ITEM.width = 2
ITEM.height = 1
ITEM.category = "Medical"
ITEM.price = "4000"
ITEM.flag = "1"
ITEM.quantity = 1
ITEM.sound = "fosounds/fix/npc_human_using_psycho_01.mp3"
ITEM.weight = 0.05
ITEM.duration = 5
ITEM.addictionChance = 15

ITEM.functions.use = {
	name = "Use",
	icon = "icon16/heart.png",
	OnRun = function(item)
		local quantity = item:GetData("quantity", item.quantity)
	
		ix.chat.Send(item.player, "iteminternal", "takes some "..item.name..".", false)

		item.player:NewVegasNotify("You feel uncomfortably energized. +25% Dmg, -3 Accuracy, -5 HP", "messageNeutral", 8)

		curplayer = item.player:GetCharacter()
		item.name = item.name
		duration = item.duration
	        item.player:AdjustHealth("hurt", 5)
                curplayer:AddSkillBoost("unarmed", -6)
                curplayer:AddSkillBoost("guns", -6)
                curplayer:AddSkillBoost("melee", -6)
                curplayer:AddSkillBoost("energyweapons", -6)
				curplayer:SetData("usingPsycho", true)
				curplayer:DrugHandler(item.player, "Psycho", item.addictionChance)


			timer.Create(item.name, item.duration, 1, function()  
		        curplayer:RemoveSkillBoost("bloodymary", "guns")
		        curplayer:RemoveSkillBoost("bloodymary", "unarmed")
		        curplayer:RemoveSkillBoost("bloodymary", "energyweapons")
		        curplayer:RemoveSkillBoost("bloodymary", "melee")
			curplayer:GetPlayer():NewVegasNotify(item.name .. " has worn off.", "messageNeutral", 8)
			curplayer:GetPlayer():EmitSound("cwfallout3/ui/medical/wear_off.wav" or "items/battery_pickup.wav")
			curplayer:SetData("usingPsycho", false)
			curplayer:ReapplyAddiction(curplayer:GetPlayer(), "Psycho")
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
		
		if (curplayer:GetData("usingBuffout")) then 
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