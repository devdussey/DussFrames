-- Configuration options

DussFrames.Config = {
    -- Resource bar colors (RGB values 0-1)
    colors = {
        playerManaBar = {r = 0, g = 0, b = 1},        -- Blue (default mana color)
        frameBackground = {r = 0, g = 0, b = 0},      -- Black
        frameOpacity = 0.6,                           -- Background opacity
    },

    -- Opacity settings (0-1, where 1 is fully opaque)
    opacity = {
        frameAlpha = 1.0,                             -- Overall frame opacity
    },
}

print("DussFrames: Config loaded")
