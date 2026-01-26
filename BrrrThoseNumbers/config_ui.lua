local mod = SMODS.current_mod

-- Main configuration tab definition for SMODS
mod.config_tab = function()
    return { n = G.UIT.ROOT, config = { align = "cm", padding = 0.05, colour = G.C.CLEAR }, nodes = {
        -- Row for Sound Effect Toggle
        { n = G.UIT.R, config = { align = "cm", padding = 0.1 }, nodes = {
            { n = G.UIT.T, config = { text = "Enable Sound Effect", scale = 0.4, colour = G.C.UI.TEXT_LIGHT } },
            { n = G.UIT.C, config = { align = "cm", padding = 0.1 }, nodes = {
                { n = G.UIT.O, config = { object = SMODS.ConfigTab.create_toggle({ 
                    ref_table = mod.config, 
                    ref_value = 'enable_sound' 
                }) } }
            } }
        } }
    } }
end