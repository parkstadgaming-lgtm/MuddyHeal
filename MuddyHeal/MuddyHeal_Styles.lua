function MuddyHeal_ApplyClassicColors(f, unit)
    if not UnitExists(unit) then return end
    local _, class = UnitClass(unit)
    local hpBar, mpBar = getglobal(f:GetName().."_HealthBar"), getglobal(f:GetName().."_ManaBar")
    local color = RAID_CLASS_COLORS[class] or {r=1, g=0.5, b=0.7}
    hpBar:SetTexture(color.r, color.g, color.b)
    local pType = UnitPowerType(unit)
    if pType == 0 then mpBar:SetTexture(0, 0.5, 1)
    elseif pType == 1 then mpBar:SetTexture(1, 0, 0)
    else mpBar:SetTexture(1, 1, 0) end
    f:SetBackdropColor(0, 0, 0, 1)
    f:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
end