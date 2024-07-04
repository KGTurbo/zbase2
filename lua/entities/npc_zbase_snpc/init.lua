include("shared.lua")
include("zbase_ai.lua")
include("zbase_aerial.lua")


ENT.IsZBase_SNPC = true




function ENT:Initialize()

	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_STEP)
	self:SetCollisionGroup(COLLISION_GROUP_NPC)
	

	self.Bullseye = ents.Create("npc_bullseye")
	self.Bullseye:SetPos(self:GetPos())
	self.Bullseye:SetAngles(self:GetAngles())
	self.Bullseye:SetNotSolid(true)
	self.Bullseye:SetParent(self)
	self.Bullseye:SetHealth(math.huge)
	self.Bullseye:AddEFlags(EFL_DONTBLOCKLOS)
	self.Bullseye:Spawn()
	self.Bullseye:Activate()


	self:SNPCInitVars()

end


function ENT:SNPCInitVars()
	self.NextDetermineNewSched = CurTime()
	self.Move_AvoidSquadMembers = CurTime()
	self.Aerial_NextMoveFromGroundCheck = CurTime()
	self:SetNotNavStuck()
	self.Navigator = NULL
	self.Aerial_CurSpeed = 0
	self.Aerial_LastMoveDir = self:GetForward()
	self.SNPCNextSlowThink = CurTime()
	self.NextFaceHurtPos = CurTime()
	self.NextGetBetterSchedule = CurTime()
	self.NextSelectSchedule = CurTime()
end


function ENT:Think()

	if self.SNPCType == ZBASE_SNPCTYPE_FLY then
		self:AerialThink()
	end


	-- Apply notarget to its bullseye
	if IsValid(self.Bullseye) then

		local hasNoTarget, bullseyeNoTarget = self:Conv_HasFlags(FL_NOTARGET), self.Bullseye:Conv_HasFlags(FL_NOTARGET)
		if hasNoTarget && !bullseyeNoTarget then
			self.Bullseye:AddFlags(FL_NOTARGET)
		elseif !hasNoTarget && bullseyeNoTarget then
			self.Bullseye:RemoveFlags(FL_NOTARGET)
		end

	end


	self:ZBaseThink()

end


local NPCMETA = FindMetaTable("NPC")
ZBase_OldGetNearestSquadMember = ZBase_OldGetNearestSquadMember or NPCMETA.GetNearestSquadMember

function NPCMETA:GetNearestSquadMember( radius, zbaseSNPCOnly )
	if !self.IsZBase_SNPC then return ZBase_OldGetNearestSquadMember(self) end

	local mindist
	local squadmember

	for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius or 256)) do
		if v == self then continue end
		if !v:IsNPC() then continue end
		if zbaseSNPCOnly && !v.IsZBase_SNPC then continue end

		if self:SquadName() == v:GetKeyValues().squadname then
			local dist = self:GetPos():DistToSqr(v:GetPos())

			if !mindist or dist < mindist then
				mindist = dist
				squadmember = v
			end
		end
	end

	return squadmember
end


function ENT:OnTakeDamage( dmginfo )
	-- On hurt behaviour
	self:SNPCOnHurt(dmginfo)


	-- Decrease health
	self:SetHealth( self:Health() - dmginfo:GetDamage() )


	-- Die
	if self:Health() <= 0 then
		hook.Run("OnNPCKilled", self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	end
end

