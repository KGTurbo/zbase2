--[[
======================================================================================================================================================
                                           WELCOME MESSAGE OR SOMETHING IDK
======================================================================================================================================================
--]]


if !ZBaseInitialized then
    print("-- ███████╗██████╗░░█████╗░░██████╗███████╗ --")
    print("-- ╚════██║██╔══██╗██╔══██╗██╔════╝██╔════╝ --")
    print("-- ░░███╔═╝██████╦╝███████║╚█████╗░█████╗░░ --")
    print("-- ██╔══╝░░██╔══██╗██╔══██║░╚═══██╗██╔══╝░░ --")
    print("-- ███████╗██████╦╝██║░░██║██████╔╝███████╗ --")
    print("-- ╚══════╝╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝ --") 
    print("                                     -- █▀▀▄ █──█ 　 ▀▀█ ─▀─ █▀▀█ █▀▀█ █──█ --")
    print("                                     -- █▀▀▄ █▄▄█ 　 ▄▀─ ▀█▀ █──█ █──█ █▄▄█ --")
    print("                                     -- ▀▀▀─ ▄▄▄█ 　 ▀▀▀ ▀▀▀ █▀▀▀ █▀▀▀ ▄▄▄█ --")
end   


--[[
======================================================================================================================================================
                                           DONT BE ON SOME SHIT BRANCH
======================================================================================================================================================
--]]


if BRANCH != "x86-64" && BRANCH != "dev" then
    --]]===================================================================================================================]]
    if SERVER then
        util.AddNetworkString("ZBaseError")

        hook.Add("PlayerInitialSpawn", "ZBase", function( ply )
            timer.Simple(3, function()
                net.Start("ZBaseError")
                net.Send(ply)
            end)
        end)
    end
    --]]===================================================================================================================]]
    if CLIENT then
        net.Receive("ZBaseError", function()
            chat.AddText(Color(255, 0, 0), "[ZBase] Fatal error!")
            chat.AddText(Color(255, 0, 0), "[ZBase] ZBase only works for the 'x86-64' and 'dev' branch of gmod! Current branch: '", BRANCH, "'.")
        end)
    end
    --]]===================================================================================================================]]
    return
end


--[[
======================================================================================================================================================
                                           ZBASE_RELOAD
======================================================================================================================================================
--]]


--]]===================================================================================================================]]
if CLIENT then
    net.Receive("ZBaseReload", function()
        include("autorun/zbase.lua")
    end)
else
    util.AddNetworkString("ZBaseReload")
end
--]]===================================================================================================================]]
concommand.Add("zbase_reload", function( ply )
    if ply:IsSuperAdmin() then
        include("autorun/zbase.lua")
        net.Start("ZBaseReload")
        net.Broadcast()
    end
end)
--]]===================================================================================================================]]


--[[
======================================================================================================================================================
                                           PARTICLES
======================================================================================================================================================
--]]


game.AddParticles("particles/zbase_blood_impact.pcf")
PrecacheParticleSystem("blood_impact_zbase_green")
PrecacheParticleSystem("blood_impact_zbase_black")
PrecacheParticleSystem("blood_impact_zbase_blue")


--[[
======================================================================================================================================================
                                           DECALS
======================================================================================================================================================
--]]


--]]=================================================================================================================]]
if SERVER then
    game.AddDecal("ZBaseBloodBlack", {
        "decals/zbase_blood_black/blood1",
        "decals/zbase_blood_black/blood2",
        "decals/zbase_blood_black/blood3",
        "decals/zbase_blood_black/blood4",
        "decals/zbase_blood_black/blood5",
        "decals/zbase_blood_black/blood6",
    })

    game.AddDecal("ZBaseBloodSynth", {
        "decals/zbase_blood_synth/blood1",
        "decals/zbase_blood_synth/blood2",
        "decals/zbase_blood_synth/blood3",
        "decals/zbase_blood_synth/blood4",
        "decals/zbase_blood_synth/blood5",
        "decals/zbase_blood_synth/blood6",
    })

    game.AddDecal("ZBaseBloodRed", {
        "decals/zbase_blood_red/blood1",
        "decals/zbase_blood_red/blood2",
        "decals/zbase_blood_red/blood3",
        "decals/zbase_blood_red/blood4",
        "decals/zbase_blood_red/blood5",
        "decals/zbase_blood_red/blood6",
    })

    game.AddDecal("ZBaseBloodGreen", {
        "decals/zbase_blood_green/blood1",
        "decals/zbase_blood_green/blood2",
        "decals/zbase_blood_green/blood3",
        "decals/zbase_blood_green/blood4",
        "decals/zbase_blood_green/blood5",
        "decals/zbase_blood_green/blood6",
    })

    game.AddDecal("ZBaseBloodBlue", {
        "decals/zbase_blood_blue/blood1",
        "decals/zbase_blood_blue/blood2",
        "decals/zbase_blood_blue/blood3",
        "decals/zbase_blood_blue/blood4",
        "decals/zbase_blood_blue/blood5",
        "decals/zbase_blood_blue/blood6",
    })
end
--]]=================================================================================================================]]


--[[
======================================================================================================================================================
                                           SOUNDS
======================================================================================================================================================
--]]


--]]=================================================================================================================]]
sound.Add( {
	name = "ZBase.Melee1",
	channel = CHAN_AUTO,
	volume = 0.8,
	level = 75,
	pitch = {95, 105},
	sound = {
        "npc/fast_zombie/claw_strike1.wav",
		"npc/fast_zombie/claw_strike2.wav",
		"npc/fast_zombie/claw_strike3.wav",
    }
} )
--]]=================================================================================================================]]
sound.Add( {
	name = "ZBase.Melee2",
	channel = CHAN_AUTO,
	volume = 0.8,
	level = 75,
	pitch = {95, 105},
	sound = {
        "physics/body/body_medium_impact_hard1.wav",
		"physics/body/body_medium_impact_hard2.wav",
		"physics/body/body_medium_impact_hard3.wav",
        "physics/body/body_medium_impact_hard4.wav",
		"physics/body/body_medium_impact_hard5.wav",
		"physics/body/body_medium_impact_hard6.wav",
    }
} )
--]]=================================================================================================================]]
sound.Add( {
	name = "ZBase.Ricochet",
	channel = CHAN_AUTO,
	volume = 0.8,
	level = 75,
	pitch = {90, 110},
	sound = {
        "weapons/fx/rics/ric1.wav",
        "weapons/fx/rics/ric2.wav",
        "weapons/fx/rics/ric3.wav",
        "weapons/fx/rics/ric4.wav",
        "weapons/fx/rics/ric5.wav"
    }
} )
--]]=================================================================================================================]]


--[[
======================================================================================================================================================
                                           INCLUDES
======================================================================================================================================================
--]]


--]]===================================================================================================================]]
local function IncludeFiles()
    include("zbase/shared/globals.lua")
    include("zbase/shared/hooks.lua")

    if SERVER then
        include("zbase/server/general/hooks.lua")
        include("zbase/server/general/scheds.lua")
        include("zbase/server/general/relationship.lua")

        local files = file.Find("zbase/npc_enhancements/*","LUA")
        local enhPath = "zbase/npc_enhancements/"

        for _, v in ipairs(files) do
            include(enhPath..v)
        end
    end
end
--]]===================================================================================================================]]


--[[
======================================================================================================================================================
                                           REGISTER THE BLOODY NPC BASE
                                           ADD NPCS TO SPAWNMENU
======================================================================================================================================================
--]]


--]]===================================================================================================================]]
local function NPCsInherit()
    for cls, t in pairs(ZBaseNPCs) do
        local ZBase_Inherit = t.Inherit

        if ZBase_Inherit
        && ZBaseNPCs[ZBase_Inherit] then
            for k, v in pairs(ZBaseNPCs[ZBase_Inherit]) do
                if t[k] == nil then 

                    t[k] = istable(v) && table.Copy(v) or v
                end
            end
        end
    
        for k, v in pairs(ZBaseNPCs["npc_zbase"]) do
            if t[k] == nil then
                -- print(cls, "npc_zbase", k, v)
                t[k] = istable(v) && table.Copy(v) or v
            end
        end


        if SERVER then
            local path = "zbase/npcs/"..cls
            local bh = path.."/behaviour.lua"
            if file.Exists(bh, "LUA") then
                include(bh)
            end
        end
    end
end
--]]===================================================================================================================]]
local function RegBase()
    ZBaseNPCs["npc_zbase"] = {}

    local npcpath = "zbase/npcs/npc_zbase/"

    AddCSLuaFile(npcpath.."shared.lua")
    AddCSLuaFile(npcpath.."cl_init.lua")

    if SERVER then
        include("zbase/server/npc_base/core.lua")
        include("zbase/server/npc_base/util.lua")
        include(npcpath.."init.lua")


        ZBaseNPCs["npc_zbase"].Behaviours = {}


        local files = file.Find("zbase/server/npc_base/behaviours/*","LUA")
        local behaviourPath = "zbase/server/npc_base/behaviours/"

        for _, v in ipairs(files) do
            include(behaviourPath..v)
        end


        -- Get names of sound variables
        ZBaseNPCs["npc_zbase"].SoundVarNames = {}
        for k, v in pairs(ZBaseNPCs["npc_zbase"]) do
            if string.EndsWith(k, "Sounds") then
                table.insert(ZBaseNPCs["npc_zbase"].SoundVarNames, k)
            end
        end
    end

    include(npcpath.."shared.lua")

    if CLIENT then
        include(npcpath.."cl_init.lua")
    end
end
--]]===================================================================================================================]]
local function NPCReg( name )
    if string.StartsWith(name, "npc_") && name != "npc_zbase" then
        local path = "zbase/npcs/"..name.."/"
        local sh = path.."shared.lua"
        local cl = path.."cl_init.lua"
        local sv = path.."init.lua"
        local bh = path.."behaviour.lua"

        if file.Exists(sh, "LUA")
        && file.Exists(sv, "LUA") then
            ZBaseNPCs[name] = {}

            include(sh)
            AddCSLuaFile(sh)

            if file.Exists(cl, "LUA") then
                AddCSLuaFile(cl)
            end

            if SERVER then
                include(sv)

                -- if file.Exists(bh, "LUA") then
                --     include(bh)
                -- end
            end

            if file.Exists(cl, "LUA") && CLIENT then
                include(cl)
            end
        end
    end
end
--]]===================================================================================================================]]
local function registerNPCs()
    local _, dirs = file.Find("zbase/npcs/*","LUA")

    RegBase() -- Register base

    -- Register all ZBase NPCs
    for _, v in ipairs(dirs) do
        NPCReg(v)
    end

    -- PrintTable(ZBaseNPCs)
end
--]]===================================================================================================================]]
local function AddNPCsToSpawnMenu()
    for cls, t in pairs( ZBaseNPCs ) do
        local ZBaseSpawnMenuTbl = {
            Name=t.Name,
            Category=t.Category,
            Class = t.Class,
            Weapons = t.Weapons,
            Models = t.Models,
            KeyValues = table.Copy(t.KeyValues),
            OnFloor = t.OnFloor,
            OnCeiling = t.OnCeiling,
            NoDrop = t.NoDrop,
            Offset = t.Offset or (t.SNPCType == ZBASE_SNPCTYPE_FLY && t.Fly_DistanceFromGround),
            Rotate = t.Rotate,
            Skins = t.Skins,
            AdminOnly = t.AdminOnly,
            SpawnFlagTbl = t.SpawnFlagTbl,
            TotalSpawnFlags = t.TotalSpawnFlags,
            OnDuplicated = t.OnDuplicated,
            BodyGroups = BodyGroups,
            StartHealth = t.StartHealth,
        }


        ZBaseSpawnMenuNPCList[cls] = ZBaseSpawnMenuTbl -- Add to zbase menu
    end
end
--]]===================================================================================================================]]
hook.Add("Initialize", "ZBASE", function()
    NPCsInherit()
    AddNPCsToSpawnMenu()
    ZBaseInitialized = true
end)
--]]===================================================================================================================]]


if ZBaseInitialized then
    table.Empty( ZBaseNPCs )
    table.Empty( ZBaseSpawnMenuNPCList )
    
    IncludeFiles()
    registerNPCs()

    NPCsInherit()
    AddNPCsToSpawnMenu()

    MsgN("ZBase Reloaded!")
else

    IncludeFiles()
    registerNPCs()

end


--[[
======================================================================================================================================================
                                           SCHIZOPHRENIA
======================================================================================================================================================
--]]


-- IF YOU ARE READING THIS
-- SHE NEEDS TO BE MY WIFE
-- I CANNOT RAISE THE FIRST BORN CHILD THAT IS ZBASE AS A LONE PARENT
-- ZBASE NEEDS THE MOTHERLY LOVE THAT IT DESERVES