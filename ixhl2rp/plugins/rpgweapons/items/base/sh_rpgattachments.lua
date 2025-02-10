local PLUGIN = PLUGIN

ITEM.name = "RPG Weapons"
ITEM.description = "An attachment. It goes on a weapon."
ITEM.category = "Attachments"
ITEM.model = "models/Items/BoxSRounds.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.price = 1
ITEM.slot = 1
ITEM.quantity = 1
ITEM.flag = "2"
ITEM.isAttachment = true
ITEM.isWeaponUpg = true 


-- Slot Numbers Defined

-- 1: Receiver, Capacitor, or Unique
-- 2: Barrel
-- 3: Magazine
-- 4: Grip
-- 5: Stock
-- 6: Sight
-- 7: Muzzle

local function attachment(item, data, combine)
    local client = item.player
    local char = client:GetChar()
    local inv = char:GetInv()
    local items = inv:GetItems()
    local target

    for k, invItem in pairs(items) do
        if data then
            if (invItem:GetID() == data[1]) then
                target = invItem
                break
            end
        end
    end
	
    if (!target.rpgWeapon) then
        client:NotifyLocalized("No Weapon Selected")
        return false
    else

        if target:GetData("equip", false) then
            client:NotifyLocalized("Unequip the weapon before modifying it.")
            return false
        end 

        if not doesAcceptMod(target, item) then
            client:Notify(target:GetName() .. " cannot take a " .. item:GetName() .. "upgrade.")
            return false
        end
             
        local mods = target:GetData("mod", {})
        -- Is the Armor Slot Filled?
        if (mods[item.slot]) then
            client:NotifyLocalized("Slot Filled")
            return false
        end
        
        curPrice = target:GetData("RealPrice")
	    if !curPrice then
		    curPrice = target.price
		end
		
        target:SetData("RealPrice", (curPrice + item.price))


        mods[item.slot] = {item.uniqueID, item.name}
        target:SetData("mod", mods)

        
        
		client:EmitSound("cw/holster4.wav")
        return true
    end


    client:NotifyLocalized("No Weapon Selected")
    return false
end

ITEM.functions.Upgrade = {
    name = "Upgrade",
    tip = "Puts this upgrade on the specified weapon.",
    icon = "icon16/wrench.png",
    
    
    OnCanRun = function(item)
        return (!IsValid(item.entity))
    end,
	
    OnRun = function(item, data)
		return attachment(item, data, false)
	end,
    
    isMulti = true,
    
    multiOptions = function(item, client)
        --local client = item.player
        local targets = {}
        local char = client:GetChar()
        if (char) then
            local inv = char:GetInv()
            if (inv) then
                local items = inv:GetItems()

                for k, v in pairs(items) do

                    if not v.noUpgrade then 

                        if doesAcceptMod(v, item) then
                            table.insert(targets, {
                                name = L(v.name),
                                data = {v:GetID()},
                            })
                        end 


                    end 
				end
			end
		end
    return targets
	end,
}

ITEM.functions.Sell = {
	name = "Sell",
	icon = "icon16/stalker/sell.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = (item.price/2)
		sellprice = math.Round(sellprice)
		client:Notify( "Sold for "..(sellprice).." rubles." )
		client:GetCharacter():GiveMoney(sellprice)
		
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1")
	end
}

ITEM.functions.Value = {
	name = "Value",
	icon = "icon16/help.png",
	sound = "physics/metal/chain_impact_soft2.wav",
	OnRun = function(item)
		local client = item.player
		local sellprice = (item.price/2)
		sellprice = math.Round(sellprice)
		client:Notify( "Item is sellable for "..(sellprice).." rubles." )
		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity) and item:GetOwner():GetCharacter():HasFlags("1")
	end
}

function ITEM:GetDescription()
	local str = self.description 

	if self.stats then
		str = str .. "\n"
		for k, v in pairs(self.stats) do


			if v > 0 then 
                if k == "Range" then v = "Increases Range by " .. v .. " step" end 
				str = str .. "\n" .. k .. ": " .. v
			end 
		end
	end 

    if self.qualities then 
        str = str .. "\n\nAdds Qualities:"
        for k, v in pairs(self.qualities) do
			str = str .. "\n" .. v
		end
    end 

    if self.effects then 
        str = str .. "\n\nAdds Effects:"
        for k, v in pairs(self.effects) do
			str = str .. "\n" .. v
		end
    end 
    
    if self.removequalities then 
        str = str .. "\n\nRemoves Qualities:"
        for k, v in pairs(self.removequalities) do
			str = str .. "\n" .. v
		end
    end 

    if self.removeeffects then 
        str = str .. "\n\nRemoves Effects:"
        for k, v in pairs(self.removeeffects) do
			str = str .. "\n" .. v
		end
    end 


	return str
end

function doesAcceptMod(weapon, mod)

    if not weapon.acceptedMods then return false end

    local whitelist = weapon.acceptedMods
    local modid = mod.uniqueID

    local isWhitelisted = false

    for k, v in pairs(whitelist) do
      if modid == v then
        isWhitelisted = true
        break
      end
    end

  return isWhitelisted




end 

