ITEM.name = "Pip-Walker"
ITEM.description = "A portable holotape player."
ITEM.longdesc = "A fairly chunky device produced by Vault-Tec in partnership with General Atomics, it serves as a portable holotape player, though only for audio tapes as it has no processing or video display capability."
ITEM.price = 15000
ITEM.model = "models/gibs/shield_scanner_gib1.mdl"
ITEM.width = 2
ITEM.height = 1
ITEM.weight = 1.12

ITEM.functions.play = {
    name = "Play Tape",
    tip = "useTip",
    icon = "icon16/control_play.png",
    OnCanRun = function(item)				
		return (!IsValid(item.entity) and item:GetData("CurTape", nil) != nil)
	end,
    OnRun = function(item)
    	local entity = item.player
		local curtape = item:GetData("CurTape", nil)
		local tape = ix.item.list[curtape]

		if entity.sound then
			entity.sound:Stop()
		end

		tape.options = {}
		for k, v in pairs(tape.cassette_options) do
			tape.options[#tape.options + 1] = k
		end

		entity.CurCassette = data
		entity.sound = CreateSound(entity, table.Random(tape.options))
		entity.sound:Play()
		entity.sound:SetSoundLevel(0)
		entity:EmitSound("stalkersound/inv_properties.mp3", 40)
		
		return false
	end,
}

ITEM.functions.insert = {
    name = "Insert Tape",
    tip = "useTip",
    icon = "icon16/arrow_up.png",
    isMulti = true,
    OnCanRun = function(item)				
		return (!IsValid(item.entity) and item:GetData("CurTape", nil) == nil)
	end,
	multiOptions = function(item, client)
		local targets = {}
        local char = client:GetCharacter()
		
        if (char) then
			local inv = char:GetInventory()

			if (inv) then
				local items = inv:GetItems()

				for k, v in pairs(items) do
					if v.isCassette then
						table.insert(targets, {
							name = v.name,
							data = {v:GetID()},
						})
					else
						continue
					end
				end
			end
		end

        return targets
	end,
    OnRun = function(item, data)
		if !data[1] then
			return false
		end

		local target = data[1]
		local items = item.player:GetCharacter():GetInventory():GetItems()

		for k, invItem in pairs(items) do
			if (data[1]) then
				if (invItem:GetID() == data[1]) then
					target = invItem

					break
				end
			else
				client:Notify("No item selected.")
				return false
			end
		end

		item:SetData("CurTape", target.uniqueID)
		target:Remove()
		item.player:EmitSound("stalkersound/inv_slot.mp3", 40)
		
		return false
	end,
}

ITEM.functions.remove = {
    name = "Remove Tape",
    tip = "useTip",
    icon = "icon16/arrow_down.png",
    OnCanRun = function(item)				
		return (!IsValid(item.entity) and item:GetData("CurTape", nil) != nil)
	end,
    OnRun = function(item, data)
		local inv = item.player:GetCharacter():GetInventory()
		local curtape = item:GetData("CurTape", nil)
		item:StopSound()

		inv:Add(curtape)
		item:SetData("CurTape", nil)
		item.player:EmitSound("stalkersound/inv_slot.mp3", 40)
		
		return false
	end,
}

ITEM.functions.stopsound = {
    name = "Stop Playing",
    tip = "useTip",
    icon = "icon16/control_stop.png",
    OnCanRun = function(item)
		return (!IsValid(item.entity) and item:GetData("CurTape", nil) != nil)
	end,
    OnRun = function(item, data)
		item:StopSound()
		item.player:EmitSound("stalkersound/inv_properties.mp3", 40)
		
		return false
	end,
}

ITEM:Hook("drop", function(item)
	item:StopSound()
end)

function ITEM:StopSound()
	local entity = self.player
	if entity.sound then
		entity.sound:Stop()
	end
end


function ITEM:GetDescription()
	local quant = self:GetData("quantity", 1)
	local str = self.description
	if self.longdesc then
		str = str.."\n"..(self.longdesc or "")
	end

	local customData = self:GetData("custom", {})
	if(customData.desc) then
		str = customData.desc
	end

	if (self.entity) then
		return (self.description)
	else
        return (str)
	end
end

function ITEM:GetName()
	local name = self.name
	
	local customData = self:GetData("custom", {})
	if(customData.name) then
		name = customData.name
	end
	
	return name
end

ITEM.functions.Custom = {
	name = "Customize",
	tip = "Customize this item",
	icon = "icon16/wrench.png",
	OnRun = function(item)		
		ix.plugin.list["customization"]:startCustom(item.player, item)
		
		return false
	end,
	
	OnCanRun = function(item)
		local client = item.player
		return client:GetCharacter():HasFlags("N") and !IsValid(item.entity)
	end
}

ITEM.functions.Inspect = {
	name = "Inspect",
	tip = "Inspect this item",
	icon = "icon16/picture.png",
	OnClick = function(item, test)
		local customData = item:GetData("custom", {})

		local frame = vgui.Create("DFrame")
		frame:SetSize(540, 680)
		frame:SetTitle(item.name)
		frame:MakePopup()
		frame:Center()

		frame.html = frame:Add("DHTML")
		frame.html:Dock(FILL)
		
		local imageCode = [[<img src = "]]..customData.img..[["/>]]
		
		frame.html:SetHTML([[<html><body style="background-color: #000000; color: #282B2D; font-family: 'Book Antiqua', Palatino, 'Palatino Linotype', 'Palatino LT STD', Georgia, serif; font-size 16px; text-align: justify;">]]..imageCode..[[</body></html>]])
	end,
	OnRun = function(item)
		return false
	end,
	OnCanRun = function(item)
		local customData = item:GetData("custom", {})
	
		if(!customData.img) then
			return false
		end
		
		if(item.entity) then
			return false
		end
		
		return true
	end
}

ITEM.functions.Clone = {
	name = "Clone",
	tip = "Clone this item",
	icon = "icon16/wrench.png",
	OnRun = function(item)
		local client = item.player	
	
		client:requestQuery("Are you sure you want to clone this item?", "Clone", function(text)
			if text then
				local inventory = client:GetCharacter():GetInventory()
				
				if(!inventory:Add(item.uniqueID, 1, item.data)) then
					client:Notify("Inventory is full")
				end
			end
		end)
		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		return client:GetCharacter():HasFlags("N") and !IsValid(item.entity)
	end
}