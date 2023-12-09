------------------------------------------------------------------------------------------=#
local function ZBaseAddMenuCategory( name, func )
    spawnmenu.AddToolMenuOption("Options", "ZBase", name, name, "", "", function(panel)
        panel:ControlHelp("")
        panel:ControlHelp("-- ███████╗██████╗░░█████╗░░██████╗███████╗ --")
        panel:ControlHelp("-- ╚════██║██╔══██╗██╔══██╗██╔════╝██╔════╝ --")
        panel:ControlHelp("-- ░░███╔═╝██████╦╝███████║╚█████╗░█████╗░░ --")
        panel:ControlHelp("-- ██╔══╝░░██╔══██╗██╔══██║░╚═══██╗██╔══╝░░ --")
        panel:ControlHelp("-- ███████╗██████╦╝██║░░██║██████╔╝███████╗ --")
        panel:ControlHelp("-- ╚══════╝╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝ --")
        panel:ControlHelp("")
        panel:ControlHelp("                                     -- █▀▀▄ █──█ 　 ▀▀█ ─▀─ █▀▀█ █▀▀█ █──█ --")
        panel:ControlHelp("                                     -- █▀▀▄ █▄▄█ 　 ▄▀─ ▀█▀ █──█ █──█ █▄▄█ --")
        panel:ControlHelp("                                     -- ▀▀▀─ ▄▄▄█ 　 ▀▀▀ ▀▀▀ █▀▀▀ █▀▀▀ ▄▄▄█ --")
        panel:ControlHelp("")
        panel:ControlHelp("-- "..string.upper(name).." --")
        func(panel)
    end)
end
------------------------------------------------------------------------------------------=#
hook.Add("PopulateToolMenu", "ZBASE", function()


    ZBaseAddMenuCategory("General", function( panel )
        panel:CheckBox("Glowing Eyes (Server)", "zbase_sv_glowing_eyes")
        panel:Help("Give NPCs glowing eyes on spawn if the NPC's model has any.")

        panel:CheckBox("Glowing Eyes (Client)", "zbase_glowing_eyes")
        panel:Help("Render glowing eyes if any are available.")
    end)


    ZBaseAddMenuCategory("Weapons", function( panel )
        panel:CheckBox("NPC Full HL2 Weapon Damage", "zbase_full_hl2_wep_damage_npc")
        panel:Help("Should NPCs deal the same amount of damage with HL2 weapons towards NPCs?")

        panel:CheckBox("Player Full HL2 Weapon Damage", "zbase_full_hl2_wep_damage_ply")
        panel:Help("Should NPCs deal the same amount of damage with HL2 weapons towards players?")
    end)


    ZBaseAddMenuCategory("NPCs", function( panel )
        panel:NumSlider( "Health Multiplier", "zbase_hp_mult", 0, 20, 2 )
        panel:Help("Multiply ZBase NPCs' health by this number.")
        panel:NumSlider( "Damage Multiplier", "zbase_dmg_mult", 0, 20, 2 )
        panel:Help("Multiply ZBase NPCs' damage by this number.")


        panel:CheckBox("Zombie Headcrabs", "zbase_zombie_headcrabs")
        panel:Help("Should the default ZBase zombies spawn with headcrabs?")
        panel:CheckBox("Zombie Red Blood", "zbase_zombie_red_blood")
        panel:Help("Should the default ZBase zombies spawn with red blood?")
    end)


    ZBaseAddMenuCategory("Aftermath", function( panel )
        panel:NumSlider( "Ragdoll Remove Time", "zbase_rag_remove_time", 0, 600, 1 )
        panel:Help("Time until ragdolls are removed, 0 = never. If keep corpses is enabled, this is ignored.")
        panel:NumSlider( "Max Ragdolls", "zbase_rag_max", 1, 200, 0 )
        panel:Help("Max ragdolls, if there is one too many, the oldest ragdoll will be removed. If keep corpses is enabled, this is ignored.")

        panel:NumSlider( "Gib Remove Time", "zbase_gib_remove_time", 0, 600, 1 )
        panel:Help("Time until gibs are removed, 0 = never. Not affected by keep corpses.")
        panel:NumSlider( "Max Gibs", "zbase_gib_max", 1, 200, 0 )
        panel:Help("Max gibs, if there is one too many, the oldest gib will be removed. Not affected by keep corpses.")
    end)


end)
------------------------------------------------------------------------------------------=#
