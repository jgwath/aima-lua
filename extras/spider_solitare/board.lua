
local M = {} -- Holds objects exported by this module.

function M.card_total(card_set)
    local total = 0
    for i, v in ipairs(card_set) do
        total = total + #v
    end
    return total
end

return M
