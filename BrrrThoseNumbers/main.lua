local mod = SMODS.current_mod
 
local last_h = 0 -- Tracks hands_left to fire sound only once
 
-- Efficient hook for state-based audio trigger
local old_update = Game.update
function Game:update(dt)
    old_update(self, dt)
 
    -- Check if sound is enabled and we are in a round
    if G.I and mod.config.enable_sound and G.GAME and G.GAME.current_round then
        local h = G.GAME.current_round.hands_left
 
        -- Play sound only on the transition to 1 hand left
        if h == 1 and last_h > 1 then
            -- 'tarot1' is a verified internal sound ID
            play_sound('tarot1', 1.2, 0.6)
        end
        last_h = h
    elseif G.GAME and not G.GAME.current_round then
        -- Reset tracker when not in a round
        last_h = 0
    end
end
 
-- Efficient hook for visual UI modification
local old_draw = UIBox.draw
function UIBox:draw()
    -- Target the 'Play' button and check conditions
    if self.config.button == 'play_cards_from_highlighted'
    and mod.config.enable_warning and G.GAME and G.GAME.current_round
    and G.GAME.current_round.hands_left == 1
    and G.hand and #G.hand.highlighted > 0 then
        -- Store original colour to restore it later
        local old_outline = self.config.outline_colour
 
        -- Calculate pulsing effect for the Dynamic Warning
        local p = (math.sin(G.SETTINGS.GUITimer * 12) + 1) / 2
        local warn_col = {1, 0.1, 0.1, 1 * p}
 
        -- Inject new outline colour
        self.config.outline_colour = warn_col
 
        -- Draw the element with the new colour
        old_draw(self)
 
        -- Restore original colour to prevent UI bugs
        self.config.outline_colour = old_outline
    else
        -- Draw all other elements normally
        old_draw(self)
    end
end
-- TEST_ID: 94821

SMODS.Keybind{
    key_pressed = 'f10',
    action = function()
        if G.GAME and G.GAME.current_round then
            G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + 1
            G.GAME.current_round.discards_left = G.GAME.current_round.discards_left + 1
            sendDebugMessage("BRIDGE_TEST: Stats incremented.")
        end
    end
}
