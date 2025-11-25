-- Custom Player Frame

function DussFrames:CreatePlayerFrame()
    local playerFrame = CreateFrame("Frame", "DussPlayerFrame", UIParent)
    playerFrame:SetSize(240, 100)
    playerFrame:SetPoint("LEFT", UIParent, "LEFT", 20, 0)

    -- Get class color
    local classColor = DussFrames:GetPlayerClassColor()
    local frameAlpha = DussFrames.Persistence:GetOpacity("frameAlpha")
    playerFrame:SetAlpha(frameAlpha)

    -- Top half: Black background for health section
    local topBg = playerFrame:CreateTexture(nil, "BACKGROUND")
    topBg:SetSize(240, 45)
    topBg:SetPoint("TOPLEFT", playerFrame, "TOPLEFT", 0, 0)
    topBg:SetColorTexture(0, 0, 0, 0.6)  -- Black background
    playerFrame.topBg = topBg

    -- Bottom half: Black background for resource bar
    local bottomBg = playerFrame:CreateTexture(nil, "BACKGROUND")
    bottomBg:SetSize(240, 55)
    bottomBg:SetPoint("BOTTOMLEFT", playerFrame, "BOTTOMLEFT", 0, 0)
    bottomBg:SetColorTexture(0, 0, 0, 0.6)  -- Black background
    playerFrame.bottomBg = bottomBg

    -- Health bar overlay in top section (class colored, showing health %)
    local healthBar = CreateFrame("StatusBar", nil, playerFrame)
    healthBar:SetSize(240, 45)
    healthBar:SetPoint("TOPLEFT", topBg, "TOPLEFT", 0, 0)
    healthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    healthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b, 0.7)
    playerFrame.healthBar = healthBar

    -- Player name text
    local playerNameText = healthBar:CreateFontString(nil, "OVERLAY")
    playerNameText:SetFont("Fonts/FRIZQT__.TTF", 12, "OUTLINE")
    playerNameText:SetPoint("TOP", healthBar, "TOP", 0, -5)
    playerNameText:SetText(UnitName("player"))
    playerNameText:SetTextColor(1, 1, 1, 1)
    playerFrame.playerNameText = playerNameText

    -- Health text (child of healthBar so it appears on top)
    local healthText = healthBar:CreateFontString(nil, "OVERLAY")
    healthText:SetFont("Fonts/FRIZQT__.TTF", 10, "OUTLINE")
    healthText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    healthText:SetText("0 / 0")
    healthText:SetTextColor(1, 1, 1, 1)
    playerFrame.healthText = healthText

    -- Get player's power type to determine resource bar
    local _, class = UnitClass("player")
    local powerType = UnitPowerType("player")
    local powerColor = DussFrames:GetPowerColor(class, powerType)

    -- Resource bar overlay (showing resource %, bound to bottom background)
    local resourceBar = CreateFrame("StatusBar", nil, playerFrame)
    resourceBar:SetSize(240, 55)
    resourceBar:SetPoint("TOPLEFT", bottomBg, "TOPLEFT", 0, 0)
    resourceBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
    resourceBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b, 0.7)

    -- Resource text
    local resourceText = resourceBar:CreateFontString(nil, "OVERLAY")
    resourceText:SetFont("Fonts/FRIZQT__.TTF", 10, "OUTLINE")
    resourceText:SetPoint("CENTER", resourceBar, "CENTER", 0, 0)
    resourceText:SetText("0 / 0")
    resourceText:SetTextColor(1, 1, 1, 1)

    resourceBar.resourceText = resourceText
    resourceBar.powerColor = powerColor  -- Store initial color
    playerFrame.resourceBar = resourceBar
    playerFrame.resourceText = resourceText

    -- Make frame draggable but don't resize (keep it fixed at 240x100)
    DussFrames.FrameUtils:MakeDraggable(playerFrame, "playerFrame")

    -- Load saved position (do this AFTER setting initial position)
    if not DussFrames.Persistence:LoadFramePosition("playerFrame", playerFrame) then
        -- If no saved position exists, save the current default position
        DussFrames.Persistence:SaveFramePosition("playerFrame", playerFrame)
    end

    self.playerFrame = playerFrame
    print("DussFrames: Player frame created")
end
