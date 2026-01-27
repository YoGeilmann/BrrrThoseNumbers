--- GP-2026-STRICT: Bridge Logic - Refined Session-Controller
local mod_path = "Mods/BrrrDebugBridge/"
local config_path = mod_path .. "config.lua"
local config = { show_intro = false, mode = "auto", deck = "b_red", stake = 1 }

-- [GUARD] Session-Lock
if G_BRRR_BRIDGE_FIRST_LOAD == nil then
    G_BRRR_BRIDGE_FIRST_LOAD = true
end

-- [CONFIG] Load
local chunk = loadfile(config_path)
if chunk then
    local status, data = pcall(chunk)
    if status and type(data) == "table" then config = data end
end

-- [COMPONENT] Refined Intro Bypass
-- Logic: Only bypass if (Auto-Mode is active) OR (Intro is explicitly disabled)
if config.mode == "auto" or not config.show_intro then
    if Game then
        function Game:splash_screen()
            print("[BRRR_BRIDGE:INTRO] Bypass triggered (Reason: Mode="..config.mode.." | ShowIntro="..tostring(config.show_intro)..")")
            if self.main_menu then self:main_menu() end
        end
        if G and G.SETTINGS then G.SETTINGS.skip_splash = 'Yes' end
    end
else
    print("[BRRR_BRIDGE:INTRO] Native boot: Intro will be shown (Manual Mode)")
end

-- [COMPONENT] Autopilot
if config.mode == "auto" then
    local original_main_menu = Game.main_menu
    function Game:main_menu()
        original_main_menu(self)
        if G_BRRR_BRIDGE_FIRST_LOAD then
            G_BRRR_BRIDGE_FIRST_LOAD = false
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    G.FUNCS.start_run(nil, { deck = config.deck or 'b_red', stake = config.stake or 1 })
                    return true
                end
            }))
        end
    end
end