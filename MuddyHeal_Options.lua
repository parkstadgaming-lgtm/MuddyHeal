function MuddyHeal_CreateOptions()
    if MuddyHealOptions then return end -- Prevent duplicate creation

    -- Safety check to ensure core settings exist
    if not MuddyHeal_Config and MuddyHeal_OnLoad then 
        MuddyHeal_OnLoad() 
    end

    local panel = CreateFrame("Frame", "MuddyHealOptions", UIParent)
    panel:SetWidth(320)
    panel:SetHeight(450) 
    panel:SetPoint("CENTER", 0, 0)
    
    panel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    
    panel:SetScript("OnDragStart", function() this:StartMoving() end)
    panel:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    
    local t = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    t:SetPoint("TOP", 0, -16)
    t:SetText("MuddyHeal Config")

    local closeBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    closeBtn:SetWidth(80)
    closeBtn:SetHeight(22)
    closeBtn:SetPoint("BOTTOM", 0, 16)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() MuddyHealOptions:Hide() end)

    local function CreateCB(name, label, pos, var)
        local cb = CreateFrame("CheckButton", name, panel, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 16, pos)
        
        -- Bulletproof text creation (bypassing Vanilla templates)
        local cbText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        cbText:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        cbText:SetText(label)
        
        cb:SetScript("OnShow", function() 
            if MuddyHeal_Config then this:SetChecked(MuddyHeal_Config[var]) end
        end)
        cb:SetScript("OnClick", function() 
            if MuddyHeal_Config then MuddyHeal_Config[var] = this:GetChecked() end
            if MuddyHeal_UpdateFrames then MuddyHeal_UpdateFrames() end
        end)
    end

    CreateCB("MH_DebuffCB", "Highlight Debuffs", -40, "showDebuffs")
    CreateCB("MH_SoloCB", "Always Show Self (Solo)", -70, "alwaysShowSelf")
    CreateCB("MH_AnnounceCB", "Raid Announcements", -100, "announcements")
    CreateCB("MH_NamesCB", "Show Names on Bars", -130, "showNames")
    CreateCB("MH_LockCB", "Lock UI (Prevent Dragging)", -160, "locked")

    local spellTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    spellTitle:SetPoint("TOPLEFT", 16, -200)
    spellTitle:SetText("Custom Spell Bindings:")

    local spellHint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    spellHint:SetPoint("TOPLEFT", 16, -220)
    spellHint:SetText("Syntax: Flash of Light(Rank 2) - NO SPACES!")
    spellHint:SetTextColor(1, 1, 0) 

    local function CreateEditBox(name, label, pos, key)
        local labelText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        labelText:SetPoint("TOPLEFT", 20, pos)
        labelText:SetText(label)

        local eb = CreateFrame("EditBox", name, panel, "InputBoxTemplate")
        eb:SetWidth(150)
        eb:SetHeight(20)
        eb:SetPoint("TOPLEFT", 120, pos + 5)
        eb:SetAutoFocus(false)
        
        eb:SetScript("OnShow", function() 
            if MuddyHeal_Config and MuddyHeal_Config.spells then
                this:SetText(MuddyHeal_Config.spells[key] or "") 
            end
        end)
        eb:SetScript("OnTextChanged", function() 
            if MuddyHeal_Config and MuddyHeal_Config.spells then
                MuddyHeal_Config.spells[key] = this:GetText() 
            end
        end)
        eb:SetScript("OnEscapePressed", function() this:ClearFocus() end)
        eb:SetScript("OnEnterPressed", function() this:ClearFocus() end)
    end

    CreateEditBox("MH_LeftSpell", "Left Click:", -240, "LeftButton")
    CreateEditBox("MH_RightSpell", "Right Click:", -270, "RightButton")
    CreateEditBox("MH_MiddleSpell", "Middle Click:", -300, "MiddleButton")

    local scaleSlider = CreateFrame("Slider", "MH_ScaleSlider", panel, "OptionsSliderTemplate")
    scaleSlider:SetWidth(200)
    scaleSlider:SetPoint("TOP", 0, -350)
    scaleSlider:SetMinMaxValues(0.5, 1.5)
    scaleSlider:SetValueStep(0.05)
    
    getglobal(scaleSlider:GetName().."Low"):SetText("50%")
    getglobal(scaleSlider:GetName().."High"):SetText("150%")
    getglobal(scaleSlider:GetName().."Text"):SetText("UI Scale")
    
    scaleSlider:SetScript("OnShow", function() 
        if MuddyHeal_Config then this:SetValue(MuddyHeal_Config.scale or 1.0) end
    end)
    scaleSlider:SetScript("OnValueChanged", function()
        local val = this:GetValue()
        if MuddyHeal_Config then MuddyHeal_Config.scale = val end
        if MuddyHeal_MainFrame then MuddyHeal_MainFrame:SetScale(val) end
    end)

    panel:Hide()
end

-- On-Demand generation trigger
SLASH_MUDDYHEAL1 = "/mh"
SlashCmdList["MUDDYHEAL"] = function() 
    if not MuddyHealOptions then
        MuddyHeal_CreateOptions()
    end
    
    if MuddyHealOptions then
        if MuddyHealOptions:IsVisible() then 
            MuddyHealOptions:Hide() 
        else 
            MuddyHealOptions:Show() 
        end
    end
end