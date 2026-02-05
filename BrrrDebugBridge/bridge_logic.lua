-- GP-2026-STRICT: Bridge Logic (v27.5)
-- Session-Controller & Autopilot with Final Async Guard

local mod_path = "Mods/BrrrDebugBridge/"
local config_path = mod_path .. "config.lua"
local launched = false
local frame_delay = 0
local config = { show_intro = false, mode = "auto", deck = "b_red", stake = 1 }

if G_BRRR_BRIDGE_FIRST_LOAD == nil then
    G_BRRR_BRIDGE_FIRST_LOAD = true
    print("[BRRR:INIT] Cold boot detected")
end

local function load_config()
    local chunk = loadfile(config_path)
    if chunk then
        local status, data = pcall(chunk)
        if status and type(data) == "table" then
            for k, v in pairs(data) do config[k] = v end
            print("[BRRR:CONFIG] Synced")
        end
    end
end
load_config()

if config.mode == "auto" or not config.show_intro then
    if Game then
        function Game:splash_screen()
            self:main_menu()
        end
    end
end

if config.mode == "auto" then
    local old_update = Game.update
    function Game:update(dt)
        if old_update then old_update(self, dt) end

        -- Guard: Prevent UI crashes
        if G.SETTINGS and G.SETTINGS.GAMESPEED == nil then 
            G.SETTINGS.GAMESPEED = 1 
        end

        if G_BRRR_BRIDGE_FIRST_LOAD and not launched then
            if G.STATE == G.STATES.MENU and G.P_CENTERS and G.P_CENTERS.j_joker then
                
                -- 1. ASYNC DELAY GUARD (60 frames / ~1s)
                if frame_delay < 60 then
                    frame_delay = frame_delay + 1
                    return
                end

                -- 2. RELIABLE SAVE DETECTION
                if (G.SAVED_GAME and G.F_SAVE_CONTINUE) or G.CONT_RUN then
                    print("[BRRR:SKIP] Injected save detected after delay. Aborting Autopilot.")
                    launched = true
                    G_BRRR_BRIDGE_FIRST_LOAD = false
                    return
                end

                -- 3. EXECUTE AUTO-START (Clean sequence)
                launched = true
                G_BRRR_BRIDGE_FIRST_LOAD = false
                print("[BRRR:ATOMIC] No save found. Launching Sequence...")

                local user_speed = (G.SETTINGS and G.SETTINGS.GAMESPEED) or 1
                G.SETTINGS.GAMESPEED = 100
                if G.SPEEDFACTOR then G.SPEEDFACTOR = 100 end
                if G.MAIN_MENU_UI then G.MAIN_MENU_UI:remove(); G.MAIN_MENU_UI = nil end

                G.FUNCS.start_run(nil, {
                    deck = config.deck or 'b_red',
                    stake = config.stake or 1,
                    seed = config.seed,
                    challenge = config.challenge
                })

                G.STATE_COMPLETE = true
                G.SETTINGS.GAMESPEED = user_speed
                if G.SPEEDFACTOR then G.SPEEDFACTOR = user_speed end
                if G.save_settings then G:save_settings() end
                
                print("[BRRR:ATOMIC] Sequence Complete. Speed restored.")
            end
        end
    end
end