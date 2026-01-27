---
--- BrrrDebugBridge - Main Entry Point
---
--- GP-2026-STRICT: Native config loading with safe path resolution.
---

-- [BOOT CONTROL FUNCTION]
local function apply_config()
    -- SMODS.current_mod is usually available when the file is executed by the loader
    local mod_path = (SMODS and SMODS.current_mod and SMODS.current_mod.path) or "Mods/BrrrDebugBridge/"
    local config_path = mod_path .. "config.lua"
    
    local show_intro = false
    local chunk, err = loadfile(config_path)

    if chunk then
        local status, config_data = pcall(chunk)
        if status and type(config_data) == "table" then
            show_intro = config_data.show_intro
        end
    else
        print("[BRRR BRIDGE] Config skipped (expected during first run or if ignored): " .. tostring(err))
    end

    if not show_intro then
        -- Safe override: Game class might be accessible even if G is nil
        if Game and Game.splash_screen then
            function Game:splash_screen()
                if self.main_menu then self:main_menu() end
            end
        end
        
        -- Late binding for the settings flag
        if G and G.SETTINGS then
            G.SETTINGS.skip_splash = 'Yes'
        end
        print("!!! BRRR BRIDGE: Intro Bypass Active !!!")
    else
        print("!!! BRRR BRIDGE: Intro Enabled by Config !!!")
    end
end

-- Execute immediately
apply_config()