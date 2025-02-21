-- works
SMODS.Enhancement {
    key = "radiant",
    loc_txt = {
        name = "Radiant",
        text = {
            "{C:attention}SOLAR{}",
            "Grants {X:mult,C:white}X0.2{} Mult for",
            "each {C:attention}Solar{} card in",
            "hand or played",
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = {
            x_mult = 1
        }
    },
    pos = {x=0, y=3},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            local solar_count = 0
            for _, handCard in ipairs(G.hand.cards) do
                if handCard.config.center_key == "m_fm_radiant" or
                   handCard.config.center_key == "m_fm_restoration" or 
                   handCard.config.center_key == "m_fm_scorch" then
                    solar_count = solar_count + 1
                end
            end
            
            for _, playedCard in ipairs(G.play.cards) do
                if playedCard.config.center_key == "m_fm_radiant" or
                   playedCard.config.center_key == "m_fm_restoration" or 
                   playedCard.config.center_key == "m_fm_scorch" then
                    solar_count = solar_count + 1
                end
            end
 
            if solar_count > 0 then
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "Radiant!",
                    sound = "fm_radiant",
                    colour = G.C.ORANGE
                })
                return{
                    x_mult = 1 + (0.2 * solar_count)
                }
            end
        end
    end
}

-- works
SMODS.Enhancement {
    key = "scorch",
    loc_txt = {
        name = "Scorch",
        text = {
            "{C:attention}SOLAR{}",
            "Scoring this card will increase",
            "{C:attention}Scorch{} stacks.",
            "At {C:attention}3{} stacks, {C:attention}it will ignite{},",
            "destroying it but granting {X:mult,C:white}X3{} Mult",
            "{C:inactive}(Currently {C:red}#1#{C:inactive} Stacks)"
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = {
            stacks = 0,
            x_mult = 1
        }
    },
    pos = {x=1, y=3},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.stacks } }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            card.ability.extra.stacks = card.ability.extra.stacks + 1
            return {
                message = 'Scorched!',
                colour = G.C.ORANGE,
                sound = 'fm_scorch'
            }
        end
        if context.destroying_card and card.ability.extra.stacks >= 3 then
            return {
                x_mult = 3,
                message = 'Ignited!',
                sound = 'fm_ignition',
                colour = G.C.ORANGE
            }
        end
    end
}

-- works
SMODS.Enhancement {
    key = "restoration",
    loc_txt = {
        name = "Restoration",
        text = {
            "{C:attention}SOLAR{}",
            "Adjacent cards to it will rank up",
            "if they share the same suit"
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = {
            rank_increase = 0
        }
    },
    pos = {x=2, y=3},
    calculate = function(self, card, context)
        -- Check adjacent cards after scoring
        if context.final_scoring_step and context.cardarea == G.hand then
            for i, handCard in ipairs(G.hand.cards) do
                if handCard == card then
                    -- Check and rank up left card
                    if i > 1 and G.hand.cards[i-1].base.suit == card.base.suit then
                        local leftCard = G.hand.cards[i-1]
                        local new_rank = math.min(leftCard:get_id() + 1, 14)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                if leftCard.area == G.hand then
                                    leftCard:highlight()
                                    leftCard:flip()
                                    leftCard:set_base(G.P_CARDS[string.sub(leftCard.base.suit, 1, 1)..'_' .. 
                                        (new_rank < 10 and tostring(new_rank) or
                                         new_rank == 10 and 'T' or
                                         new_rank == 11 and 'J' or
                                         new_rank == 12 and 'Q' or
                                         new_rank == 13 and 'K' or 'A')])
                                    leftCard:flip()
                                    leftCard:highlight(false)
                                    SMODS.calculate_effect({
                                        message = "Rank Up!",
                                        sound = "fm_restoration",
                                        colour = G.C.ORANGE
                                    }, leftCard)
                                end
                                return true
                            end
                        }))
                    end
     
                    -- Check and rank up right card
                    if i < #G.hand.cards and G.hand.cards[i+1].base.suit == card.base.suit then
                        local rightCard = G.hand.cards[i+1]
                        local new_rank = math.min(rightCard:get_id() + 1, 14)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                if rightCard.area == G.hand then
                                    rightCard:highlight()
                                    rightCard:flip()
                                    rightCard:set_base(G.P_CARDS[string.sub(rightCard.base.suit, 1, 1)..'_' .. 
                                        (new_rank < 10 and tostring(new_rank) or
                                         new_rank == 10 and 'T' or
                                         new_rank == 11 and 'J' or
                                         new_rank == 12 and 'Q' or
                                         new_rank == 13 and 'K' or 'A')])
                                    rightCard:flip()
                                    rightCard:highlight(false)
                                    SMODS.calculate_effect({
                                        message = "Rank Up!",
                                        sound = "fm_restoration",
                                        colour = G.C.ORANGE
                                    }, rightCard)
                                end
                                return true
                            end
                        }))
                    end
                    break
                end
            end
        end
    end
}