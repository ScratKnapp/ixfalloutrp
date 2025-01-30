local PLUGIN = PLUGIN

ITEM.name = "FNUpgrade"
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


-- Slot Numbers Defined

-- Armor Vest: 1
-- Mask: 2
-- Helmet: 3
-- Misc: 4

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
	
    if (!target.isArmor) then
        client:NotifyLocalized("noArmorTarget")
        return false
    else


        -- Make sure armor is not currently on, to avoid fuckery of trying to modify protection values while someone's actively using it
        if target:GetData("equip", false) then
            client:NotifyLocalized("Unequip the armor before modifying it.")
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

        if item.armorHP then local oldmax = target:GetMaxHP() end 

        mods[item.slot] = {item.uniqueID, item.name}
        target:SetData("mod", mods)

        
        -- If armor was at max health before we attached an upgrade that boosted it, set HP to new maximum
        if item.armorHP then
            local oldmax = target:GetMaxHP()
            if target:GetHP() == oldmax then
                item:SetData("HP", target:GetMaxHP())
            end
        end
        
        
		client:EmitSound("cw/holster4.wav")
        return true
    end
	char:setRPGValues()
    client:NotifyLocalized("noArmor")
    return false
end

ITEM.functions.Upgrade = {
    name = "Upgrade",
    tip = "Puts this upgrade on the specified piece of armor.",
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
	
    if self.damResistances then
        str = str .. "\n\nPhysical Protection:  " .. self.damResistances["Physical"]
        str = str .. "\nEnergy Protection:  " .. self.damResistances["Energy"]
        str = str .. "\nRadiation Protection: " .. self.damResistances["Radiation"]
    end

    if self.armorHP then
        str = str .. "\n\n+" .. self.armorHP .. " Maximum Armor HP"
    end
    
	return str
end

function doesAcceptMod(armor, mod)

    if not armor.acceptedMods then return false end

    local whitelist = armor.acceptedMods
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

