
local FL = require "functional_list"
local OP = require "operators"

local M = {} -- Holds objects exported by this module.

--[[
    card_total()

    Just sum up the cards in the card set.

    Additonal not-very-relevant commentary:

    This is about twice the characters of the Haskell
    version.  Some of that stems from the desire to specify
    the imports of everything, rather than having common
    functions like map() in the global namespace.
    The other main thing missing is some way to compose functions in the
    dot-free style that is popular with Haskell.
]]--

local function card_total(card_set)
    return FL.foldr1(OP.add, (FL.map(OP.len, card_set)))
end


--[[
    valid_tableau()
]]--
local function valid_tableau(tb)
    return #tb == 10 and card_total(tb) <= 104
       and (FL.all(function(x) return x[1].face_up end, tb))
end

local function valid_talon(tal)
    return #tal <= 5 
       and (FL.all(function(x) return #x == 10 end, tal))
end
        
local function valid_foundation(found)
    return #found <= 8 
       and (FL.all(function(x) return #x == 13 end, found))
end
    
local function all_cards_total(sg)
    return   card_total(sg.tableau) + card_total(sg.talon) + card_total(sg.foundation)
end


function M.valid_game(sg)
    return     all_cards_total(sg) == 104
           and valid_talon(sg.talon)
           and valid_tableau(sg.tableau)
           and valid_foundation(sg.foundation)
end

return M
