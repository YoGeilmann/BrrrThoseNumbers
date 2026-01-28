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

-- [COMPONENT] Refined Splash Screen Override
if config.mode == "auto" or not config.show_intro then
    if Game then
        function Game:splash_screen()
            print("[BRRR_BRIDGE:INTRO] Safe Bypass: Waiting for Main Menu stability...")
            -- We call main_menu directly to bypass the splash screen.
            -- This allows the engine to complete shader initialization cleanly.
            self:main_menu()
        end
    end
end

-- [COMPONENT] Autopilot Controller (Engine-Native Launch)
if config.mode == "auto" then
    local original_main_menu = Game.main_menu
    function Game:main_menu()
        original_main_menu(self)
        
        if G_BRRR_BRIDGE_FIRST_LOAD then
            G_BRRR_BRIDGE_FIRST_LOAD = false
            
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 1.0,
                func = function()
                    -- STRESS-TEST: Only start if the menu is stable
                    if G.STATE == G.STATES.MAIN_MENU and G.FUNCS.start_run then
                        print("[BRRR_BRIDGE:LAUNCH] Executing native start sequence...")
                        
                        -- 1. Simulate UI Cleanup (prevents Black Screen via Layer-Overlay)
                        if G.MAIN_MENU_UI then G.MAIN_MENU_UI:remove() end
                        
                        -- 2. Call Native Start Function
                        G.FUNCS.start_run(nil, {
                            deck = config.deck or 'b_red',
                            stake = config.stake or 1
                        })
                    end
                    return true
                end
            }))
        end
    end
end