-- Options Panel for DussFrames

DussFrames.Options = {}

function DussFrames.Options:CreatePanel()
    local panel = CreateFrame("Frame", "DussFramesOptionsPanel", InterfaceOptionsFramePanelContainer)
    panel.name = "Duss Frames"
    panel:SetSize(600, 400)

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    title:SetText("Duss Frames Options")

    -- Player Frame Section
    local playerTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    playerTitle:SetPoint("TOPLEFT", 20, -60)
    playerTitle:SetText("Player Frame")

    -- Lock Player Frame Checkbox
    local lockPlayerCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    lockPlayerCheck:SetPoint("TOPLEFT", 40, -90)
    lockPlayerCheck:SetChecked(DussFrames.playerFrame and DussFrames.playerFrame.isLocked or false)
    lockPlayerCheck.label = lockPlayerCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lockPlayerCheck.label:SetPoint("LEFT", lockPlayerCheck, "RIGHT", 5, 0)
    lockPlayerCheck.label:SetText("Lock Player Frame")
    lockPlayerCheck:SetScript("OnClick", function(self)
        if self:GetChecked() then
            if not DussFrames.playerFrame.isLocked then
                DussFrames.FrameUtils:ToggleLock(DussFrames.playerFrame, "playerFrame")
            end
        else
            if DussFrames.playerFrame.isLocked then
                DussFrames.FrameUtils:ToggleLock(DussFrames.playerFrame, "playerFrame")
            end
        end
    end)

    -- Target Frame Section
    local targetTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    targetTitle:SetPoint("TOPLEFT", 20, -130)
    targetTitle:SetText("Target Frame")

    -- Lock Target Frame Checkbox
    local lockTargetCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    lockTargetCheck:SetPoint("TOPLEFT", 40, -160)
    lockTargetCheck:SetChecked(DussFrames.targetFrame and DussFrames.targetFrame.isLocked or false)
    lockTargetCheck.label = lockTargetCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lockTargetCheck.label:SetPoint("LEFT", lockTargetCheck, "RIGHT", 5, 0)
    lockTargetCheck.label:SetText("Lock Target Frame")
    lockTargetCheck:SetScript("OnClick", function(self)
        if self:GetChecked() then
            if not DussFrames.targetFrame.isLocked then
                DussFrames.FrameUtils:ToggleLock(DussFrames.targetFrame, "targetFrame")
            end
        else
            if DussFrames.targetFrame.isLocked then
                DussFrames.FrameUtils:ToggleLock(DussFrames.targetFrame, "targetFrame")
            end
        end
    end)

    -- Frame Opacity Section
    local opacityTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    opacityTitle:SetPoint("TOPLEFT", 20, -210)
    opacityTitle:SetText("Frame Opacity")

    -- Opacity Slider
    local opacitySlider = CreateFrame("Slider", nil, panel)
    opacitySlider:SetPoint("TOPLEFT", 40, -245)
    opacitySlider:SetSize(300, 20)
    opacitySlider:SetMinMaxValues(0, 100)
    opacitySlider:SetValueStep(1)
    opacitySlider:SetValue(DussFrames.Persistence:GetOpacity("frameAlpha") * 100)

    -- Slider texture
    opacitySlider:SetThumbTexture("Interface\\Buttons\\UI-SliderControls-Button-Horizontal")
    local bg = opacitySlider:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)

    -- Label
    local opacityLabel = opacitySlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    opacityLabel:SetPoint("LEFT", opacitySlider, "LEFT", 0, 20)
    opacityLabel:SetText("Opacity")

    -- Value display
    local opacityValue = opacitySlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    opacityValue:SetPoint("RIGHT", opacitySlider, "RIGHT", 0, 0)
    opacityValue:SetText("100%")

    opacitySlider:SetScript("OnValueChanged", function(self, value)
        value = value / 100
        DussFrames.Persistence:SetOpacity("frameAlpha", value)
        opacityValue:SetText(string.format("%.0f%%", self:GetValue()))
        if DussFrames.playerFrame then
            DussFrames.playerFrame:SetAlpha(value)
        end
        if DussFrames.targetFrame then
            DussFrames.targetFrame:SetAlpha(value)
        end
    end)

    -- Help Text
    local helpText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    helpText:SetPoint("TOPLEFT", 20, -300)
    helpText:SetText("Right-click frames to toggle lock | Use /df for slash commands")
    helpText:SetTextColor(0.7, 0.7, 0.7)

    return panel
end

-- Initialize the panel when the addon loads
function DussFrames.Options:Init()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", function(self, event, addonName)
        if addonName == "DussFrames" then
            local panel = DussFrames.Options:CreatePanel()
            if InterfaceOptions_AddCategory then
                InterfaceOptions_AddCategory(panel)
            end
            self:UnregisterEvent("ADDON_LOADED")
        end
    end)
end

print("DussFrames: Options loaded")
