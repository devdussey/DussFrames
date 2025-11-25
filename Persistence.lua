-- Persistence system for frame positions and lock state

DussFrames.Persistence = {}

-- Default saved variables
DussFrames.SavedVars = {
    frames = {
        playerFrame = {
            locked = false,
            position = nil,
        },
        targetFrame = {
            locked = false,
            position = nil,
        },
    },
    opacity = {
        frameAlpha = 1.0,
    },
}

-- Initialize persistence system
function DussFrames.Persistence:Init()
    -- Create saved variables if they don't exist
    if not DussFramesSavedVars then
        DussFramesSavedVars = DussFrames.SavedVars
    else
        -- Merge any new keys
        self:MergeSavedVars()
    end
end

-- Merge new keys into existing saved vars
function DussFrames.Persistence:MergeSavedVars()
    if not DussFramesSavedVars.frames then
        DussFramesSavedVars.frames = DussFrames.SavedVars.frames
    end
    if not DussFramesSavedVars.frames.playerFrame then
        DussFramesSavedVars.frames.playerFrame = DussFrames.SavedVars.frames.playerFrame
    end
    if not DussFramesSavedVars.frames.targetFrame then
        DussFramesSavedVars.frames.targetFrame = DussFrames.SavedVars.frames.targetFrame
    end
    if not DussFramesSavedVars.opacity then
        DussFramesSavedVars.opacity = DussFrames.SavedVars.opacity
    end
end

-- Save frame position
function DussFrames.Persistence:SaveFramePosition(frameName, frame)
    if not DussFramesSavedVars.frames[frameName] then
        DussFramesSavedVars.frames[frameName] = {}
    end

    local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
    DussFramesSavedVars.frames[frameName].position = {
        point = point or "CENTER",
        xOffset = xOffset or 0,
        yOffset = yOffset or 0,
    }
end

-- Load frame position
function DussFrames.Persistence:LoadFramePosition(frameName, frame)
    if not DussFramesSavedVars.frames[frameName] or not DussFramesSavedVars.frames[frameName].position then
        return false
    end

    local pos = DussFramesSavedVars.frames[frameName].position
    frame:ClearAllPoints()
    frame:SetPoint(pos.point, UIParent, pos.point, pos.xOffset, pos.yOffset)

    return true
end

-- Save lock state
function DussFrames.Persistence:SaveLockState(frameName, locked)
    if not DussFramesSavedVars.frames[frameName] then
        DussFramesSavedVars.frames[frameName] = {}
    end
    DussFramesSavedVars.frames[frameName].locked = locked
end

-- Load lock state
function DussFrames.Persistence:LoadLockState(frameName)
    if not DussFramesSavedVars.frames[frameName] then
        return false
    end
    return DussFramesSavedVars.frames[frameName].locked
end

-- Get opacity setting
function DussFrames.Persistence:GetOpacity(opacityType)
    if not DussFramesSavedVars.opacity[opacityType] then
        return DussFrames.SavedVars.opacity[opacityType]
    end
    return DussFramesSavedVars.opacity[opacityType]
end

-- Set opacity setting
function DussFrames.Persistence:SetOpacity(opacityType, value)
    if not DussFramesSavedVars.opacity then
        DussFramesSavedVars.opacity = {}
    end
    DussFramesSavedVars.opacity[opacityType] = value
end

print("DussFrames: Persistence loaded")
