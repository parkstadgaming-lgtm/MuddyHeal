function MuddyHeal_CastOnClick(button, unit)
    local spell = MuddyHeal_Config.spells[button]

    if spell and spell ~= "" then 
        -- Approach A: Target and Cast (No immediate swap back to prevent server drops)
        TargetUnit(unit)
        CastSpellByName(spell)

        if MuddyHeal_Announce then
            MuddyHeal_Announce(spell, UnitName(unit))
        end
    end
end