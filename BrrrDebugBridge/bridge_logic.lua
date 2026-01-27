---
--- BrrrDebugBridge - Main Entry Point
---

-- [BOOT CONTROL]
-- Force skip the intro by overriding the splash_screen function.
-- This bypasses the video/animation stage immediately.
G.SETTINGS.skip_splash = 'Yes'

local original_splash = Game.splash_screen
function Game:splash_screen()
    self:main_menu()
end

-- Success Indicator
sendDebugMessage("!!! BRRR BRIDGE: Intro Bypass Active !!!")