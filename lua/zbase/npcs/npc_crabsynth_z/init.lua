local NPC = FindZBaseTable(debug.getinfo(1,'S'))

NPC.Models = {"models/zippy/Synth.mdl"}
NPC.StartHealth = 320


NPC.BloodColor = DONT_BLEED
NPC.CustomBloodParticles = {"blood_impact_synth_01"} -- Table of custom particles
NPC.CustomBloodDecals = "ZBaseBloodSynth" -- String name of custom decal

NPC.CollisionBounds = {min=Vector(-75, -75, 0), max=Vector(75, 75, 90)}
NPC.HullType = HULL_LARGE -- The hull type, false = default, https://wiki.facepunch.com/gmod/Enums/HULL


NPC.ZBaseStartFaction = "combine"


NPC.BaseMeleeAttack = true -- Use ZBase melee attack system
NPC.MeleeAttackCooldown = {0, 0} -- Melee attack cooldown {min, max}
NPC.MeleeDamage_AffectProps = true -- Affect props and other entites
NPC.MeleeAttackAnimationSpeed = 1.33 -- Speed multiplier for the melee attack animation
NPC.MeleeDamage = {20, 30} -- Melee damage {min, max}
NPC.MeleeDamage_Type = DMG_SLASH -- The damage type, https://wiki.facepunch.com/gmod/Enums/DMG
NPC.MeleeDamage_Delay = false -- Time until the damage strikes, set to false to disable the timer (if you want to use animation events instead)
NPC.MeleeDamage_Sound = "ZBaseCrabSynth.MeleeHit" -- Sound when the melee attack hits an enemy
NPC.MeleeDamage_Sound_Prop = "ZBaseCrabSynth.Melee2" -- Sound when the melee attack hits props


        -- ARMOR SYSTEM --
NPC.HasArmor = {
    [HITGROUP_GENERIC] = true,
}
NPC.ArmorPenChance = false -- 1/x Chance that the armor is penetrated, false = never
NPC.ArmorAlwaysPenDamage = false -- Always penetrate the armor if the damage is more than this, set to false to disable
NPC.ArmorHitSpark = false -- Do a spark on armor hit
NPC.ArmorReflectsBullets = true -- Should the armor reflect bullets?


NPC.SquadGiveSpace = 256
NPC.CantReachEnemyBehaviour = ZBASE_CANTREACHENEMY_FACE -- ZBASE_CANTREACHENEMY_HIDE || ZBASE_CANTREACHENEMY_FACE


        -- BASE RANGE ATTACK --
NPC.BaseRangeAttack = true -- Use ZBase range attack system
NPC.RangeAttackAnimations = {} -- Example: NPC.RangeAttackAnimations = {ACT_RANGE_ATTACK1}
NPC.RangeProjectile_Inaccuracy = 0.07
NPC.RangeAttackCooldown = {8, 12} -- Range attack cooldown {min, max}
NPC.RangeAttackDistance = {300, 2000} -- Distance that it initiates the range attack {min, max}
NPC.RangeAttackTurnSpeed = 10 -- Speed that it turns while trying to face the enemy when range attacking
NPC.RangeProjectile_Attachment = "muzzle"


-- Time until the projectile code is ran
-- Set to false to disable the timer (if you want to use animation events instead for example)
NPC.RangeProjectile_Delay = false


NPC.FlinchAnimations = {ACT_BIG_FLINCH} -- Flinch animations to use, leave empty to disable the base flinch
NPC.FlinchAnimationSpeed = 1.5 -- Speed of the flinch animation
NPC.FlinchCooldown = {4, 5} -- Flinch cooldown in seconds {min, max}
NPC.FlinchChance = 1 -- Flinch chance 1/x


-- Sounds (Use sound scripts to alter pitch and level and such!)
NPC.AlertSounds = "ZBaseCrabSynth.Alert" -- Sounds emitted when an enemy is seen for the first time
NPC.IdleSounds = "ZBaseCrabSynth.Idle" -- Sounds emitted while there is no enemy
NPC.Idle_HasEnemy_Sounds = "ZBaseCrabSynth.Idle" -- Sounds emitted while there is an enemy
NPC.PainSounds = "ZBaseCrabSynth.Pain" -- Sounds emitted on hurt
NPC.DeathSounds = "ZBaseCrabSynth.Death" -- Sounds emitted on death
NPC.KilledEnemySounds = "" -- Sounds emitted when the NPC kills an enemy

NPC.LostEnemySounds = "ZBaseCrabSynth.LostEnemy" -- Sounds emitted when the enemy is lost
NPC.SeeDangerSounds = "" -- Sounds emitted when the NPC spots a danger, such as a flaming barrel
NPC.SeeGrenadeSounds = "" -- Sounds emitted when the NPC spots a grenade
NPC.AllyDeathSounds = "" -- Sounds emitted when an ally dies
NPC.OnMeleeSounds = "ZBaseCrabSynth.Announce" -- Sounds emitted when the NPC does its melee attack
NPC.OnRangeSounds = "ZBaseCrabSynth.Announce" -- Sounds emitted when the NPC does its range attack
NPC.OnReloadSounds = "" -- Sounds emitted when the NPC reloads

-- Sounds emitted when the NPC hears a potential enemy, only with this addon enabled:
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3001759765
NPC.HearDangerSounds = "ZBaseCrabSynth.HearSound"

-- Sound cooldowns {min, max}
NPC.IdleSoundCooldown = {5, 10}
NPC.IdleSounds_HasEnemyCooldown = {5, 10}
NPC.PainSoundCooldown = {1, 2.5}
NPC.AlertSoundCooldown = {4, 8}

-- Sound chance 1/X
NPC.IdleSound_Chance = 3
NPC.AllyDeathSound_Chance = 2
NPC.OnMeleeSound_Chance = 2
NPC.OnRangeSound_Chance = 2
NPC.OnReloadSound_Chance = 2


--]]==============================================================================================]]
function NPC:CustomInitialize()
    self.MinigunShootSound = CreateSound(self, "ZBaseCrabSynth.MinigunLoop")
end
--]]==============================================================================================]]
function NPC:MultipleMeleeAttacks()
    local rnd = math.random(1, 3)

    
    if rnd == 1 then

        self.MeleeAttackAnimations = {"attack2"}
        self.MeleeDamage = {20, 30} -- Melee damage {min, max}
        self.MeleeDamage_Angle = 180 -- Damage angle (180 = everything in front of the NPC is damaged)
        self.MeleeAttackName = "bigmelee" -- Serves no real purpose, you can use it for whatever you want
        self.MeleeAttackFaceEnemy = true -- Should it face enemy while doing the melee attack?
        self.MeleeAttackDistance = 190
        self.MeleeDamage_Distance = 200 -- Distance the damage travels

    elseif rnd == 2 then

        self.MeleeAttackAnimations = {"attack1"}
        self.MeleeDamage = {20, 20} -- Melee damage {min, max}
        self.MeleeDamage_Angle = 90 -- Damage angle (180 = everything in front of the NPC is damaged)
        self.MeleeAttackName = "smallmelee" -- Serves no real purpose, you can use it for whatever you want
        self.MeleeAttackFaceEnemy = true -- Should it face enemy while doing the melee attack?
        self.MeleeAttackDistance = 190
        self.MeleeDamage_Distance = 200 -- Distance the damage travels

    elseif rnd == 3 then

        self.MeleeAttackAnimations = {ACT_MELEE_ATTACK2}
        self.MeleeDamage = {20, 20} -- Melee damage {min, max}
        self.MeleeDamage_Angle = 90 -- Damage angle (180 = everything in front of the NPC is damaged)
        self.MeleeAttackName = "runmelee" -- Serves no real purpose, you can use it for whatever you want
        self.MeleeAttackFaceEnemy = false -- Should it face enemy while doing the melee attack?
        self.MeleeAttackDistance = 250
        self.MeleeDamage_Distance = 200 -- Distance the damage travels

    end
end
--]]==============================================================================================]]
function NPC:CustomThink()
    local seqName = self:GetSequenceName(self:GetSequence())


    -- Range attack face code
    if seqName == "range_loop" or seqName == "range_start" then
        self:Face(self:RangeAttack_IdealFacePos(), nil, self.RangeAttackTurnSpeed)
    end


    -- Shoot loop sound
    if seqName == "range_loop" && !self.MinigunShootSound:IsPlaying() then
        self.MinigunShootSound:Play()
    elseif seqName != "range_loop" && self.MinigunShootSound:IsPlaying() then
        self.MinigunShootSound:Stop()
    end


    -- Charge attack think
    if seqName == "charge_loop" then
        -- Charge attack does melee damage
        self.MeleeDamage = {20, 30} -- Melee damage {min, max}
        self.MeleeDamage_Angle = 90 -- Damage angle (180 = everything in front of the NPC is damaged)
        self.MeleeAttackName = "runmelee" -- Serves no real purpose, you can use it for whatever you want
        self.MeleeDamage_Distance = 115 -- Distance the damage travels
        local ChargeHitEnts = self:MeleeAttackDamage()


        -- Hit wall, stop
        local startPos = self:GetPos()+self:GetUp()*20
        local tr = util.TraceEntity({
            start = startPos,
            endpos = startPos+self:GetForward()*80,
            mask = MASK_NPCWORLDSTATIC,
        }, self)
        if tr.Hit then
            self:StopCurrentAnimation()
        end


        -- Hit target, stop
        for _, ent in ipairs(ChargeHitEnts) do
            if ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot() then
                self:StopCurrentAnimation()
                break
            end
        end
    end
end
--]]==============================================================================================]]
function NPC:OnRangeAttack()
    local duration = math.Rand(3, 6)

    self:PlayAnimation(ACT_RANGE_ATTACK1, false, {duration=duration})
    self.CurTargetPos = nil -- Reset
    self.CurTrackSpeed = 0.01
end
--]]==============================================================================================]]
function NPC:RangeAttackProjectile()
    if !self.CurTrackSpeed then return end


    local projStartPos = self:Projectile_SpawnPos()
    local projEndPos = self:Projectile_TargetPos()


    -- Track the enemy's position more slowly --

    if !self.CurTargetPos then
        -- Target pos reset, set to in front of itself
        self.CurTargetPos = self:GetAttachment(1).Pos+self:GetForward()*100
    else
        -- Steer towards projectile target pos, increase the speed of the tracking as well
        -- Only track the position slowly if the enemy is far away
        self.CurTargetPos = (self:ZBaseDist(projEndPos, {away=400}) or !self:IsFacing(projEndPos, 90))
        && Lerp(self.CurTrackSpeed, self.CurTargetPos, projEndPos)
        or projEndPos

        self.CurTrackSpeed = self.CurTrackSpeed+0.005
    end

    self:FireBullets({
        Attacker = self,
        Inflictor = self,
        Damage = 3,
        Dir = (self.CurTargetPos - projStartPos):GetNormalized(),
        Src = projStartPos,
        Spread = Vector(self.RangeProjectile_Inaccuracy, self.RangeProjectile_Inaccuracy),
        TracerName = "HelicopterTracer",
    })
    --------------------------------------=#


    local effectdata = EffectData()
    effectdata:SetEntity(self)
    effectdata:SetAttachment(1)
    util.Effect("ChopperMuzzleFlash", effectdata, true, true)
end
--]]==============================================================================================]]
function NPC:MeleeDamageForce( dmgData )
    if dmgData.name == "smallmelee" then
        return {forward=150, up=325, right=-350, randomness=75}
    elseif dmgData.name == "bigmelee" then
        return {forward=500, up=75, right=0, randomness=150}
    elseif dmgData.name == "runmelee" then
        return {forward=300, up=350, right=0, randomness=75}
    end
end
--]]==============================================================================================]]
function NPC:SNPCHandleAnimEvent(event, eventTime, cycle, type, option) 
    if event == 5 then
        self:MeleeAttackDamage()
    end


    if event == 2042 then
        self:RangeAttackProjectile()
    end
end
--]]==============================================================================================]]
function NPC:OnFlinch(dmginfo, HitGroup, flinchAnim)
    if dmginfo:GetDamage() < 80 then return false end
    if !dmginfo:IsExplosionDamage() then return false end


    return true
end
--]]==============================================================================================]]
function NPC:CustomTakeDamage( dmginfo, HitGroup )
    local damageHeight = (dmginfo:GetDamagePosition().z - self:WorldSpaceCenter().z)+10


    if !(damageHeight < 0 && dmginfo:IsExplosionDamage() && self:GetSequenceName(self:GetSequence()) != "bodythrow") then
        dmginfo:ScaleDamage(0.1)
    end
end
--]]==============================================================================================]]