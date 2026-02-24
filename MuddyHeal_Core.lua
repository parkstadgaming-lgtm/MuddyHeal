local frame = CreateFrame("Frame", nil, UIParent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
frame:RegisterEvent("RAID_ROSTER_UPDATE")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_MANA")
frame:RegisterEvent("UNIT_AURA")

local rangeTimer = 0
frame:SetScript("OnUpdate", function()
    rangeTimer = rangeTimer + arg1
    if rangeTimer > 0.5 then
        for i = 1, 5 do
            local f = getglobal("MuddyHeal_Unit_"..i)
            if f and f:IsVisible() and f.unit then
                if UnitIsVisible(f.unit) and CheckInteractDistance(f.unit, 4) then f:SetAlpha(1.0) else f:SetAlpha(0.4) end
            end
        end
        rangeTimer = 0
    end
end)

function MuddyHeal_OnLoad()
    if not MuddyHeal_Config then MuddyHeal_Config = {} end
    if MuddyHeal_Config.locked == nil then MuddyHeal_Config.locked = false end
    if MuddyHeal_Config.scale == nil then MuddyHeal_Config.scale = 1.0 end
    MuddyHeal_MainFrame:SetScale(MuddyHeal_Config.scale)
end

function MuddyHeal_UpdateBarLevels(unit)
    for i = 1, 5 do
        local f = getglobal("MuddyHeal_Unit_"..i)
        if f and f:IsVisible() and f.unit == unit then
            local hpBar, mpBar = getglobal(f:GetName().."_HealthBar"), getglobal(f:GetName().."_ManaBar")
            local hpText, buffText = getglobal(f:GetName().."_HealthText"), getglobal(f:GetName().."_BuffText")
            local currHP, maxHP = UnitHealth(unit), UnitHealthMax(unit)
            if maxHP > 0 then hpBar:SetWidth(math.max((currHP/maxHP)*101, 1)) end
            if UnitManaMax(unit) > 0 then mpBar:SetWidth(math.max((UnitMana(unit)/UnitManaMax(unit))*101, 1)) end
            if currHP < maxHP then
                local pct = math.floor((currHP/maxHP)*100)
                hpText:SetText(pct.."%"); hpText:SetTextColor(pct < 30 and 1 or 1, pct < 30 and 0 or 1, pct < 30 and 0 or 1); hpText:Show()
            else hpText:Hide() end
            local hasBlessing = false
            for j = 1, 32 do
                local b = UnitBuff(unit, j)
                if b and string.find(b, "Blessing") then hasBlessing = true; break end
            end
            if hasBlessing then buffText:Hide() else buffText:SetText("B"); buffText:SetTextColor(1,1,0); buffText:Show() end
            local dispellable = false
            for j = 1, 16 do
                local _, _, dtype = UnitDebuff(unit, j)
                if dtype == "Magic" then f:SetBackdropBorderColor(0.2, 0.6, 1, 1); dispellable = true; break
                elseif dtype == "Poison" then f:SetBackdropBorderColor(0, 0.6, 0, 1); dispellable = true; break
                elseif dtype == "Disease" then f:SetBackdropBorderColor(0.6, 0.4, 0, 1); dispellable = true; break end
            end
            if not dispellable then f:SetBackdropBorderColor(0.2, 0.2, 0.2, 1) end
        end
    end
end

function MuddyHeal_UpdateFrames()
    local units = {}
    if GetNumPartyMembers() == 0 then table.insert(units, "player") end
    for i = 1, GetNumPartyMembers() do table.insert(units, "party"..i) end
    for i = 1, 5 do local f = getglobal("MuddyHeal_Unit_"..i) if f then f:Hide() end end
    for i, unitID in ipairs(units) do
        local f = getglobal("MuddyHeal_Unit_"..i) or CreateFrame("Button", "MuddyHeal_Unit_"..i, MuddyHeal_MainFrame, "MuddyHeal_Unit_Template")
        f:EnableMouse(true); f:SetHitRectInsets(0,0,0,0); f:SetFrameLevel(20); f:ClearAllPoints()
        if i == 1 then f:SetPoint("TOPLEFT", 0, 0) else f:SetPoint("TOPLEFT", getglobal("MuddyHeal_Unit_"..(i-1)), "BOTTOMLEFT", 0, -4) end
        f.unit = unitID; f:Show()
        f:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
        f:SetScript("OnClick", function() if MuddyHeal_CastOnClick then MuddyHeal_CastOnClick(arg1, this.unit) end end)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", function() if not MuddyHeal_Config.locked then MuddyHeal_MainFrame:StartMoving() end end)
        f:SetScript("OnDragStop", function() MuddyHeal_MainFrame:StopMovingOrSizing() end)
        if MuddyHeal_ApplyClassicColors then MuddyHeal_ApplyClassicColors(f, f.unit) end
        getglobal(f:GetName().."_Name"):SetText(UnitName(unitID)); MuddyHeal_UpdateBarLevels(unitID)
    end
end

frame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "MuddyHeal" then MuddyHeal_OnLoad()
    elseif event == "UNIT_HEALTH" or event == "UNIT_MANA" or event == "UNIT_AURA" then MuddyHeal_UpdateBarLevels(arg1)
    else if MuddyHeal_Config then MuddyHeal_UpdateFrames() end end
end)