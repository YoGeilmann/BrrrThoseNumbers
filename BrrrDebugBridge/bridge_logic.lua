-- BrrrDebugBridge Heartbeat
-- Logic: Check if the Core Mod is loaded and report status.
function SMODS.current_mod.process_config(config)
    if SMODS.Mods["BrrrThoseNumbers"] then
        sendDebugMessage("BrrrDebugBridge: [OK] Core Mod detected and linked.")
    else
        sendDebugMessage("BrrrDebugBridge: [WARN] Core Mod 'BrrrThoseNumbers' not found!")
    end
end