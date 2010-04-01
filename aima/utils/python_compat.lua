
require "io"
require "string"
require "math"

local M = {} -- Will contain all exported functions.


--[[
    random_choice()

    Randomly choose an item from the list.

    Don't forget to initialize the random seed first.
]]--
function M.random_choice(list)
    local i = math.random(#list)
    return list[i]
end


--[[
    Simple / shallow list comparison.

    TODO: If something better is needed, consider using Penlight's table
    utilities instead.
]]--
function M.list_compare(a, b)
    if #a ~= #b then
        return false
    end
    for i, v in pairs(a) do
        if v ~= b[i] then
            return false
        end
    end

    for i, v in pairs(b) do
        if v ~= a[i] then
            return false
        end
    end
    return true
end

return M
