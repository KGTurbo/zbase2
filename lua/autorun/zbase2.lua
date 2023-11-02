-------------------------------------------------------------------------------------------------------------------------=#
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
-------------------------------------------------------------------------------------------------------------------------=#


        -- TODO --
    -- More basic variables and functions, use VJ Base as an example

    -- Sound variation system broken? fix

    -- Easy sound creating system
    
    -- Fix dumbass seach bar

    -- More sounds
        -- LostEnemySounds
        -- ReloadSounds
        -- SeeDangerSounds
        -- HearDangerSounds
        -- AllyDeathSounds

    -- Ministrider
        -- Based on hunter
        -- Armor that deflects bullets

    -- Mortar synth
        -- Based on scanner
        -- Base range attack system

    -- Crab synth SNPC
        -- Armor that deflects bullets
        -- Uses custom schedule system

    -- Crabless zombies (just called zombies, normal zombies will be called headcrab zombies)

    -- Custom blood system
        --White blood decals for hunters

    -- Any kind of general npc improvement
        -- Extended jumping
        -- Hearing system

    -- Aerial base
        -- Ground node navigation system

    -- Controller

    -- Player base

        -- Finally --
    -- Make sure all NPCs have their full potential
    -- Make more user friendly with comments and shit, dummy git
    -- Make sure everything works

-------------------------------------------------------------------------------------------------------------------------=#

if BRANCH != "x86-64" && BRANCH != "dev" then
    -------------------------------------------------------------------------------------------------------------------------=#
    if SERVER then
        util.AddNetworkString("ZBaseError")

        hook.Add("PlayerInitialSpawn", "ZBase", function( ply )
            timer.Simple(3, function()
                net.Start("ZBaseError")
                net.Send(ply)
            end)
        end)
    end
    -------------------------------------------------------------------------------------------------------------------------=#
    if CLIENT then
        net.Receive("ZBaseError", function()
            chat.AddText(Color(255, 0, 0), "[ZBase] Fatal error!")
            chat.AddText(Color(255, 0, 0), "[ZBase] ZBase only works for the 'x86-64' and 'dev' branch of gmod! Current branch: '", BRANCH, "'.")
        end)
    end
    -------------------------------------------------------------------------------------------------------------------------=#
    return
end

-------------------------------------------------------------------------------------------------------------------------=#
local function IncludeFiles()
    AddCSLuaFile("zbase/client/hooks.lua")
    AddCSLuaFile("zbase/client/spawnmenu.lua")
    AddCSLuaFile("zbase/client/toolmenu.lua")

    include("zbase/shared/globals.lua")
    include("zbase/shared/sh_replace_funcs.lua")
    include("zbase/shared/sh_hooks.lua")

    if SERVER then
        include("zbase/server/behaviour.lua")
        include("zbase/server/hooks.lua")
    end

    if CLIENT then
        include("zbase/client/hooks.lua")
        include("zbase/client/pawnmenu.lua")
        include("zbase/client/toolmenu.lua")
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
local function NPCsInherit()
    for cls, t in pairs(ZBaseNPCs) do
        local ZBase_Inherit = t.Inherit

        if ZBase_Inherit
        && ZBaseNPCs[ZBase_Inherit] then
            for k, v in pairs(ZBaseNPCs[ZBase_Inherit]) do
                if t[k] == nil then 
                    -- print(cls, "ZBase_Inherit", k, v)
                    t[k] = v
                end
            end
        end
    
        for k, v in pairs(ZBaseNPCs["npc_zbase"]) do
            if t[k] == nil then
                -- print(cls, "npc_zbase", k, v)
                t[k] = v
            end
        end

        if SERVER then
            local path = "zbase_npcs/"..cls
            local bh = path.."/behaviour.lua"
            if file.Exists(bh, "LUA") then
                include(bh)
            end
        end
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
local function RegBase()


end
-------------------------------------------------------------------------------------------------------------------------=#

local function NPCReg( name, path )
    if string.StartsWith(name, "npc_") then

        local path = path or ("zbase_npcs/"..name)
        local sh = path.."/shared.lua"
        local cl = path.."/cl_init.lua"
        local sv = path.."/init.lua"


        if file.Exists(sh, "LUA")
        && file.Exists(sv, "LUA") then
            include(sh)
            AddCSLuaFile(sh)

            if file.Exists(cl, "LUA") then
                AddCSLuaFile(cl)
            end

            if SERVER then
                include(sv)
            end

            if file.Exists(cl, "LUA") && CLIENT then
                include(cl)
            end
        end
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
local function registerNPCs()
    local _, dirs = file.Find("zbase_npcs/*","LUA")

    RegBase() -- Register base

    -- Register all ZBase NPCs
    for _, v in ipairs(dirs) do
        NPCReg(v)
    end
end
-------------------------------------------------------------------------------------------------------------------------=#
local function AddNPCsToSpawnMenu()
    for cls, t in pairs( ZBaseNPCs ) do

        local ZBaseSpawnMenuTbl = {
            Name=t.Name,
            Category=t.Category,
            Class = t.Class,
            Weapons = t.Weapons,
            KeyValues = table.Copy(t.KeyValues),
        }
        if SERVER then
            if !ZBaseSpawnMenuTbl.KeyValues then ZBaseSpawnMenuTbl.KeyValues = {} end
            ZBaseSpawnMenuTbl.KeyValues.parentname = "zbase_"..cls
            ZBaseSpawnMenuTbl.KeyValues.spawnflags = bit.bor(ZBaseSpawnMenuTbl.KeyValues.spawnflags or 0, 256) -- Long Visibility/Shoot
        end

        ZBaseSpawnMenuNPCList[cls] = ZBaseSpawnMenuTbl -- Add to zbase menu

         -- Add to regular spawn menu
        local SpawnMenuTable = table.Copy(ZBaseSpawnMenuTbl)
        SpawnMenuTable.Category = "ZBase - "..ZBaseSpawnMenuTbl.Category

        if !file.Exists( "materials/entities/" .. cls .. ".png", "GAME" ) then
            SpawnMenuTable.IconOverride = "entities/zbase.png"
        end

        list.Set("NPC", cls, SpawnMenuTable)
        ----------------------------------------------------------=#

        local replaceTargetTbl = list.Get("NPC")[t.Replace]
        if ZBaseCvar_Replace:GetBool() && t.Replace && replaceTargetTbl then
            -- Replace default spawn menu npcs

            local replaceTable = table.Copy(SpawnMenuTable)
            replaceTable.Category = replaceTargetTbl.Category
            replaceTable.Name = "[ZBase] "..replaceTable.Name

            -- Replace image if available (otherwise it will just use monke)
            if file.Exists( "materials/entities/" .. cls .. ".png", "GAME" ) then
                replaceTable.IconOverride = "materials/entities/" .. cls .. ".png"
            end
    
            list.Set( "NPC", t.Replace, replaceTable )
        end

    end
end
-------------------------------------------------------------------------------------------------------------------------=#
hook.Add("Initialize", "ZBASE", function()
    NPCsInherit()
    AddNPCsToSpawnMenu()
    ZBaseInitialized = true
end)
-------------------------------------------------------------------------------------------------------------------------=#

IncludeFiles()
registerNPCs()

if ZBaseInitialized then
    NPCsInherit()
    AddNPCsToSpawnMenu()
end