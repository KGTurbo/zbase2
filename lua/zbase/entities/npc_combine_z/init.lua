local NPC = FindZBaseTable(debug.getinfo(1,'S'))


NPC.WeaponProficiency = WEAPON_PROFICIENCY_VERY_GOOD -- WEAPON_PROFICIENCY_POOR || WEAPON_PROFICIENCY_AVERAGE || WEAPON_PROFICIENCY_GOOD
-- || WEAPON_PROFICIENCY_VERY_GOOD || WEAPON_PROFICIENCY_PERFECT


NPC.StartHealth = 50 -- Max health
NPC.CanPatrol = true -- Use base patrol behaviour


NPC.ZBaseStartFaction = "combine" -- Any string, all ZBase NPCs with this faction will be allied


NPC.HasArmor = {
    [HITGROUP_GENERIC] = true,
    [HITGROUP_CHEST] = true,
    [HITGROUP_STOMACH] = true,
}


NPC.m_nKickDamage = 15


--]]==============================================================================================]]
function NPC:CustomInitialize()
end
--]]==============================================================================================]]

    -- Return a new sound name to play that sound instead.
    -- Return false to prevent the sound from playing.
function NPC:CustomOnEmitSound( sndData, sndVarName )
end
--]]==============================================================================================]]