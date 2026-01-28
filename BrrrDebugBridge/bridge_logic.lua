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

-- [COMPONENT] Autopilot Controller (Source-Validated & Profile-Safe)
if config.mode == "auto" then
    local original_main_menu = Game.main_menu
    function Game:main_menu()
        original_main_menu(self)
        
        if G_BRRR_BRIDGE_FIRST_LOAD then
            G_BRRR_BRIDGE_FIRST_LOAD = false
            
            local stability_counter = 0
            
            local function attempt_auto_launch(retries)
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.5,
                    func = function()
                        -- STRESS-TEST: MENU state must be 11, and Profile data must be fully loaded
                        local is_menu = G.STATE == G.STATES.MENU
                        local is_data_ready = G.PROFILES and G.SETTINGS and G.SETTINGS.profile

                        print(string.format("[BRRR_DIAG] State: %s, Comp: %s, Wipe: %s, DataReady: %s", 
                            tostring(G.STATE), tostring(G.STATE_COMPLETE), tostring(G.screenwipe ~= nil), 
                            tostring(G.SETTINGS and G.SETTINGS.profile ~= nil)))

                        -- Logic: Check stability (Grace Period)
                        if is_menu and is_data_ready and (not G.screenwipe) then
                            stability_counter = stability_counter + 1
                            print("[BRRR_BRIDGE] Stability check: " .. stability_counter .. "/10")
                        else
                            stability_counter = 0
                        end

                        if stability_counter >= 10 and G.FUNCS.start_run then
                            print("[BRRR_BRIDGE:LAUNCH] Attempting launch: State Ready")
                            
                            G.FUNCS.start_run(nil, {
                                deck = config.deck or 'b_red',
                                stake = config.stake or 1,
                                seed = config.seed,
                                challenge = config.challenge
                            })
                            return true
                        elseif retries > 0 then
                            print("[BRRR_BRIDGE:RETRY] Waiting for stable MENU and Profile... (" .. retries .. ")")
                            attempt_auto_launch(retries - 1)
                            return true
                        else
                            print("[BRRR_BRIDGE:ERROR] Auto-launch timeout. State: " .. tostring(G.STATE))
                            return true
                        end
                    end
                }))
            end
            attempt_auto_launch(100)
        end
    end
end