function MuddyHeal_CastOnClick(button, unit)
    local clickButton = button or arg1
    if not unit or not MuddyHeal_Config or not MuddyHeal_Config.spells then return end
    local spellName = MuddyHeal_Config.spells[clickButton]
    if not spellName or spellName == "" then TargetUnit(unit) return end

    if UnitExists(unit) then
        local hadTarget = UnitExists("target")
        TargetUnit(unit)
        local missingHP = UnitHealthMax(unit) - UnitHealth(unit)
        local finalSpell = spellName
        if spellName == "Flash of Light" then
            if missingHP < 200 then finalSpell = "Flash of Light(Rank 1)"
            elseif missingHP < 400 then finalSpell = "Flash of Light(Rank 3)"
            else finalSpell = "Flash of Light" end 
        elseif spellName == "Holy Light" then
            if missingHP < 600 then finalSpell = "Holy Light(Rank 4)"
            else finalSpell = "Holy Light" end
        end
        CastSpellByName(finalSpell)
        if hadTarget then TargetLastTarget() else ClearTarget() end
    end
end