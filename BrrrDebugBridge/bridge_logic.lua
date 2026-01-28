--- GP-2026-STRICT: Bridge Logic - Session-Controller & Autopilot
--- ⚠️ [ASSUMPTION]: Standard Balatro Mod directory structure is used.
--- This script automates the transition from Boot to Run while preventing loops.

local mod_path = "Mods/BrrrDebugBridge/"
local config_path = mod_path .. "config.lua"
local launched = false

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

-- [COMPONENT] Autopilot Controller (Source-Validated & Profile-Safe)
if config.mode == "auto" then
    local old_update = Game.update
    function Game:update(dt)
        if old_update then old_update(self, dt) end

        -- Nuclear Guard: Prevent UI crashes if settings are corrupt
        if G.SETTINGS and G.SETTINGS.GAMESPEED == nil then
            print("[BRRR_LOG:CRITICAL] G.SETTINGS.GAMESPEED was nil! Forcing to 1.")
            G.SETTINGS.GAMESPEED = 1
        end

        -- Trigger only once per session (Cold Boot)
        if G_BRRR_BRIDGE_FIRST_LOAD and not launched then
            -- Condition: Menu State (11) and Data Ready
            if G.STATE == G.STATES.MENU and G.P_CENTERS and G.P_CENTERS.j_joker then
                launched = true
                G_BRRR_BRIDGE_FIRST_LOAD = false -- Consume the lock

                print("[BRRR_LOG:ATOMIC] Triggering Atomic Launch Sequence...")

                -- A. Capture User Speed (Robust)
                local user_speed = (G.SETTINGS and G.SETTINGS.GAMESPEED) or 1
                print("[BRRR_LOG:SPEED] Initial User Speed: " .. tostring(user_speed))

                -- B. Warp Speed
                G.SETTINGS.GAMESPEED = 100
                print("[BRRR_LOG:SPEED] Warp Speed Engaged: " .. tostring(G.SETTINGS.GAMESPEED))

                -- Force immediate update for internal engine references
                if G.SPEEDFACTOR then G.SPEEDFACTOR = 100 end
                G:save_settings()
                
                -- C. UI Cleanup
                if G.MAIN_MENU_UI then G.MAIN_MENU_UI:remove(); G.MAIN_MENU_UI = nil end

                -- D. Start Run
                G.FUNCS.start_run(nil, {
                    deck = config.deck or 'b_red',
                    stake = config.stake or 1,
                    seed = config.seed,
                    challenge = config.challenge
                })

                -- E. State Fix
                G.STATE_COMPLETE = true

                -- F. Restore Speed
                G.SETTINGS.GAMESPEED = user_speed
                if G.SPEEDFACTOR then G.SPEEDFACTOR = user_speed end
                print("[BRRR_LOG:SPEED] Speed Restored: " .. tostring(G.SETTINGS.GAMESPEED))
                
                -- Persist settings to avoid UI desync
                if G.save_settings then G:save_settings() end
                
                print("[BRRR_LOG:ATOMIC] Sequence Complete.")
            end
        end
    end
end