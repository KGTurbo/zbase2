AddCSLuaFile()

ZBaseCvar_Replace = CreateConVar("zbase_replace", "0", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
ZBaseCvar_HL2WepDMG = CreateConVar("zbase_hl2_wep_damage", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))

if !ZBaseNPCs then
    ZBaseNPCs = {}
    ZBaseNPCInstances = {}
    ZBaseBehaviourTimerFuncs = {}
    ZBase_NonZBaseNPCs = {}
    ZBaseSpawnMenuNPCList = {}
    ZBaseSpeakingSquads = {}
end

if SERVER then
    ZBaseFactionTranslation = {
        [CLASS_COMBINE] = "combine",
        [CLASS_COMBINE_GUNSHIP] = "combine",
        [CLASS_MANHACK] = "combine",
        [CLASS_METROPOLICE] = "combine",
        [CLASS_MILITARY] = "combine",
        [CLASS_SCANNER] = "combine",
        [CLASS_STALKER] = "combine",
        [CLASS_PROTOSNIPER] = "combine",
        [CLASS_COMBINE_HUNTER] = "combine",

        [CLASS_HACKED_ROLLERMINE] = "ally",
        [CLASS_HUMAN_PASSIVE] = "ally",
        [CLASS_VORTIGAUNT] = "ally",
        [CLASS_PLAYER] = "ally",
        [CLASS_PLAYER_ALLY] = "ally",
        [CLASS_PLAYER_ALLY_VITAL] = "ally",
        [CLASS_CITIZEN_PASSIVE] = "ally",
        [CLASS_CITIZEN_REBEL] = "ally",

        [CLASS_BARNACLE] = "xen",
        [CLASS_ALIEN_MILITARY] = "xen",
        [CLASS_ALIEN_MONSTER] = "xen",
        [CLASS_ALIEN_PREDATOR] = "xen",

        [CLASS_MACHINE] = "hecu",
        [CLASS_HUMAN_MILITARY] = "hecu",

        [CLASS_HEADCRAB] = "zombie",
        [CLASS_ZOMBIE] = "zombie",
        [CLASS_ALIEN_PREY] = "zombie",

        [CLASS_ANTLION] = "antlion",

        [CLASS_EARTH_FAUNA] = "neutral",
    }
end


ZBase_EmitSoundCall = false
ZBase_DontSpeakOverThisSound = false
ZBaseComballOwner = NULL

if SERVER then
    util.AddNetworkString("ZBasePlayerFactionSwitch")
    util.AddNetworkString("ZBaseNPCFactionOverrideSwitch")

    -----------------------------------------------------------------------------------------=#
    net.Receive("ZBasePlayerFactionSwitch", function( _, ply )
        local faction = net.ReadString()
        ply.ZBaseFaction = faction
    end)
    -----------------------------------------------------------------------------------------=#
    net.Receive("ZBaseNPCFactionOverrideSwitch", function( _, ply )
        local faction = net.ReadString()
        ply.ZBaseNPCFactionOverride = faction
    end)
    -----------------------------------------------------------------------------------------=#
end
-------------------------------------------------------------------------------------------------------------------------=#
function FindZBaseTable(debuginfo)
    local shortsrc = debuginfo.short_src
    local split = string.Split(shortsrc, "/")
    local name = split[#split-1]
    return ZBaseNPCs[name]
end
-------------------------------------------------------------------------------------------------------------------------=#
function FindZBaseBehaviourTable(debuginfo)
    if SERVER then
        return FindZBaseTable(debuginfo).Behaviours
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
-- List an entity's internal variables
function ZBasePrintInternalVars(ent)
    print("---", ent, "internal vars", "---")
    for k in pairs(ent:GetSaveTable( true )) do
        print(k)
    end
    print("----------------------------------------")
end
-------------------------------------------------------------------------------------------------------------------------=#
-- Quickly adds a soundscript with voice like features
function ZBaseCreateVoiceSounds( name, tbl )
    sound.Add( {
        name = name,
        channel = CHAN_VOICE,
        volume = 0.5,
        level = 90,
        pitch = {95, 105},
        sound = tbl,
    } )
end
---------------------------------------------------------------------------------------------------------------------=#
-- Pretty straight forward if you look at the code
function ZBaseRndTblRange( tbl )
    return math.Rand(tbl[1], tbl[2])
end
---------------------------------------------------------------------------------------------------------------------=#
-- Blood effect from an NPC
local BloodEffects = {
    [BLOOD_COLOR_RED] = "blood_impact_red_01",
    [BLOOD_COLOR_ANTLION] = "blood_impact_antlion_01",
    [BLOOD_COLOR_ANTLION_WORKER] = "blood_impact_antlion_worker_01",
    [BLOOD_COLOR_GREEN] = "blood_impact_green_01",
    [BLOOD_COLOR_ZOMBIE] = "blood_impact_zombie_01",
    [BLOOD_COLOR_YELLOW] = "blood_impact_yellow_01",
}

function ZBaseBleed( ent, pos, ang )
    if !ent.GetBloodColor then return end
    if ent.GetNPCState && ent:GetNPCState()==NPC_STATE_DEAD then return end

    local bloodcol = ent:GetBloodColor()

    if bloodcol==BLOOD_COLOR_MECH then
        local spark = ents.Create("env_spark")
        spark:SetKeyValue("spawnflags", 256)
        spark:SetKeyValue("TrailLength", 1)
        spark:SetKeyValue("Magnitude", 1)
        spark:SetPos(pos)
        spark:SetAngles(-ang)
        spark:Spawn()
        spark:Activate()
        spark:Fire("SparkOnce")
        SafeRemoveEntityDelayed(spark, 0.1)
    else
        local effect = BloodEffects[bloodcol]

        if effect then
            ParticleEffect(effect, pos, ang or AngleRand())
        end
    end
end
---------------------------------------------------------------------------------------------------------------------=#