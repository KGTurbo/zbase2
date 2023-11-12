include("shared.lua")
util.AddNetworkString("base_ai_zbase_client_ragdoll")


ENT.m_iClass = CLASS_NONE -- NPC Class
ENT.IsZBase_SNPC = true

--------------------------------------------------------------------------------=#
function ENT:Initialize()
	self:SetHullType(self.HullType or HULL_MEDIUM)
	self:SetHullSizeNormal()
	self:SetSolid(SOLID_BBOX)

	if self.Initialize_Aerial then
		self:Initialize_Aerial()
	else
		self:CapabilitiesAdd(CAP_MOVE_GROUND)
	end

	self:SetMoveType(MOVETYPE_STEP)

	self.Bullseye = ents.Create("npc_bullseye")
	self.Bullseye:SetPos(self:GetPos())
	self.Bullseye:SetAngles(self:GetAngles())
	self.Bullseye:SetNotSolid(true)
	self.Bullseye:SetParent(self)
	self.Bullseye:AddEFlags(EFL_DONTBLOCKLOS)
	self.Bullseye:Spawn()
	self.Bullseye:Activate()
end
--------------------------------------------------------------------------------=#
function ENT:Think()
	-- Sussy phys object
	local phys = self:GetPhysicsObject()
	phys:SetPos(self:GetPos())

	self:NextThink( CurTime() ) -- Set the next think to run as soon as possible, i.e. the next frame.
	return true -- Apply NextThink call
end
--------------------------------------------------------------------------------=#
function ENT:SelectSchedule( iNPCState )
	self:SNPCSelectSchedule( iNPCState )
end
--------------------------------------------------------------------------------=#
function ENT:ServerRagdoll( dmginfo )
	local rag = ents.Create("prop_ragdoll")
	rag:SetModel(self:GetModel())
	rag:SetPos(self:GetPos())
	rag:SetAngles(self:GetAngles())
	rag:SetSkin(self:GetSkin())
	rag:SetColor(self:GetColor())
	rag:SetMaterial(self:GetMaterial())
	rag:Spawn()
	local ragPhys = rag:GetPhysicsObject()

	if !IsValid(ragPhys) then
		rag:Remove()
		return
	end

	-- Ragdoll force
	if dmginfo:IsBulletDamage() then
		ragPhys:SetVelocity(dmginfo:GetDamageForce()*0.1)
	else
		ragPhys:SetVelocity(dmginfo:GetDamageForce())
	end

	-- Placement
	local physcount = rag:GetPhysicsObjectCount()
	for i = 0, physcount - 1 do
		local physObj = rag:GetPhysicsObjectNum(i)
		local pos, ang = self:GetBonePosition(self:TranslatePhysBoneToBone(i))
		physObj:SetPos( pos )
		physObj:SetAngles( ang )
	end

	-- Hook
	hook.Run("CreateEntityRagdoll", self, rag)

	-- Dissolve
	if dmginfo:IsDamageType(DMG_DISSOLVE) then
		rag:SetName( "base_ai_ext_rag" .. rag:EntIndex() )

		local dissolve = ents.Create("env_entity_dissolver")
		dissolve:SetKeyValue("target", rag:GetName())
		dissolve:SetKeyValue("dissolvetype", dmginfo:IsDamageType(DMG_SHOCK) && 2 or 0)
		dissolve:Fire("Dissolve", rag:GetName())
		dissolve:Spawn()
		rag:DeleteOnRemove(dissolve)

		rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

		undo.ReplaceEntity( rag, NULL )
		cleanup.ReplaceEntity( rag, NULL )
	end

	-- Ignite
	if self:IsOnFire() then
		rag:Ignite(math.Rand(4,8))
	end
end
--------------------------------------------------------------------------------=#
function ENT:ClientRagdoll( dmginfo )
	net.Start("base_ai_zbase_client_ragdoll")
	net.WriteEntity(self)
	net.WriteVector(dmginfo:GetDamageForce())
	net.Broadcast()
end
--------------------------------------------------------------------------------=#
function ENT:Die( dmginfo )

	if self.Dead then return end
	self.Dead = true

	-- Death notice and other stuff
	hook.Run("OnNPCKilled", self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	self:SetNPCState(NPC_STATE_DEAD)

	if self:GetShouldServerRagdoll() or dmginfo:IsDamageType(DMG_DISSOLVE) then
		self:ServerRagdoll( dmginfo )
		self:Remove()
	else
		self:ClientRagdoll( dmginfo )
        self:AddFlags(FL_NOTARGET)
        self:SetCollisionBounds(Vector(), Vector())
        self:SetBloodColor(-1)
        self:CapabilitiesClear()
        self:SetNoDraw(true)
        SafeRemoveEntityDelayed(self, 0.66)
	end

end
--------------------------------------------------------------------------------=#
function ENT:OnTakeDamage( dmginfo )
	-- Face damage
	if !IsValid(self:GetEnemy()) then
		self:FullReset()
		self:SetLastPosition(dmginfo:GetDamagePosition())

		timer.Simple(0.1, function()
			self:StartSchedule(ZSched.FaceLastPos)
		end)
	end

	-- Decrease health
	self:SetHealth( self:Health() - dmginfo:GetDamage() )

	-- Die
	if self:Health() <= 0 then
		self:Die( dmginfo )
	end
end
--------------------------------------------------------------------------------=#
function ENT:DoNPCState()
	local enemy = self:GetEnemy()
	local enemyInvalidPlayer = IsValid(enemy) && enemy:IsPlayer() && (!enemy:Alive() or GetConVar("ai_ignoreplayers"):GetBool())


	-- If there is no valid enemy and the NPC state is combat, set to idle
	if !(IsValid(enemy) && !enemyInvalidPlayer)
	&& self:GetNPCState() == NPC_STATE_COMBAT then
		self:SetNPCState(NPC_STATE_IDLE)
	end
end
--------------------------------------------------------------------------------=#
function ENT:DoSequence()
	if self.StopPlaySeqTime > CurTime() then
		-- self:SetSequence(self.ZBaseSNPCSequence)
	else
		self:SetPlaybackRate(1)
		self:ResetIdealActivity(ACT_IDLE)
		self.BaseDontSetPlaybackRate = true
	end

	return true
end
--------------------------------------------------------------------------------=#
function ENT:FullReset()
    self:TaskComplete()
    self:ClearGoal()
    self:ScheduleFinished()
    self:ClearSchedule()
    self:StopMoving()
    self:SetMoveVelocity(Vector())
end
--------------------------------------------------------------------------------=#
function ENT:GetCurrentCustomSched()
	return self.CurrentSchedule && self.CurrentSchedule.DebugName
end
--------------------------------------------------------------------------------=#
function ENT:StopUnwantedSchedules()
	-- local sched = self:GetCurrentCustomSched()
	-- local enemy = self:GetEnemy()
	-- local enemyValid = IsValid(enemy)
	-- local enemyVisible = enemyValid && self:Visible(enemy)


	-- -- Can't reach the enemy when chasing
	-- if enemyValid && sched=="CombatChase" && self:IsNavStuck() then
	-- 	if enemyVisible then
	-- 		-- Take cover if enemy is visible
	-- 		self:FullReset()
	-- 		self:SetSchedule(SCHED_TAKE_COVER_FROM_ENEMY)

	-- 	else
	-- 		-- Patrol if enemy is not visible
	-- 		self:FullReset()
	-- 		self:SetSchedule(SCHED_COMBAT_PATROL)

	-- 	end

	-- 	return
	-- end


	-- -- Don't combat patrol if enemy is seen
	-- if enemyValid && enemyVisible && self:IsCurrentSchedule(SCHED_COMBAT_PATROL) then
	-- 	self:FullReset()

	-- 	return
	-- end
end
--------------------------------------------------------------------------------=#
function ENT:IsNavStuck()
	if !self.NextStuck then return false end
	return self.NextStuck < CurTime()
end
--------------------------------------------------------------------------------=#
function ENT:DetermineNavStuck()
	if self:IsGoalActive() && self:GetCurWaypointPos()!=Vector() then
		self.NextStuck = CurTime()+0.3
	end
end
--------------------------------------------------------------------------------=#
function ENT:RunAI( strExp )
	self:DoNPCState()
	
	-- Play sequence:
	if self.ZBaseSNPCSequence then
		local dontRunAI = self:DoSequence()
		
		if dontRunAI then return end
	end

	self:StopUnwantedSchedules() -- Stop, or replace schedules that shouldn't play right now
	self:DetermineNavStuck() -- Check if waypoint has been 0,0,0 for some time

	-- If we're running an Engine Side behaviour
	-- then return true and let it get on with it.
	if ( self:IsRunningBehavior() ) then
		return true
	end

	-- If we're doing an engine schedule then return true
	-- This makes it do the normal AI stuff.
	if ( self:DoingEngineSchedule() ) then
		return true
	end

	-- If we're currently running a schedule then run it.
	if ( self.CurrentSchedule ) then
		self:DoSchedule( self.CurrentSchedule )
	end

	-- If we have no schedule (schedule is finished etc)
	-- Then get the derived NPC to select what we should be doing
	if ( !self.CurrentSchedule ) then
		self:SelectSchedule()
	end

	-- Do animation system
	self:MaintainActivity()

end
--------------------------------------------------------------------------------=#