function MuddyHeal_Announce(spell, target)
    if not MuddyHeal_Config.announcements then return end
    
    local chan = "PARTY"
    if UnitInRaid("player") then
        chan = "RAID"
    end
    
    if not UnitInParty("player") and not UnitInRaid("player") then return end

    local msg = ""
    if spell == "Rebirth" then
        msg = ">>> Rez'ing " .. target .. " (Rebirth) <<<"
    elseif spell == "Innervate" then
        msg = ">>> Innervate on " .. target .. " <<<"
    elseif spell == "Lay on Hands" then
        msg = ">>> LAY ON HANDS used on " .. target .. " <<<"
    elseif spell == "Power Infusion" then
        msg = ">>> Power Infusion on " .. target .. " <<<"
    end

    if msg ~= "" then
        SendChatMessage(msg, chan)
    end
end