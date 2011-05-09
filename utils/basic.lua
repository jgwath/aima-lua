--[[
    aima/utils/basic.lua

    This is a handy set of basic utility functions.

    Some functions, like round(), ought to have been included in the
    basic Lua distribution.  Others, like table_print() are quite useful
    for quick debugging.

    Unlike just about everything else I do, this will inject
    the functions into the global namespace.
]]--

require "table"
require "debug"
require "math"


-- Print anything - including nested tables
local function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    for key, value in pairs (tt) do
      io.write(string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        io.write(string.format("[%s] => table\n", tostring (key)));
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write("(\n");
        table_print (value, indent + 7, done)
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write(")\n");
      else
        io.write(string.format("[%s] => %s\n",
            tostring (key), tostring(value)))
      end
    end
  else
    io.write(tt .. "\n")
  end
end


--[[=================================================================

                            Iterators

=================================================================]]--

--[[
    apairs()

    Easy iteration over a variable number of arguments
    to a function.

    Example Usage:

    function test_func(...)
        for i,a in apairs(...) do print(i, a) end
    end

    test_func("foo", nil, 32, nil)
    
    will print:

    1       foo
    2       nil
    3       32
    4       nil

    Code by David Manura <dm.lua@math2.org>

]]--

local function apairs_helper(a, i)
    if i < a.n then 
        return i + 1, a[i + 1] 
    end
end

local function apairs(...)
    --   iterator function, context, start value
    return apairs_helper, {n=select('#', ...), ...}, 0
end


--[[
    round()

    Round number to nearest integer value.
]]--
local function round(num, idp) 
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- printf
local function printf(...) io.write(string.format(...)) end


return {
    printf      = printf,
    apairs      = apairs,
    round       = round,
    table_print = table_print,
}
