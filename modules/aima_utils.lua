
require "io"
require "string"
require "math"

local _M = {} -- Will contain all exported functions.

function _M.random_choice(list)
    local i = math.random(#list)
    return list[i]
end

--[[
    Simple list comparison.
    This is slow and inefficient.

    TODO: If something better is needed, consider using Penlight's table
    utilities instead.
]]--
function _M.list_compare(a, b)
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

return _M
