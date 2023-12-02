local my_cls = ZBaseEnhancementNPCClass(debug.getinfo(1,'S'))
ZBaseEnhancementTable[my_cls] = function( NPC )
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedInit()
        local MyModel = table.Random(self.NPCTable.Models)
        if MyModel then
            self:SetModel(MyModel)
        end

        self:SetAllowedEScheds({
            "SCHED_HUNTER_RANGE_ATTACK2",
            "SCHED_HUNTER_CHASE_ENEMY",
            "SCHED_HUNTER_CHARGE_ENEMY",
            "SCHED_HUNTER_MELEE_ATTACK1",
            "SCHED_HUNTER_STAGGER",
            "SCHED_HUNTER_COMBAT_FACE",
            "SCHED_HUNTER_FLANK_ENEMY",
            "SCHED_HUNTER_PATROL",
            "SCHED_HUNTER_PATROL_RUN",
        })
    end
    --]]============================================================================================================]]
    function NPC:ZBaseEnhancedThink()
    end
    --]]============================================================================================================]]
end