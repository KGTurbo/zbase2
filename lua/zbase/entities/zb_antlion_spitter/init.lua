local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.StartHealth = 60 -- Max health


-- Default engine blood color, set to DONT_BLEED if you want to use custom blood instead
NPC.BloodColor = DONT_BLEED -- DONT_BLEED || BLOOD_COLOR_RED || BLOOD_COLOR_YELLOW || BLOOD_COLOR_GREEN
-- || BLOOD_COLOR_MECH || BLOOD_COLOR_ANTLION || BLOOD_COLOR_ZOMBIE || BLOOD_COLOR_ANTLION_WORKER
NPC.CustomBloodParticles = {"blood_impact_zbase_blue"} -- Table of custom particles
NPC.CustomBloodDecals = "ZBaseBloodBlue" -- String name of custom decal

NPC.SubMaterials = {
    [2] = "models/antlionspitter/antlionhigh_sheet2",
}


-- ZBase faction
-- Can be any string, all ZBase NPCs with the same faction will be allied
-- Default factions:
-- "combine" || "ally" || "zombie" || "antlion" || "none" || "neutral"
    -- "none" = not allied with anybody
    -- "neutral" = allied with everybody
NPC.ZBaseStartFaction = "antlion"


NPC.BaseRangeAttack = true -- Use ZBase range attack system
NPC.RangeAttackFaceEnemy = true -- Should it face enemy while doing the range attack?
NPC.RangeAttackTurnSpeed = 10 -- Speed that it turns while trying to face the enemy when range attacking
NPC.RangeAttackDistance = {0, 1000} -- Distance that it initiates the range attack {min, max}
NPC.RangeAttackCooldown = {2, 4} -- Range attack cooldown {min, max}
NPC.RangeAttackSuppressEnemy = true -- If the enemy can't be seen, target the last seen position


NPC.RangeAttackAnimations = {"pounce"} -- Example: NPC.RangeAttackAnimations = {ACT_RANGE_ATTACK1}
NPC.RangeAttackAnimationSpeed = 1 -- Speed multiplier for the range attack animation


-- Time until the projectile code is ran
-- Set to false to disable the timer (if you want to use animation events instead for example)
NPC.RangeProjectile_Delay = 1


-- Attachment to spawn the projectile on 
-- If set to false the projectile will spawn from the NPCs center
NPC.RangeProjectile_Attachment = false
NPC.RangeProjectile_Offset = false -- Projectile spawn offset, example: {forward=50, up=25, right=0}
NPC.RangeProjectile_Speed = 2000 -- The speed of the projectile
NPC.RangeProjectile_Inaccuracy = 0 -- Inaccuracy, 0 = perfect, higher numbers = less accurate


--]]==============================================================================================]]
function NPC:CustomInitialize()
    self:SetSkin(1)
end
--]]==============================================================================================]]
function NPC:RangeAttackProjectile()
    local projStartPos = self:Projectile_SpawnPos()

    local proj = ents.Create("zb_spit")
    proj:SetPos(projStartPos)
    proj:SetAngles(self:GetAngles())
    proj:SetOwner(self)
    proj:Spawn()

    local proj_phys = proj:GetPhysicsObject()
    if IsValid(proj_phys) then
        proj_phys:SetVelocity(self:RangeAttackProjectileVelocity()+Vector(0, 0, 150))
    end
end
--]]==============================================================================================]]