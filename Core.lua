-- DussFrames Addon
-- Core initialization

-- Create namespace
DussFrames = {}
DussFrames.VERSION = "1.0"

-- Event frame (to receive WoW events)
DussFrames.eventFrame = CreateFrame("Frame")

-- Register for startup event
DussFrames.eventFrame:RegisterEvent("PLAYER_LOGIN")

-- Event handler
function DussFrames.eventFrame:OnEvent(event, ...)
    if event == "PLAYER_LOGIN" then
        print("DussFrames: Addon loaded!")

        -- Initialize persistence system
        DussFrames.Persistence:Init()

        -- Debug: Check if saved variables exist
        if DussFramesSavedVars and DussFramesSavedVars.frames then
            if DussFramesSavedVars.frames.playerFrame and DussFramesSavedVars.frames.playerFrame.position then
                print("DussFrames: Found saved player frame position")
            else
                print("DussFrames: No saved player frame position found")
            end
        end

        -- Initialize logger
        DussFrames.Logger:Init()
        DussFrames.Logger:HookErrorHandler()

        -- Initialize options panel
        DussFrames.Options:Init()

        -- Hide default frames by moving them off-screen
        -- Don't unregister events as it breaks Blizzard's internal systems
        PlayerFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", -500, -500)
        PlayerFrame:SetAlpha(0)

        TargetFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 500, -500)
        TargetFrame:SetAlpha(0)

        -- Create our custom frames
        DussFrames:CreatePlayerFrame()
        DussFrames:CreateTargetFrame()

        -- Register for updates
        DussFrames:RegisterUpdateEvents()
    end
end

DussFrames.eventFrame:SetScript("OnEvent", DussFrames.eventFrame.OnEvent)

-- Helper function to format numbers
function DussFrames:FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fk", num / 1000)
    else
        return tostring(num)
    end
end

-- Get player's class color
function DussFrames:GetPlayerClassColor()
    local _, class = UnitClass("player")
    if not class then
        return {r = 0.5, g = 0.5, b = 0.5}  -- Gray fallback
    end

    -- WoW class colors
    local classColors = {
        WARRIOR = {r = 0.78, g = 0.61, b = 0.43},
        PALADIN = {r = 0.96, g = 0.55, b = 0.73},
        HUNTER = {r = 0.67, g = 0.83, b = 0.45},
        ROGUE = {r = 1.0, g = 0.96, b = 0.41},
        PRIEST = {r = 1.0, g = 1.0, b = 1.0},
        DEATHKNIGHT = {r = 0.77, g = 0.12, b = 0.23},
        SHAMAN = {r = 0.0, g = 0.44, b = 0.87},
        MAGE = {r = 0.41, g = 0.8, b = 0.94},
        WARLOCK = {r = 0.58, g = 0.51, b = 0.79},
        MONK = {r = 0.0, g = 1.0, b = 0.59},
        DRUID = {r = 1.0, g = 0.49, b = 0.04},
        DEMONHUNTER = {r = 0.64, g = 0.19, b = 0.79},
        EVOKER = {r = 0.2, g = 0.58, b = 0.9},
    }

    return classColors[class] or {r = 0.5, g = 0.5, b = 0.5}
end

-- Get target health bar color based on unit type
function DussFrames:GetTargetHealthColor()
    if not UnitExists("target") then
        return {r = 0.5, g = 0.5, b = 0.5}  -- Gray for no target
    end

    local isPlayer = UnitIsPlayer("target")
    local isEnemy = UnitCanAttack("player", "target")
    local reaction = UnitReaction("player", "target")

    -- Enemy player = red (class color would be too friendly)
    if isPlayer and isEnemy then
        return {r = 1, g = 0, b = 0}  -- Red for enemy players
    end

    -- Non-enemy player = their class color
    if isPlayer and not isEnemy then
        local _, class = UnitClass("target")
        return DussFrames:GetClassColorForClass(class) or {r = 1, g = 1, b = 1}
    end

    -- NPC enemy = red
    if not isPlayer and isEnemy then
        return {r = 1, g = 0, b = 0}  -- Red for enemy NPCs
    end

    -- Non-enemy NPC = green
    if not isPlayer and not isEnemy then
        return {r = 0, g = 1, b = 0}  -- Green for friendly NPCs
    end

    return {r = 0.5, g = 0.5, b = 0.5}  -- Gray fallback
end

-- Get class color by class name (for target players)
function DussFrames:GetClassColorForClass(class)
    if not class then
        return {r = 0.5, g = 0.5, b = 0.5}
    end

    local classColors = {
        WARRIOR = {r = 0.78, g = 0.61, b = 0.43},
        PALADIN = {r = 0.96, g = 0.55, b = 0.73},
        HUNTER = {r = 0.67, g = 0.83, b = 0.45},
        ROGUE = {r = 1.0, g = 0.96, b = 0.41},
        PRIEST = {r = 1.0, g = 1.0, b = 1.0},
        DEATHKNIGHT = {r = 0.77, g = 0.12, b = 0.23},
        SHAMAN = {r = 0.0, g = 0.44, b = 0.87},
        MAGE = {r = 0.41, g = 0.8, b = 0.94},
        WARLOCK = {r = 0.58, g = 0.51, b = 0.79},
        MONK = {r = 0.0, g = 1.0, b = 0.59},
        DRUID = {r = 1.0, g = 0.49, b = 0.04},
        DEMONHUNTER = {r = 0.64, g = 0.19, b = 0.79},
        EVOKER = {r = 0.2, g = 0.58, b = 0.9},
    }

    return classColors[class] or {r = 0.5, g = 0.5, b = 0.5}
end

-- Get power/resource color based on class and power type
function DussFrames:GetPowerColor(class, powerType)
    -- Power type constants: 0=Mana, 1=Rage, 2=Focus, 3=Energy, 4=Chi, 5=Runes, 6=Runic Power, 7=Soul Shards, 8=Lunar Power, 9=Holy Power, 10=Alternate, 11=Maelstrom, 12=Insanity
    local powerColors = {
        [0] = {r = 0.0, g = 0.44, b = 0.87},        -- Mana (Blue)
        [1] = {r = 1.0, g = 0.23, b = 0.0},         -- Rage (Red)
        [2] = {r = 1.0, g = 0.5, b = 0.25},         -- Focus (Orange)
        [3] = {r = 1.0, g = 1.0, b = 0.0},          -- Energy (Yellow)
        [4] = {r = 0.0, g = 1.0, b = 0.59},         -- Chi (Green)
        [5] = {r = 0.5, g = 0.5, b = 0.5},          -- Runes (Gray)
        [6] = {r = 0.77, g = 0.12, b = 0.23},       -- Runic Power (Dark Red)
        [7] = {r = 0.58, g = 0.51, b = 0.79},       -- Soul Shards (Purple)
        [8] = {r = 0.3, g = 0.52, b = 1.0},         -- Lunar Power (Light Blue)
        [9] = {r = 1.0, g = 0.85, b = 0.0},         -- Holy Power (Gold)
        [10] = {r = 0.64, g = 0.19, b = 0.79},      -- Alternate (DH Green)
        [11] = {r = 0.0, g = 1.0, b = 1.0},         -- Maelstrom (Cyan)
        [12] = {r = 0.7, g = 0.3, b = 1.0},         -- Insanity (Dark Purple)
    }

    return powerColors[powerType] or {r = 0.0, g = 0.44, b = 0.87}  -- Default to mana blue
end

-- Apply visual changes to frames without reload
function DussFrames:ApplyVisualChanges()
    if not self.playerFrame or not self.targetFrame then
        return
    end

    -- Get settings
    local frameAlpha = DussFrames.Persistence:GetOpacity("frameAlpha")
    local bgColor = DussFrames.Persistence:GetColor("frameBackground")
    local bgOpacity = DussFrames.Persistence:GetOpacity("frameBackground")
    local showBg = DussFrames.Persistence:GetAppearance("showBackground")
    local showBorder = DussFrames.Persistence:GetAppearance("showBorder")
    local borderColor = DussFrames.Persistence:GetColor("frameBorder")
    local borderOpacity = DussFrames.Persistence:GetOpacity("frameBorder")
    local showMana = DussFrames.Persistence:GetBarVisibility("showPlayerMana")
    local showHealthText = DussFrames.Persistence:GetBarVisibility("showHealthText")
    local showManaText = DussFrames.Persistence:GetBarVisibility("showManaText")
    local useClassColor = DussFrames.Persistence:GetClassColorSetting("usePlayerClassColor")
    local useClassBorder = DussFrames.Persistence:GetClassColorSetting("usePlayerClassBorder")

    -- Get class color if enabled
    local classColor = useClassColor and DussFrames:GetPlayerClassColor() or borderColor
    local playerBorderColor = useClassBorder and DussFrames:GetPlayerClassColor() or borderColor

    -- Helper function to apply changes
    local function applyToFrame(frame, isManaFrame, usePlayerColor)
        frame:SetAlpha(frameAlpha)

        -- Background
        if frame.bgTexture then
            if showBg then
                frame.bgTexture:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, bgOpacity)
            else
                frame.bgTexture:SetColorTexture(0, 0, 0, 0)
            end
        end

        -- Border - use class color for player frame if enabled
        local bColor = usePlayerColor and playerBorderColor or borderColor
        if frame.borderTop then
            if showBorder then
                frame.borderTop:SetColorTexture(bColor.r, bColor.g, bColor.b, borderOpacity)
                frame.borderTop:Show()
            else
                frame.borderTop:Hide()
            end
        end
        if frame.borderBottom then
            if showBorder then
                frame.borderBottom:SetColorTexture(bColor.r, bColor.g, bColor.b, borderOpacity)
                frame.borderBottom:Show()
            else
                frame.borderBottom:Hide()
            end
        end
        if frame.borderLeft then
            if showBorder then
                frame.borderLeft:SetColorTexture(bColor.r, bColor.g, bColor.b, borderOpacity)
                frame.borderLeft:Show()
            else
                frame.borderLeft:Hide()
            end
        end
        if frame.borderRight then
            if showBorder then
                frame.borderRight:SetColorTexture(bColor.r, bColor.g, bColor.b, borderOpacity)
                frame.borderRight:Show()
            else
                frame.borderRight:Hide()
            end
        end

        -- Health text
        if frame.healthText then
            if showHealthText then
                frame.healthText:Show()
            else
                frame.healthText:Hide()
            end
        end

        -- Mana bar (only for player frame)
        if isManaFrame then
            if frame.manaBar then
                if showMana then
                    frame.manaBar:Show()
                else
                    frame.manaBar:Hide()
                end
            end

            if frame.manaText then
                if showManaText then
                    frame.manaText:Show()
                else
                    frame.manaText:Hide()
                end
            end
        end
    end

    -- Apply to player frame (with class color support)
    applyToFrame(self.playerFrame, true, true)

    -- Apply to target frame (no class color)
    applyToFrame(self.targetFrame, false, false)

    -- Update player frame class color background
    if self.playerFrame and self.playerFrame.topBg then
        local classColor = DussFrames:GetPlayerClassColor()
        self.playerFrame.topBg:SetColorTexture(classColor.r, classColor.g, classColor.b, 0.8)
    end
end

-- Slash command handler
function DussFrames:HandleSlashCommand(msg)
    msg = string.lower(msg):trim()

    if msg == "lock" then
        DussFrames.FrameUtils:ToggleLock(self.playerFrame, "playerFrame")
        DussFrames.FrameUtils:ToggleLock(self.targetFrame, "targetFrame")
    elseif msg == "unlock" then
        if self.playerFrame.isLocked then
            DussFrames.FrameUtils:ToggleLock(self.playerFrame, "playerFrame")
        end
        if self.targetFrame.isLocked then
            DussFrames.FrameUtils:ToggleLock(self.targetFrame, "targetFrame")
        end
    elseif msg == "lock player" then
        DussFrames.FrameUtils:ToggleLock(self.playerFrame, "playerFrame")
    elseif msg == "lock target" then
        DussFrames.FrameUtils:ToggleLock(self.targetFrame, "targetFrame")
    elseif msg == "unlock player" then
        if self.playerFrame.isLocked then
            DussFrames.FrameUtils:ToggleLock(self.playerFrame, "playerFrame")
        end
    elseif msg == "unlock target" then
        if self.targetFrame.isLocked then
            DussFrames.FrameUtils:ToggleLock(self.targetFrame, "targetFrame")
        end
    elseif msg == "status" then
        local playerStatus = self.playerFrame.isLocked and "LOCKED" or "UNLOCKED"
        local targetStatus = self.targetFrame.isLocked and "LOCKED" or "UNLOCKED"
        print("DussFrames Status:")
        print("  Player Frame: " .. playerStatus)
        print("  Target Frame: " .. targetStatus)
    elseif string.find(msg, "^opacity %d+") then
        local opacity = tonumber(string.match(msg, "opacity (%d+)"))
        if opacity and opacity >= 0 and opacity <= 100 then
            local value = opacity / 100
            DussFrames.Persistence:SetOpacity("frameAlpha", value)
            DussFrames:ApplyVisualChanges()
            print("DussFrames: Frame opacity set to " .. opacity .. "%")
        else
            print("DussFrames: Opacity must be between 0 and 100")
        end
    else
        print("DussFrames Commands:")
        print("  /df lock - Lock all frames")
        print("  /df unlock - Unlock all frames")
        print("  /df lock player - Lock player frame only")
        print("  /df lock target - Lock target frame only")
        print("  /df unlock player - Unlock player frame only")
        print("  /df unlock target - Unlock target frame only")
        print("  /df status - Show lock status")
        print("  /df opacity 0-100 - Set frame opacity (0-100%)")
        print("  Right-click frames to toggle lock")
    end
end

-- Register slash commands
SLASH_DUSSFRAMES1 = "/dussframes"
SLASH_DUSSFRAMES2 = "/df"
SlashCmdList["DUSSFRAMES"] = function(msg)
    DussFrames:HandleSlashCommand(msg)
end

print("DussFrames: Core loaded")
