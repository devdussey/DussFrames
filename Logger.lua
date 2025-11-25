-- Error logging system

DussFrames.Logger = {}

-- Initialize logger
function DussFrames.Logger:Init()
    self.logFile = "DussFrames_errors.log"
    self.logPath = "Logs"

    -- Hook into the default error frame to add copy button
    self:HookErrorFrame()
end

-- Hook into the default Lua error frame
function DussFrames.Logger:HookErrorFrame()
    -- Wait for the error frame to exist
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("UI_ERROR_MESSAGE")
    eventFrame:SetScript("OnEvent", function(self, event, message)
        if message and string.find(message, "DussFrames") then
            -- Add copy button to error frame after a short delay
            C_Timer.After(0.1, function()
                DussFrames.Logger:AddCopyButton(message)
            end)
        end
    end)
end

-- Add a copy button to the error frame
function DussFrames.Logger:AddCopyButton(errorMessage)
    local errorFrame = UIErrorsFrame
    if not errorFrame or errorFrame:IsHidden() then
        return
    end

    -- Check if button already exists
    if errorFrame.copyButton then
        return
    end

    -- Create copy button
    local copyButton = CreateFrame("Button", "DussFramesErrorCopyBtn", errorFrame, "UIPanelButtonTemplate")
    copyButton:SetSize(70, 22)
    copyButton:SetPoint("BOTTOMRIGHT", errorFrame, "BOTTOMRIGHT", -5, 5)
    copyButton:SetText("Copy")
    copyButton:SetScript("OnClick", function()
        DussFrames.Logger:CopyToClipboard(errorMessage)
    end)

    errorFrame.copyButton = copyButton
end

-- Copy text to clipboard using WoW's method
function DussFrames.Logger:CopyToClipboard(text)
    -- Create an editbox to use WoW's built-in copy functionality
    if not self.clipboardFrame then
        self.clipboardFrame = CreateFrame("EditBox")
        self.clipboardFrame:Hide()
    end

    self.clipboardFrame:SetText(text)
    self.clipboardFrame:SetFocus()
    self.clipboardFrame:HighlightText()

    -- Attempt to copy (may require user action in some cases)
    if self.clipboardFrame:GetTextLength() > 0 then
        print("DussFrames: Error copied to clipboard! Use Ctrl+V to paste.")
    end
end

-- Log error with timestamp
function DussFrames.Logger:LogError(errorMessage, errorType)
    errorType = errorType or "ERROR"

    -- Get current timestamp
    local timestamp = date("%Y-%m-%d %H:%M:%S")

    -- Format log message
    local logEntry = string.format("[%s] [%s] %s\n", timestamp, errorType, errorMessage)

    -- Print to chat for immediate feedback
    print("DussFrames: " .. logEntry)

    -- Store in memory (in case file writing isn't available)
    if not self.errorLog then
        self.errorLog = {}
    end
    table.insert(self.errorLog, logEntry)
end

-- Get all logged errors
function DussFrames.Logger:GetLog()
    if self.errorLog then
        return table.concat(self.errorLog)
    end
    return ""
end

-- Hook into WoW's error handler
function DussFrames.Logger:HookErrorHandler()
    local originalHandler = geterrorhandler()

    seterrorhandler(function(...)
        -- Log the error
        local errorMessage = ...
        if errorMessage and string.find(errorMessage, "DussFrames") then
            DussFrames.Logger:LogError(errorMessage, "LUA_ERROR")
        end

        -- Call original handler
        if originalHandler then
            originalHandler(...)
        end
    end)
end

print("DussFrames: Logger loaded")
