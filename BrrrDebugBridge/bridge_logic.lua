--- GP-2026-STRICT: Bridge Logic - Session-Controller & Autopilot
--- ⚠️ [ASSUMPTION]: Standard Balatro Mod directory structure is used.
--- This script automates the transition from Boot to Run while preventing loops.

local mod_path = "Mods/BrrrDebugBridge/"
local config_path = mod_path .. "config.lua"

-- Initial table state to prevent nil access during load
local config = { 
    show_intro = false, 
    mode = "auto", 
    deck = "b_red", 
    stake = 1 
}

-- [GUARD] Session-Persistence
-- Balatro's Lua environment persists across run-restarts. 
-- We use a global lock to ensure automation only triggers on EXE boot.
if G_BRRR_BRIDGE_FIRST_LOAD == nil then
    G_BRRR_BRIDGE_FIRST_LOAD = true
    print("[BRRR_BRIDGE:INIT] Cold boot detected | Persistence lock initialized")
end

-- [FUNCTION] Safe Config Loader
local function load_bridge_config()
    local chunk, err = loadfile(config_path)
    if chunk then
        local status, data = pcall(chunk)
        if status and type(data) == "table" then 
            -- Merge loaded data into local config table
            for k, v in pairs(data) do config[k] = v end
            print("[BRRR_BRIDGE:CONFIG] Successfully synced from " .. config_path)
        else
            print("[BRRR_BRIDGE:ERROR] Config syntax valid but data corrupt: " .. tostring(data))
        end
    else
        print("[BRRR_BRIDGE:CONFIG] No config file found. Using hardcoded defaults.")
    end
end

-- Execute config load immediately on mod initialization
load_bridge_config()

-- [COMPONENT] Splash Screen Override (Intro Bypass)
-- Hooking into Game:splash_screen to skip the 2-second delay
if not config.show_intro then
    if Game then
        local original_splash = Game.splash_screen
        function Game:splash_screen()
            print("[BRRR_BRIDGE:INTRO] Bypass: Skipping splash_screen")
            -- Immediate transition to main_menu logic
            if self.main_menu then self:main_menu() end
        end
        -- Fallback for native engine flag
        if G and G.SETTINGS then G.SETTINGS.skip_splash = 'Yes' end
    end
end

-- [COMPONENT] Autopilot Controller
-- Hooking into main_menu to trigger automation
if config.mode == "auto" then
    local original_main_menu = Game.main_menu
    function Game:main_menu()
        -- Call original function first to ensure engine state is ready
        original_main_menu(self)
        
        -- Check if autopilot should fire or if we are returning from a run
        if G_BRRR_BRIDGE_FIRST_LOAD then
            print("[BRRR_BRIDGE:AUTO] Condition met: Starting automated run sequence")
            G_BRRR_BRIDGE_FIRST_LOAD = false -- Set lock to prevent re-triggering
            
            -- Use G.E_MANAGER to wait for the next frame (safest injection point)
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    print("[BRRR_BRIDGE:AUTO] API-Call: start_run | Deck: " .. tostring(config.deck))
                    G.FUNCS.start_run(nil, {
                        deck = config.deck or 'b_red',
                        stake = config.stake or 1
                    })
                    return true
                end
            }))
        else
            -- Trace for forensic audit: why didn't the run start?
            print("[BRRR_BRIDGE:AUTO] Suppressed: User returned to menu from active session")
        end
    end
else
    print("[BRRR_BRIDGE:MANUAL] Automation disabled via config flag")
end