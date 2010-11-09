
local B = require "Board"
local M = require "Move"
local G = require "Game"

local function main()
    local sd  = B.shuffled_deck()
    local nsg = B.deal_spider_game(sd)
    return G.interactive_game(nsg)
end

main()
