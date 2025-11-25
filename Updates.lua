-- Event handlers and frame updates

function DussFrames:RegisterUpdateEvents()
    -- Player events
    self.eventFrame:RegisterUnitEvent("UNIT_HEALTH", "player")
    self.eventFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    self.eventFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")

    -- Target events
    self.eventFrame:RegisterUnitEvent("UNIT_HEALTH", "target")
    self.eventFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "target")
    self.eventFrame:RegisterUnitEvent("UNIT_TARGET", "player")

    -- Global target change event
    self.eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

    -- Form change event (for druids shapeshifting)
    self.eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")

    -- Set script to handle events
    self.eventFrame:SetScript("OnEvent", function(self, event, unit)
        DussFrames:OnUnitEvent(event, unit)
    end)

    -- Initial update
    DussFrames:UpdatePlayerFrame()
    DussFrames:UpdateTargetFrame()
end

function DussFrames:OnUnitEvent(event, unit)
    if event == "PLAYER_TARGET_CHANGED" then
        -- Immediately update target frame when target changes
        DussFrames:UpdateTargetFrame()
    elseif event == "UPDATE_SHAPESHIFT_FORM" then
        -- Update player frame when form changes (druid shapeshifting)
        DussFrames:UpdatePlayerFrame()
    elseif unit == "player" then
        DussFrames:UpdatePlayerFrame()
    elseif unit == "target" then
        DussFrames:UpdateTargetFrame()
    end
end

function DussFrames:UpdatePlayerFrame()
    local frame = self.playerFrame
    if not frame then return end

    -- Update health info (values)
    local health = UnitHealth("player")
    local maxHealth = UnitHealthMax("player")

    -- Update player name
    if frame.playerNameText then
        frame.playerNameText:SetText(UnitName("player"))
    end

    -- Update health text
    if frame.healthText then
        frame.healthText:SetText(self:FormatNumber(health) .. " / " .. self:FormatNumber(maxHealth))
    end

    -- Update health bar
    if frame.healthBar then
        frame.healthBar:SetMinMaxValues(0, maxHealth)
        frame.healthBar:SetValue(health)
    end

    -- Update resource bar
    if frame.resourceBar then
        local _, class = UnitClass("player")
        local powerType = UnitPowerType("player")
        local power = UnitPower("player", powerType)
        local maxPower = UnitPowerMax("player", powerType)

        -- Update bar color based on current power type (handles form changes)
        local powerColor = DussFrames:GetPowerColor(class, powerType)
        frame.resourceBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)

        frame.resourceBar:SetMinMaxValues(0, maxPower)
        frame.resourceBar:SetValue(power)

        if frame.resourceText then
            frame.resourceText:SetText(self:FormatNumber(power) .. " / " .. self:FormatNumber(maxPower))
        end
    end
end

function DussFrames:UpdateTargetFrame()
    local frame = self.targetFrame
    if not frame then return end

    if UnitExists("target") then
        -- Target exists - show the frame
        frame:Show()

        local health = UnitHealth("target")
        local maxHealth = UnitHealthMax("target")

        -- Update health bar color based on target type
        local healthColor = DussFrames:GetTargetHealthColor()
        frame.healthBar:SetStatusBarColor(healthColor.r, healthColor.g, healthColor.b, 0.7)

        frame.healthBar:SetMinMaxValues(0, maxHealth)
        frame.healthBar:SetValue(health)
        frame.healthText:SetText(self:FormatNumber(health) .. " / " .. self:FormatNumber(maxHealth))
        frame.targetNameText:SetText(UnitName("target"))

        -- Update mana/resource bar
        if frame.manaBar then
            local powerType = UnitPowerType("target")
            local mana = UnitPower("target", powerType)
            local maxMana = UnitPowerMax("target", powerType)
            frame.manaBar:SetMinMaxValues(0, maxMana)
            frame.manaBar:SetValue(mana)
            if frame.manaText then
                frame.manaText:SetText(self:FormatNumber(mana) .. " / " .. self:FormatNumber(maxMana))
            end
        end
    else
        -- No target - hide the frame
        frame:Hide()
    end
end

print("DussFrames: Updates loaded")
