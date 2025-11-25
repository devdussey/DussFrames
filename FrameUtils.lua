-- Frame utility functions for dragging and resizing

DussFrames.FrameUtils = {}

-- Make a frame draggable
function DussFrames.FrameUtils:MakeDraggable(frame, frameName)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    frame:SetScript("OnDragStart", function(self)
        if not self.isLocked then
            self:StartMoving()
        end
    end)

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        DussFrames.Persistence:SaveFramePosition(frameName, self)
    end)

    -- Right-click to toggle lock
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            DussFrames.FrameUtils:ToggleLock(self, frameName)
        end
    end)

    frame.isLocked = DussFrames.Persistence:LoadLockState(frameName)
    frame.frameName = frameName
end

-- Make a frame resizable with a resize handle
function DussFrames.FrameUtils:MakeResizable(frame, minWidth, minHeight)
    minWidth = minWidth or 100
    minHeight = minHeight or 100

    frame:SetResizable(true)
    frame:EnableMouse(true)

    -- Create resize handle (bottom-right corner)
    local resizeHandle = CreateFrame("Frame", nil, frame)
    resizeHandle:SetSize(20, 20)
    resizeHandle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

    -- Make resize handle visible (optional - remove this if you don't want it visible)
    local resizeBG = resizeHandle:CreateTexture(nil, "BACKGROUND")
    resizeBG:SetAllPoints()
    resizeBG:SetColorTexture(0.5, 0.5, 0.5, 0.3)

    -- Create the resize texture (shows resize cursor)
    resizeHandle:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            frame:StartSizing("BOTTOMRIGHT")
        end
    end)

    resizeHandle:SetScript("OnMouseUp", function(self, button)
        frame:StopMovingOrSizing()
    end)

    resizeHandle:SetScript("OnEnter", function(self)
        self:SetAlpha(0.6)
    end)

    resizeHandle:SetScript("OnLeave", function(self)
        self:SetAlpha(0.3)
    end)

    frame.resizeHandle = resizeHandle
end

-- Toggle frame lock state
function DussFrames.FrameUtils:ToggleLock(frame, frameName)
    frame.isLocked = not frame.isLocked
    DussFrames.Persistence:SaveLockState(frameName, frame.isLocked)

    if frame.isLocked then
        print("DussFrames: " .. frameName .. " is now LOCKED")
    else
        print("DussFrames: " .. frameName .. " is now UNLOCKED")
    end
end

print("DussFrames: FrameUtils loaded")
