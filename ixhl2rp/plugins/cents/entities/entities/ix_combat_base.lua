local PLUGIN = PLUGIN

ix.util.Include("sh_animations.lua")
ix.util.Include("sh_getters.lua")
ix.util.Include("sh_setters.lua")


ENT.Type = "nextbot"
ENT.Base = "base_nextbot"
ENT.PrintName = "Combat Entity Base"
ENT.Category = "Helix"
ENT.Spawnable = false
ENT.AdminOnly = true

ENT.combatEntity = true

ENT.model = "models/Humans/Group01/male_02.mdl"


ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
    self:BasicSetup()

    self:CustomInitialize()
end

function ENT:RunBehavior()
    while (true) do
        coroutine.wait(60)

        coroutine.yield()
    end
end

function ENT:BasicSetup()
    self:SetRenderMode(RENDERMODE_TRANSALPHA)

    if (SERVER) then
        self.inventory = self.inventory or {}

        local model = self.model

        if self.models then
            model = table.Random(self.models)
        end

        self:SetModel(model)

        if self.skin then
            self:SetBodygroups("2")
        end 

        self:SetUseType(SIMPLE_USE)
    end

    self:PhysicsSetup()

    timer.Simple(0.25, function()
        if (IsValid(self)) then
            self:SetAnim()
        end
    end)
end

function ENT:CustomInitialize()
end

function ENT:PhysicsSetup()
    if (SERVER) then
        self:DrawShadow(true)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_BBOX)

        local physObj = self:GetPhysicsObject()

        if IsValid(physObj) then
            physObj:EnableMotion(false)
            physObj:EnableGravity(false)
            physObj:EnableCollisions(false)
        end

        if self.loco then
            self.loco:SetAcceleration(900)
            self.loco:SetDeceleration(100000)
            self.loco:SetGravity(0)

            self:SetGravity(0)
        end
    end

    self:SetCollisionBounds(Vector(-20, -20, 0), Vector(20, 20, 100))
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

function ENT:Think()
	--self:CustomThink()

	if (CLIENT) then
		--self:SetNextClientThink( CurTime() + 0.025 )
	end

	if (SERVER) then

		--self:NextThink( CurTime() + 0.025 )


		if (self.loco) then

			if (self:IsPlayerHolding()) then

				--if held with physgun while moving, will teleport to end when hold ends

				if (self.desiredPos) then 

					self.nudged = true

				end

			else

				local physObj = self:GetPhysicsObject()

				

				if (IsValid(physObj) and !physObj:IsAsleep()) then

					physObj:Sleep()

				end

				

				--if held with physgun while moving, will teleport to end when hold ends

				if (self.nudged and self.desiredPos) then

					self:SetPos(self.desiredPos)

					self.desiredPos = nil

					self.nudged = nil

					

					self:ResetAnim()

				end

				

				if (!self.desiredPos) then

					if self:GetVelocity():LengthSqr() > 0 then

						self.loco:SetVelocity(Vector(0,0,0))

					end

				end
				
				if (self.desiredPos and !self.loco:IsOnGround()) then --basically they drift off into the sunset if you dont do this

					self:SetPos(self.desiredPos)

					self.desiredPos = nil

					

					self:ResetAnim()

				end

			end

			

			if (self.desiredPos) then

				self.loco:Approach(self.desiredPos, 1)


				local stuck = self.loco:IsStuck()
				--128
				if (self:GetRangeSquaredTo(self.desiredPos) < 32 or stuck) then

					self.loco:SetVelocity(Vector(0,0,0))

					self:SetPos(self.desiredPos)

					self.desiredPos = nil

					self:ResetAnim()

				end

			end



			if (IsValid(self.follow) and !self.desiredPos and !(self.follow and self.follow:InVehicle())) then

				local followPos = self.follow:GetPos() + self.follow:GetRight() * -50

			

				local range = self:GetRangeSquaredTo(followPos)

			

				if (range > 32768 and !stuck) then

					self:MovementStart(followPos)

				

					self.desiredPos2 = followPos
					--256
				elseif ((self.desiredPos2 and range < 64) or stuck) then

					self.loco:SetVelocity(Vector(0,0,0))



					self:SetPos(followPos)

					

					self.desiredPos2 = nil

					

					self:ResetAnim()

				end

				

				if (self.desiredPos2) then

					self.loco:Approach(followPos, 1)

				end

			end

		end

	end


	return true 
end

function ENT:CustomThink()
end

function ENT:HandleStuck()
end

function ENT:MovementStart(position)
    if (SERVER) then
        local tempEntity = ents.Create("info_particle_system")
        tempEntity:SetParent(self)
        tempEntity:SetPos(position)

        self:PointAtEntity(tempEntity)
        local ang = self:GetAngles()
        self:SetAngles(Angle(0, ang.y, 0))

        SafeRemoveEntity(tempEntity)

        self.desiredPos = position
        self:SetNetVar("desiredPos", position)

        if self.isCrouching then
            self:Crouch(true)
        end

        self:WalkAnimation(self:GetPos():Distance(position))
    end
end

function ENT:TurnTowards(position)
    if (SERVER) then
        local tempEntity = ents.Create("info_particle_system")
        tempEntity:SetParent(self)
        tempEntity:SetPos(position)

        self:PointAtEntity(tempEntity)
        local ang = self:GetAngles()
        self:SetAngles(Angle(0, ang.y, 0))

        SafeRemoveEntity(tempEntity)
    end
end

function ENT:OnRemove()
    
end

function ENT:Die(attacker)
    if !self.noRagdoll then
        local ragdoll = ents.Create("prop_ragdoll")
        if ragdoll:IsValid() then
            ragdoll:SetPos(self:GetPos())
			ragdoll:SetModel(self:GetModel())
			ragdoll:SetAngles(self:GetAngles())
			ragdoll:Spawn()
			ragdoll:SetSkin(self:GetSkin())
			ragdoll:SetColor(self:GetColor())
			ragdoll:SetMaterial(self:GetMaterial())
			ragdoll:SetBloodColor(self:GetBloodColor())
				
			local num = ragdoll:GetPhysicsObjectCount()-1
	   
			for i=0, num do
				local bone = ragdoll:GetPhysicsObjectNum(i)

				if IsValid(bone) then
					local bp, ba = self:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
					if bp and ba then
						bone:SetPos(bp)
						bone:SetAngles(ba)
					end
				end
			end

            for k, v in pairs(self:GetBodyGroups()) do
                ragdoll:SetBodygroup(v.id, self:GetBodygroup(v.id))
            end

            ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

            if attacker then
                local posDifference = (attacker:GetPos() - self:GetPos())
                posDifference = posDifference / posDifference:Length()

                local physObj = ragdoll:GetPhysicsObject()

                physObj:ApplyForceCenter(posDifference * math.random(-5000, -8000) + Vector(0, 0, 300))
            end

            --ragdoll:EmitSound(table.Random(self.dieSounds) or "", 100)
        end

        if !IsValid(ragdoll:GetPhysicsObject()) then
            SafeRemoveEntity(ragdoll)
        end
    end

    SafeRemoveEntity(self)
end

function ENT:EquipWeapon(weaponItem, modelPath)
	if(IsValid(self.weapon)) then 
		SafeRemoveEntity(self.weapon)
	end

    if(IsValid(self.dummyModel)) then 
		SafeRemoveEntity(self.dummyModel)
	end

	self.WeaponMount = self:LookupAttachment("anim_attachment_RH")
	self.WeaponPosition = self:GetAttachment(self.WeaponMount)

    if isstring(modelPath) then
        self.weapon = ents.Create("prop_dynamic")
        self.weapon:SetModel(modelPath)
        
        self.weapon:Spawn()
        self.weapon:SetParent(self, self.WeaponMount)
        self.weapon:SetMoveType(MOVETYPE_NONE)
        
        if(self.weapon:GetBoneCount() > 1) then
            self.weapon:AddEffects(EF_BONEMERGE)
        elseif(self.WeaponPosition) then
            PrintTable(self.WeaponPosition)
            self.weapon:SetPos(self.WeaponPosition.Pos)
            self.weapon:SetAngles(self.WeaponPosition.Ang)
        end

        self:SetNetVar("weaponModel", modelPath)
    elseif istable(modelPath) then

        if modelPath[1] then
            self.WeaponMount = self:LookupBone("ValveBiped.Bip01_R_Hand")
            self.WeaponPosition.Pos, self.WeaponPosition.Ang = self:GetBonePosition(self.WeaponMount)
        end

        local dummyModelPath = modelPath[2]
        self.dummyModel = ents.Create("prop_dynamic")
        self.dummyModel:SetModel(dummyModelPath)

        self.dummyModel:Spawn()
        self.dummyModel:SetParent(self, self.WeaponMount)
        self.dummyModel:SetMoveType(MOVETYPE_NONE)
        self.dummyModel:SetMaterial("null")

        if(self.dummyModel:GetBoneCount() > 1) then
            self.dummyModel:AddEffects(EF_BONEMERGE)
        elseif(self.WeaponPosition) then
            PrintTable(self.WeaponPosition)
            self.dummyModel:SetPos(self.WeaponPosition.Pos)
            self.dummyModel:SetAngles(self.WeaponPosition.Ang)
        end

        local weaponModel = modelPath[3]
        self.weapon = ents.Create("prop_dynamic")
        self.weapon:SetModel(weaponModel)

        self.weapon:Spawn()
        self.weapon:SetParent(self.dummyModel)
        self.weapon:SetMoveType(MOVETYPE_NONE)

        local pos = self.dummyModel:GetPos()
        local ang = self.dummyModel:GetAngles()
        local wepPos = modelPath[4]
        local wepAng = modelPath[5]

        ang:RotateAroundAxis(ang:Up(), wepAng.y)
        ang:RotateAroundAxis(ang:Right(), wepAng.p)
        ang:RotateAroundAxis(ang:Forward(), wepAng.r)

        self.weapon:SetPos(pos + ang:Forward() * wepPos.x + ang:Right() * wepPos.y + ang:Up() * wepPos.z)
        self.weapon:SetAngles(ang)

        self:SetNetVar("weaponModel", modelPath[3])
    end

    self:SetNetVar("weapon", weaponItem)
end

function ENT:getSaveData()
	local saveData = {}

	saveData.name = self:Name() or "Name Corrupted"

	saveData.desc = self:GetDescription() or "Desc Corrupted"

	--saveData.hp = self:getHP()

	--saveData.hpMax = self:getMaxHP()

	--saveData.mp = self:getMP()

	--saveData.mpMax = self:getMaxMP()

	--saveData.attribs = self.attribs

	--saveData.actions = self.actions

	--saveData.dmg = self.dmg

	--saveData.res = self:GetNetVar("res")

	--saveData.amp = self:GetNetVar("amp")

	if self.curbonegun then

		saveData.gunmodel = self.curbonegun
		
	end

	saveData.model = self:GetModel()

	saveData.mat = self:GetMaterial()

	saveData.anim = self:GetSequence()

	saveData.color = self:GetColor()

	saveData.skin = self:GetSkin()

	

	saveData.bodygroups = {

		self:GetBodygroup(1),

		self:GetBodygroup(2),

		self:GetBodygroup(3),

		self:GetBodygroup(4),

		self:GetBodygroup(5),

		self:GetBodygroup(6),

		self:GetBodygroup(7),

		self:GetBodygroup(8),

		self:GetBodygroup(9),

		self:GetBodygroup(10),

		self:GetBodygroup(11),

		self:GetBodygroup(12),

	}

	

	return saveData

end




if (CLIENT) then
    function ENT:Draw()
        self:SetIK(false)
        self:DrawModel()
    end



    ENT.PopulateEntityInfo = true

    function ENT:OnPopulateEntityInfo(container)
        local name = container:AddRow("name")
        name:SetImportant()
        name:SetText(self:Name())
        name:SizeToContents()

        local desc = container:AddRow("description")
        desc:SetText(self:GetDescription())
        desc:SizeToContents()
    end
end


PLUGIN.CEntBase = ENT