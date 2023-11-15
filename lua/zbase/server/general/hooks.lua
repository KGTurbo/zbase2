util.AddNetworkString("ZBaseInitEnt")

local grabbing_bullet_backup_data = false
local PreventCallAccuracyBoost = false

local ZBaseNextThink = CurTime()
local NextBehaviourThink = CurTime()

local ZBaseWeaponDMGs = {
    ["weapon_rpg"] = {dmg=150, inflclass="rpg_missile"},
    ["weapon_crossbow"] = {dmg=100, inflclass="crossbow_bolt"},
}
local ZBaseWeaponAccuracyBoost = {
    ["weapon_shotgun"] = 30,
    ["weapon_smg1"] = 40,
    ["weapon_pistol"] = 50,
}

---------------------------------------------------------------------------------------=#
local function TellZBaseNPCsEnemyDied(npc)
    for _, v in ipairs(ZBaseNPCInstances) do
        if v:GetEnemy() == npc then
            v.EnemyDied = true

            timer.Create("ZBaseEnemyDied_False"..npc:EntIndex(), 2, 1, function()
                if IsValid(v) then
                    v.EnemyDied = false
                end
            end)
        end
    end
end
---------------------------------------------------------------------------------------=#
hook.Add("InitPostEntity", "ZBaseReplaceFuncsServer", function() timer.Simple(0.5, function()
	local ENT = FindMetaTable("Entity")
	local emitSound = ENT.EmitSound
	local OnNPCKilled = GAMEMODE.OnNPCKilled
	local SpawnNPC = Spawn_NPC


	----------------------------------------------------------------------------------------------=#
	function GAMEMODE:OnNPCKilled( npc, attacker, ... )
		if IsValid(attacker) && attacker.IsZBaseNPC then
			attacker:OnKilledEnt( npc )
		end

        TellZBaseNPCsEnemyDied(npc)


		if npc.IsZBaseNPC then
            -- Death sound
			npc:EmitSound(npc.DeathSounds)


            local ally = npc:GetNearestAlly(600)
            local deathpos = npc:GetPos()
            if IsValid(ally) && ally:Visible(npc) then
                timer.Simple(0.5, function()
                    if IsValid(ally)
                    && ally.AllyDeathSound_Chance
                    && math.random(1, ally.AllyDeathSound_Chance) == 1 then
                        ally:EmitSound_Uninterupted(ally.AllyDeathSounds)

                        if ally.AllyDeathSounds != "" then
                            ally:FullReset()
                            ally:Face(deathpos, SoundDuration(ally.AllyDeathSounds))
                        end
                    end
                end)
            end


            SafeRemoveEntityDelayed(npc, 0.15) -- Remove earlier
		end


		return OnNPCKilled(self, npc, ...)
	end
	----------------------------------------------------------------------------------------------=#
	function Spawn_NPC( ply, NPCClassName, WeaponName, tr, ... )
        if ZBaseNPCs[NPCClassName] then
            return Spawn_ZBaseNPC( ply, NPCClassName, WeaponName, tr, ... )
        else
		    return SpawnNPC( ply, NPCClassName, WeaponName, tr, ... )
        end
	end
	----------------------------------------------------------------------------------------------=#
	function ENT:EmitSound( snd, ... )

		if self.IsZBaseNPC && snd == "" then return end

		ZBase_EmitSoundCall = true
		local v = emitSound(self, snd, ...)
		ZBase_EmitSoundCall = false

		return v

	end
	----------------------------------------------------------------------------------------------=#
end) end)
---------------------------------------------------------------------------------------=#
hook.Add("OnEntityCreated", "ZBASE", function( ent ) timer.Simple(0, function()
    if !IsValid(ent) then return end

    -- ZBase init stuff when not spawned from menu
    local zbaseClass = ent:GetKeyValues().parentname
    local zbaseNPCTable = ZBaseNPCs[ ent:GetKeyValues().parentname ]
    if zbaseNPCTable then
        ZBaseInitialize(ent, zbaseNPCTable, zbaseClass, false)
    end


    -- Give ZBase faction to non zbase NPCs
    -- if ent:IsNPC() && !ent.IsZBaseNPC && ent:GetClass() != "npc_bullseye" then
    --     local faction = ZBaseFactionTranslation[ent:Classify()]
        
    --     if faction then
    --         ent.ZBaseFaction = faction
    --     end

    --     table.insert(ZBase_NonZBaseNPCs, ent)
    --     ent:CallOnRemove("ZBase_RemoveFromNPCTable", function() table.RemoveByValue(ZBase_NonZBaseNPCs, ent) end)
    -- end


    local own = ent:GetOwner()
    if IsValid(own) && own.IsZBaseNPC then
        own:OnOwnedEntCreated( ent )
    end
end) end)
---------------------------------------------------------------------------------------=#
hook.Add("Tick", "ZBASE", function()
    -- Think for NPCs that aren't scripted
    if ZBaseNextThink < CurTime() then
        for _, v in ipairs(ZBaseNPCInstances_NonScripted) do
            v:ZBaseThink()

            if v.ZBaseEnhancedThink then
                v:ZBaseEnhancedThink()
            end
        end

        ZBaseNextThink = CurTime()+0.1
    end
    --------------------------------------------------------=#


    -- Behaviour tick
    if !GetConVar("ai_disabled"):GetBool()
    && NextBehaviourThink < CurTime() then
        for k, func in ipairs(ZBaseBehaviourTimerFuncs) do
            local entValid = func()

            if !entValid then
                table.remove(ZBaseBehaviourTimerFuncs, k)
            end
        end

        NextBehaviourThink = CurTime() + 0.5
    end
    --------------------------------------------------------=#
end)
---------------------------------------------------------------------------------------=#
hook.Add("EntityTakeDamage", "ZBASE", function( ent, dmg )

    if ent.IsZBaseNPC then
        ent:InternalDamageScale(dmg)
        ent:OnHurt(dmg)
    end


    local attacker = dmg:GetAttacker()
    local infl = dmg:GetInflictor()


    -- if IsValid(attacker) then
    --     ent.ZBaseLastAttacker = attacker
    -- end

    if IsValid(attacker.ZBaseComballOwner) then

        dmg:SetAttacker(attacker.ZBaseComballOwner)

        if ent:GetClass() == "npc_hunter" or ent:GetClass() == "npc_strider" then

            attacker:Fire("Explode")

            if attacker.ZBaseComballOwner.ZBaseFaction != ent.ZBaseFaction
            or attacker.ZBaseComballOwner.ZBaseFaction == "none" then
                local dmg2 = DamageInfo()
                dmg2:SetDamage(ent:GetClass() == "npc_strider" && 100 or 1000)
                dmg2:SetDamageType(DMG_DISSOLVE)
                dmg2:SetAttacker(dmg:GetAttacker())
                ent:TakeDamageInfo(dmg2)
            end

        end

        attacker = attacker.ZBaseComballOwner

    end


    -- Don't hurt NPCs in same faction
    if attacker.IsZBaseNPC
    && ent.IsZBaseNPC
    && ent:HasCapability(CAP_FRIENDLY_DMG_IMMUNE)
    && attacker.ZBaseFaction == ent.ZBaseFaction
    && ent.ZBaseFaction != "none" then
        dmg:ScaleDamage(0)
        return true
    end


    if IsValid(attacker) && attacker.IsZBaseNPC then
    
        local r = attacker:DealDamage(ent, dmg)
        if r then
            return r
        end

        -- Proper damage values for some hl2 weapons --
        local wep = attacker:GetActiveWeapon()

        if IsValid(infl) && IsValid(wep) then
            local dmgTbl = ZBaseWeaponDMGs[wep:GetClass()]

            if dmgTbl
            && ( (dmgTbl.inflclass=="bullet"&&dmg:IsBulletDamage()) or (dmgTbl.inflclass == infl:GetClass()) ) then
                local dmgFinal = dmgTbl.dmg

                if dmg:IsDamageType(DMG_BUCKSHOT) then
                    if attacker:WithinDistance(ent, 200) then
                        dmgFinal = math.random(40, 56)
                    elseif attacker:WithinDistance(ent, 400) then
                        dmgFinal = math.random(16, 40)
                    else
                        dmgFinal = math.random(8, 16)
                    end
                end

                dmg:SetDamage(dmgFinal)
            end
        end
        ------------------------------------------------=#

    end
end)
---------------------------------------------------------------------------------------=#
hook.Add("PostEntityTakeDamage", "ZBASE", function( ent, dmg )
    -- Fix NPCs being unkillable in SCHED_NPC_FREEZE
    if ent.IsZBaseNPC && ent:IsCurrentSchedule(SCHED_NPC_FREEZE) && ent:Health() <= 0 && !ent.ZBaseDieFreezeFixDone then
        ent:ClearSchedule()
        ent:TakeDamageInfo(dmg)
        ent.ZBaseDieFreezeFixDone = true
    end
end)
---------------------------------------------------------------------------------------=#
hook.Add("ScaleNPCDamage", "ZBASE", function( npc, hit_gr, dmg )
    if !npc.IsZBaseNPC then return end

    local r = npc:CustomTakeDamage(dmg, hit_gr)
    if r then
        return r
    end

    if npc.HasArmor[hit_gr] then
        local r = npc:HitArmor(dmg, hit_gr)
        if r then
            return r
        end
    end
end)
---------------------------------------------------------------------------------------=#
local SoundIndexes = {}
local ShuffledSoundTables = {}
---------------------------------------------------------------------------------------=#
local function RestartSoundCycle( sndTbl, data )
    SoundIndexes[data.OriginalSoundName] = 1

    local shuffle = table.Copy(sndTbl.sound)
    table.Shuffle(shuffle)
    ShuffledSoundTables[data.OriginalSoundName] = shuffle

    -- print("-----------------", data.OriginalSoundName, "-----------------")
    -- PrintTable(ShuffledSoundTables[data.OriginalSoundName])
    -- print("--------------------------------------------------")
end
---------------------------------------------------------------------------------------=#
hook.Add("EntityEmitSound", "ZBASE", function( data )

    if !IsValid(data.Entity) then return end

    
    if data.Entity.IsZBaseNPC then
        local altered = false


        -- Mute default "engine" voice
        if !ZBase_EmitSoundCall
        && SERVER
        && data.Entity.MuteDefaultVoice
        && (data.SoundName == "invalid.wav" or data.Channel == CHAN_VOICE) then
            return false
        end


            -- Avoid sound repitition --
        local sndTbl = sound.GetProperties(data.OriginalSoundName)

        if sndTbl && istable(sndTbl.sound) && table.Count(sndTbl.sound) > 1 && ZBase_EmitSoundCall then
            if !SoundIndexes[data.OriginalSoundName] then
                RestartSoundCycle(sndTbl, data)
            else
                if SoundIndexes[data.OriginalSoundName] == table.Count(sndTbl.sound) then
                    RestartSoundCycle(sndTbl, data)
                else
                    SoundIndexes[data.OriginalSoundName] = SoundIndexes[data.OriginalSoundName] + 1
                end
            end

            local snds = ShuffledSoundTables[data.OriginalSoundName]
            data.SoundName = snds[SoundIndexes[data.OriginalSoundName]]
            altered = true

            -- print(SoundIndexes[data.OriginalSoundName], data.SoundName)
        end
        -----------------------------------------------=#


        -- "OnEmitSound"
        local r = data.Entity:OnEmitSound(data)
        if isstring(r) then
            data.Entity:EmitSound(r)
            return false
        elseif r == false then
            return false
        end


        if altered then
            return true
        end
    end

end)
---------------------------------------------------------------------------------------=#
hook.Add("AcceptInput", "ZBASE", function( ent, input, activator, caller, value )
    if ent.IsZBaseNPC then
        local r = ent:CustomAcceptInput(input, activator, caller, value)
        if r == true then return true end
    end
end)
---------------------------------------------------------------------------------------------------------------------=#
hook.Add("PlayerInitialSpawn", "ZBASE", function( ply )
    ply.ZBaseFaction = "ally"
end)
---------------------------------------------------------------------------------------------------------------------=#
hook.Add("PlayerDeath", "ZBASE", function( ply, _, attacker )
    if IsValid(attacker) && attacker.IsZBaseNPC then
        attacker:OnKilledEnt( ply )
    end

    TellZBaseNPCsEnemyDied(ply)
end)
---------------------------------------------------------------------------------------------------------------------=#
hook.Add("PlayerSpawnedNPC", "ZBASE", function(ply, ent)
    if ply.ZBaseNPCFactionOverride && ply.ZBaseNPCFactionOverride != "" then
        timer.Simple(0, function()
            if !IsValid(ent) or !IsValid(ply) then return end
            if !ent.IsZBaseNPC then return end

            ent.ZBaseFaction = ply.ZBaseNPCFactionOverride
        end)
    end
end)
---------------------------------------------------------------------------------------------------------------------=#
local function BulletHit( ent, tr, dmginfo, data )
    if IsValid(tr.Entity) && tr.Entity.IsZBaseNPC then
        tr.Entity:OnBulletHit(ent, tr, dmginfo, data)
    end
end
---------------------------------------------------------------------------------------------------------------------=#
ZBaseReflectedBullet = false

hook.Add("EntityFireBullets", "ZBASE", function( ent, data, ... )
    -- "Bullet Hit Hook" --
    local data_backup = data
    if grabbing_bullet_backup_data then return end

    grabbing_bullet_backup_data = true
    hook.Run("EntityFireBullets", ent, data, ...)
    grabbing_bullet_backup_data = false

    data = data_backup

    if !ZBaseReflectedBullet then
        local callback = data.Callback
        data.Callback = function(callback_ent, tr, dmginfo, ...)

            if callback then
                callback(callback_ent, tr, dmginfo, ...)
            end

            BulletHit(callback_ent, tr, dmginfo, data)

        end
    end
    --------------------------------------------------=#


    -- Boost accuracy for some weapons --
    if ent.IsZBaseNPC then
        local wep = ent:GetActiveWeapon()
        local ene = ent:GetEnemy()

        if IsValid(wep) && IsValid(ene) && ZBaseWeaponAccuracyBoost[wep:GetClass()] then
            local sprd = (5 - ent:GetCurrentWeaponProficiency())/ZBaseWeaponAccuracyBoost[wep:GetClass()]
            data.Spread = Vector(sprd, sprd)
            data.Dir = (ene:WorldSpaceCenter() - ent:GetShootPos()):GetNormalized()
        end
    end
    --------------------------------------------------=#

    return true
end)
---------------------------------------------------------------------------------------------------------------------=#
hook.Add("GravGunPunt", "ZBaseNPC", function( ply, ent )
    if ent.IsZBaseNPC && ent.SNPCType == ZBASE_SNPCTYPE_FLY && ent.Fly_GravGunPuntForceMult > 0 then
        local timerName = "ZBaseNPCPuntVel"..ent:EntIndex()
        local totalReps = 10
        local speed = 500*ent.Fly_GravGunPuntForceMult

        timer.Create(timerName, 0.1, totalReps, function()
            if !IsValid(ent) then return end

            local mult = ( speed - ((totalReps-timer.RepsLeft(timerName))/totalReps)*speed )
            ent:SetVelocity(ply:GetAimVector() * mult)
        end)

        return true
    end
end)
---------------------------------------------------------------------------------------------------------------------=#