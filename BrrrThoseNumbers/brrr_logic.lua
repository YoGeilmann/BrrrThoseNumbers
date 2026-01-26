-- FIA: Load UI configuration from separate file
assert(SMODS.load_file("config_ui.lua"))()

local mod = SMODS.current_mod
local last_h = 0 

-- FIA FIX: Scoping hooks locally to prevent cross-mod collisions
local old_update = Game.update
function Game:update(dt)
    old_update(self, dt)
    if G.I and mod.config.enable_sound and G.GAME and G.GAME.current_round then
        local h = G.GAME.current_round.hands_left
        if h == 1 and last_h > 1 then
            play_sound('tarot1', 1.2, 0.6)
        end
        last_h = h
    elseif G.GAME and not G.GAME.current_round then
        last_h = 0
    end
end

local old_draw = UIBox.draw
function UIBox:draw()
    if self.config.button == 'play_cards_from_highlighted'
    and mod.config.enable_warning and G.GAME and G.GAME.current_round
    and G.GAME.current_round.hands_left == 1
    and G.hand and #G.hand.highlighted > 0 then
        local old_outline = self.config.outline_colour
        local p = (math.sin(G.SETTINGS.GUITimer * 12) + 1) / 2
        self.config.outline_colour = {1, 0.1, 0.1, 1 * p}
        old_draw(self)
        self.config.outline_colour = old_outline
    else
        old_draw(self)
    end
end

