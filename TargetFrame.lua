-- Custom Target Frame

function DussFrames:CreateTargetFrame()
    local targetFrame = CreateFrame("Frame", "DussTargetFrame", UIParent)
    targetFrame:SetSize(240, 100)
    targetFrame:SetPoint("RIGHT", UIParent, "RIGHT", -20, 0)

    local frameAlpha = DussFrames.Persistence:GetOpacity("frameAlpha")
    targetFrame:SetAlpha(frameAlpha)

    -- Top half: Black background for health section
    local topBg = targetFrame:CreateTexture(nil, "BACKGROUND")
    topBg:SetSize(240, 45)
    topBg:SetPoint("TOPLEFT", targetFrame, "TOPLEFT", 0, 0)
    topBg:SetColorTexture(0, 0, 0, 0.6)  -- Black background
    targetFrame.topBg = topBg

    -- Bottom half: Black background for resource bar
    local bottomBg = targetFrame:CreateTexture(nil, "BACKGROUND")
    bottomBg:SetSize(240, 55)
    bottomBg:SetPoint("BOTTOMLEFT", targetFrame, "BOTTOMLEFT", 0, 0)
    bottomBg:SetColorTexture(0, 0, 0, 0.6)  -- Black background
    targetFrame.bottomBg = bottomBg

    -- Determine target health bar color based on unit type
    local healthBarColor = {r = 0.5, g = 0.5, b = 0.5}  -- Default gray

    -- We'll update the color when target changes
    targetFrame.healthBarColor = healthBarColor

    -- Health bar overlay in top section (color determined by target type)
    local healthBar = CreateFrame("StatusBar", nil, targetFrame)
    healthBar:SetSize(240, 45)
    healthBar:SetPoint("TOPLEFT", topBg, "TOPLEFT", 0, 0)
    healthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    healthBar:SetStatusBarColor(healthBarColor.r, healthBarColor.g, healthBarColor.b, 0.7)
    targetFrame.healthBar = healthBar

    -- Target name text
    local targetNameText = healthBar:CreateFontString(nil, "OVERLAY")
    targetNameText:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    targetNameText:SetPoint("TOP", healthBar, "TOP", 0, -5)
    targetNameText:SetText("No Target")
    targetNameText:SetTextColor(1, 1, 1, 1)
    targetFrame.targetNameText = targetNameText

    -- Health text (child of healthBar so it appears on top)
    local healthText = healthBar:CreateFontString(nil, "OVERLAY")
    healthText:SetFont("Fonts/FRIZQT__.TTF", 10, "OUTLINE")
    healthText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    healthText:SetText("0 / 0")
    healthText:SetTextColor(1, 1, 1, 1)
    targetFrame.healthText = healthText

    -- Mana bar overlay (showing mana %)
    local manaBar = CreateFrame("StatusBar", nil, targetFrame)
    manaBar:SetSize(240, 55)
    manaBar:SetPoint("TOPLEFT", bottomBg, "TOPLEFT", 0, 0)
    manaBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    manaBar:SetStatusBarColor(0, 0.44, 0.87, 0.7)  -- Default mana blue
    targetFrame.manaBar = manaBar

    -- Mana text
    local manaText = manaBar:CreateFontString(nil, "OVERLAY")
    manaText:SetFont("Fonts/FRIZQT__.TTF", 10, "OUTLINE")
    manaText:SetPoint("CENTER", manaBar, "CENTER", 0, 0)
    manaText:SetText("0 / 0")
    manaText:SetTextColor(1, 1, 1, 1)
    targetFrame.manaText = manaText

    -- Make frame draggable but don't resize (keep it fixed at 240x100)
    DussFrames.FrameUtils:MakeDraggable(targetFrame, "targetFrame")

    -- Load saved position (do this AFTER setting initial position)
    if not DussFrames.Persistence:LoadFramePosition("targetFrame", targetFrame) then
        -- If no saved position exists, save the current default position
        DussFrames.Persistence:SaveFramePosition("targetFrame", targetFrame)
    end

    self.targetFrame = targetFrame
    print("DussFrames: Target frame created")
end
