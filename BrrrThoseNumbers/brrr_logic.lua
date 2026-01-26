-- BRRR Feature: Audio feedback based on score magnitude
-- Project Standard: German comments for logic, English for technicals
-- SMODS Compliance: Author YoGeilmann, version 1.0.0

-- TECHNICAL: Use math.log10 for LuaJIT/5.1 compatibility (Balatro Engine)
-- Berechnet die Tonhöhe basierend auf der Chip-Anzahl (Logarithmisch)
local function calculate_brrr_pitch(value)
    if not value or value <= 0 then return 1.0 end
    
    -- STRESS-TEST: Clamp pitch between 0.8 and 5.0 to prevent OpenAL crashes
    return math.min(0.8 + (math.log10(value) * 0.02), 5.0)
end

-- Hooking the confirmation function to inject sound
-- TECHNICAL: Hooking G.FUNCS.confirm_ea to trigger sound on score confirmation
local old_confirm_ea = G.FUNCS.confirm_ea
G.FUNCS.confirm_ea = function(e)
    -- Sicherheits-Check: Nur abspielen, wenn das Spielobjekt existiert
    if G.GAME and G.GAME.chips then
        play_sound('tarot1', calculate_brrr_pitch(G.GAME.chips), 0.6)
    end
    
    -- Ursprüngliche Funktion aufrufen (Reversibilität gewahrt)
    if old_confirm_ea then
        old_confirm_ea(e)
    end
end