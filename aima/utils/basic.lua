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

local M = {}


-- Print anything - including nested tables
function M.table_print (tt, indent, done)
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


-------------------------------------------------------------------------------
-- Coroutine safe xpcall and pcall versions
--
-- Encapsulates the protected calls with a coroutine based loop, so errors can
-- be dealed without the usual Lua 5.x pcall/xpcall issues with coroutines
-- yielding inside the call to pcall or xpcall.
--
-- Authors: Roberto Ierusalimschy and Andre Carregal 
-- Contributors: Thomas Harning Jr., Ignacio Burgueño, Fábio Mascarenhas
--
-- Copyright 2005 - Kepler Project (www.keplerproject.org)
--
-- Not really needed for Lua 5.2 anymore.
--
-------------------------------------------------------------------------------

if _VERSION == "Lua 5.2" then
    M.coxpcall = xpcall
    M.copcall = pcall
else

    -------------------------------------------------------------------------------
    -- Implements xpcall with coroutines
    -------------------------------------------------------------------------------
    local performResume, handleReturnValue
    local oldpcall, oldxpcall = pcall, xpcall

    function handleReturnValue(err, co, status, ...)
        if not status then
            return false, err(debug.traceback(co, (...)), ...)
        end
        if coroutine.status(co) == 'suspended' then
            return performResume(err, co, coroutine.yield(...))
        else
            return true, ...
        end
    end

    function performResume(err, co, ...)
        return handleReturnValue(err, co, coroutine.resume(co, ...))
    end    

    function M.coxpcall(f, err, ...)
        local res, co = oldpcall(coroutine.create, f)
        if not res then
            local params = {...}
            local newf = function() return f(unpack(params)) end
            co = coroutine.create(newf)
        end
        return performResume(err, co, ...)
    end

    -------------------------------------------------------------------------------
    -- Implements pcall with coroutines
    -------------------------------------------------------------------------------

    local function id(trace, ...)
      return ...
    end

    function M.copcall(f, ...)
        return M.coxpcall(f, id, ...)
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

function M.apairs(...)
    --   iterator function, context, start value
    return apairs_helper, {n=select('#', ...), ...}, 0
end


--[[
    Pure-Lua replacement for ipairs()

    ipairs() depreciated (with an error) in Lua 5.2
]]--
if not pcall(ipairs, {}) then
    local function ipairs_helper(a, i)
        i = i + 1
        local v = a[i]
        if v ~= nil then
            return i, v
        end
    end

    --[[
        ipairs()

            Works same as Lua 5.1 ipairs()

        returns:
            iterator function, context, start value
    ]]--
    function M.ipairs(a)
        local mt = getmetatable(a)
        if mt and mt.__ipairs then
            return mt.__ipairs(a)
        else 
            return ipairs_helper, a, 0
        end
    end
end


--[[
    round()

    Round number to nearest integer value.
]]--
function M.round(num, idp) 
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- printf
function M.printf(...) io.write(string.format(...)) end



--[[
	scope()

	John Belmonte's 'Exceptions in Lua' from Lua Programming Gems, Chapter 13

    For how to use this, see the examples here:

      http://partiallyappliedlife.blogspot.com/2009/08/resource-cleanup-in-lua.html

    John has put this code into the public domain (communicated via private email).
]]--
local function run_list(list, err)
    for _, f in ipairs(list) do f(err) end
end

if _VERSION == "Lua 5.1" then
    function M.scope(f)
        local success_funcs, failure_funcs, exit_funcs = {}, {}, {}
        local manager = {
            on_success = function(f) table.insert(success_funcs, f) end,
            on_failure = function(f) table.insert(failure_funcs, f) end,
            on_exit =    function(f) table.insert(exit_funcs,    f) end,
        }
        -- Inject these functions into that f's environment.
        local old_fenv = debug.getfenv(f)
        setmetatable(manager, {__index = old_fenv})
        debug.setfenv(f, manager)
        local status, err = pcall(f)
        debug.setfenv(f, old_fenv)
        -- NOTE: behavior undefined if a hook function raises an error
        run_list(status and success_funcs or failure_funcs, err)
        run_list(exit_funcs, err)
        if not status then error(err, 2) end
    end
end

if _VERSION == "Lua 5.2" then
    --[===[
    function scope(f)
        local success_funcs, failure_funcs, exit_funcs = {}, {}, {}
        local manager = {
            on_success = function(f) table.insert(success_funcs, f) end,
            on_failure = function(f) table.insert(failure_funcs, f) end,
            on_exit =    function(f) table.insert(exit_funcs,    f) end,
        }
        -- Inject these functions into that f's environment.
        local old_fenv = debug.getfenv(f)
        setmetatable(manager, {__index = old_fenv})
        debug.setfenv(f, manager)
        local status, err = pcall(f)
        debug.setfenv(f, old_fenv)
        -- NOTE: behavior undefined if a hook function raises an error
        run_list(status and success_funcs or failure_funcs, err)
        run_list(exit_funcs, err)
        if not status then error(err, 2) end
    end
    ]===]--
end


local unpack = unpack or table.unpack -- Lua 5.2

--- Reverse the arguments passed.
-- @return Arguments passed in reverse order.
local function reverse_args(...)
    local nargs = select('#', ...)
    local args = {}
    for i = 1, nargs do
        args[nargs + 1 - i] = (select(i, ...))
    end
    return unpack(args, 1, nargs)
end

M.reverse_args = reverse_args
return M
