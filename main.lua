SMODS.Atlas {
    key = "lordminimus",
    path = "LordMinimusAtlas.png",
    px = 71,
    py = 95
}


-- Free Refill
SMODS.Joker {
    key = 'free_refill',
    loc_txt = {
        name = 'Free Refill',
        text = {
            "This Joker gains {X:mult,C:white} X#1# {} Mult",
            "when a {V:1}#2#{0} card is destroyed,",
            "suit changes every round",
            "{C:inactive}(Currently {X:mult,C:white}X#3#{C:inactive} Mult)",
        }
    },

    config = { extra = { xmult = 1, xmult_gain = 0.5 } },
    discovered = true,
    rarity = 3,
    atlas = "lordminimus",
    pos = { x = 0, y = 0 },
    cost = 7,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return {
                vars = {
                card.ability.extra.xmult_gain,
                localize(G.GAME.current_round.j_Minim_free_refill_card.suit, 'suits_singular'),
                card.ability.extra.xmult,
                colours = { G.C.SUITS[G.GAME.current_round.j_Minim_free_refill_card.suit]}
            }
        }
    end,
    calculate = function(self, card, context)
        if
            context.remove_playing_cards and
            not context.blueprint
        then
            local suit_cards = 0
            for k, val in ipairs(context.removed) do
                if val:is_suit(G.GAME.current_round.j_Minim_free_refill_card.suit) then suit_cards = suit_cards + 1 end
            end
            if suit_cards > 0 then
                card.ability.extra.xmult = card.ability.extra.xmult + suit_cards*card.ability.extra.xmult_gain end
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.XMULT,
                card = card
            }
        elseif
            context.cards_destroyed and
            not context.blueprint
        then
            local suit_cards = 0
            for k, val in ipairs(context.glass_shattered) do
                if val:is_suit(G.GAME.current_round.j_Minim_free_refill_card.suit) then suit_cards = suit_cards + 1 end
            end
            if suit_cards > 0 then
                card.ability.extra.xmult = card.ability.extra.xmult + suit_cards*card.ability.extra.xmult_gain end
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.XMULT,
                card = card
            }
        end
        if context.joker_main and card.ability.extra.xmult > 1 then
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult } },
                Xmult_mod = card.ability.extra.xmult,
                colour = G.C.XMULT
            }
        end
    end,
}


-- RNA
SMODS.Joker {
    key = 'rna',
    loc_txt = {
        name = 'RNA',
        text = {
            "If {C:attention}final{} hand of round",
            "has only {C:attention}1 card{}, create",
            "a {C:attention}Polychrome{} copy and",
            "add it to {C:attention}deck{}",
        }
    },
    discovered = true,
    rarity = 2,
    atlas = "lordminimus",
    pos = { x = 1, y = 0 },
    cost = 5,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if
            context.joker_main and G.GAME.current_round.hands_left == 0
        then
            if #context.full_hand == 1 then
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local _card = copy_card(context.full_hand[1], nil, nil, G.playing_card)
                _card:set_edition({polychrome = true})
                _card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                table.insert(G.playing_cards, _card)
                G.hand:emplace(_card)
                _card.states.visible = nil

                G.E_MANAGER:add_event(Event({
                    func = function()
                        _card:start_materialize()
                        return true
                    end
                })) 
                return {
                    message = localize('k_copied_ex'),
                    colour = G.C.CHIPS,
                    card = card,
                    playing_cards_created = {true}
                }
            end
        end
    end,
}


-- Flyer
SMODS.Joker {
    key = 'flyer',
    loc_txt = {
        name = 'Flyer',
        text = {
            "Earn {C:money}$1{} for",
            "every {C:attention}purchase{}",
        }
    },
    discovered = true,
    config = { extra = { money = 1 } },
    rarity = 1,
    atlas = "lordminimus",
    pos = { x = 2, y = 0 },
    cost = 6,
    blueprint_compat = true,
	calculate = function (self, card, context)
        if context.buying_card or context.open_booster then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, blocking = false,
                func = function()
                    play_sound('coin2')
                    card:juice_up(0.3, 0.4)
                    delay(0.2)
                    ease_dollars(card.ability.extra.money)
                    return true
                end
			}))
        end
    end,
}


-- Number One
SMODS.Joker {
	key = 'number_one',
	loc_txt = {
		name = 'Number One',
		text = {
			"Retrigger all played cards",
			"in {C:attention}first hand{} of round"
		}
	},
    discovered = true,
	config = { extra = { repetitions = 1 } },
	rarity = 2,
	atlas = 'lordminimus',
	pos = { x = 3, y = 0 },
	cost = 6,
    blueprint_compat = true,
	calculate = function(self, card, context)
		if context.cardarea == G.play and context.repetition and not context.repetition_only then
			if G.GAME.current_round.hands_played == 0 then
				return {
					message = localize('k_again_ex'),
					repetitions = card.ability.extra.repetitions,
					card = card
				}
			end
		end
	end
}


-- Chocolate Coin
SMODS.Joker {
	key = 'chocolate_coin',
	loc_txt = {
		name = 'Chocolate Coin',
		text = {
			"Earn {C:money}$#1#{} at",
			"end of round,",
            "{C:money}-$1{} per round played",
		}
	},
	config = { extra = { money = 6 } },
	rarity = 1,
	atlas = 'lordminimus',
	pos = { x = 0, y = 1 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money } }
	end,
	calc_dollar_bonus = function(self, card)
		local bonus = card.ability.extra.money
        card.ability.extra.money = card.ability.extra.money - 1
        if card.ability.extra.money <= 0 then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.6, blocking = false,
                func = function()
                    play_sound('tarot1')
                    card.T.r = -0.2
                    card:juice_up(0.3, 0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true
                    card_eval_status_text(card, 'extra', nil, nil, nil,
				    { message = localize('k_eaten_ex') })
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        blockable = false,
                        func = function()
                            G.jokers:remove_card(card)
                            card:remove()
                            card = nil
                            return true;
                        end
                    }))
                    return true
                end
            }))
        else
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blocking = false,
                func = function()
                    card:juice_up(0.3, 0.4)
                    card_eval_status_text(card, 'extra', nil, nil, nil,
				    { message = "-$1" })
                    return true
                end
            }))
        end
		if bonus > 0 then return bonus end
	end,
}

-- For Free Refill Suit Change
local igo = Game.init_game_object
function Game:init_game_object()
    local ret = igo(self)
    ret.current_round.j_Minim_free_refill_card = { suit = 'Spades' }
    return ret
end

function SMODS.current_mod.reset_game_globals(run_start)
    G.GAME.current_round.j_Minim_free_refill_card = { suit = 'Spades' }
    local valid_j_Minim_free_refill_cards = {}
        for _, v in ipairs(G.playing_cards) do
            if not SMODS.has_no_suit(v) then
                valid_j_Minim_free_refill_cards[#valid_j_Minim_free_refill_cards+1] = v
            end
        end
        if valid_j_Minim_free_refill_cards[1] then
            local j_Minim_free_refill_card = pseudorandom_element(valid_j_Minim_free_refill_cards, pseudoseed('2cas' .. G.GAME.round_resets.ante))
            G.GAME.current_round.j_Minim_free_refill_card.suit = j_Minim_free_refill_card.base.suit
        end
end
------------------------------

SMODS.Keybind{
    key = 'minimus_joker_testS',
    key_pressed = '1',
    held_keys = {'lctrl'}, -- other key(s) that need to be held

    action = function(self)
        SMODS.add_card({
            key = "j_Minim_free_refill"
        })
        SMODS.add_card({
            key = "c_justice"
        })
        SMODS.add_card({
            key = "c_justice"
        })
        SMODS.add_card({
            key = "c_justice"
        })
        SMODS.add_card({
            key = "c_justice"
        })
        SMODS.add_card({
            key = "c_justice"
        })
    end,
}