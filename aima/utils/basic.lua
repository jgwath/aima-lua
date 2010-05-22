--[[
    aima/utils/basic.lua

    This is a handy set of basic utility functions.

    Some functions, like round(), ought to have been included in the
    basic Lua distribution.  Others, like table_print() are quite useful
    for quick debugging.
]]--

require "table"

--[[
    Usage Notes:

    Since this module just returns a table of functions, I have
    this in a utilities.lua file that is loaded when I start an
    interactive interpreter:

    local UT = require "aima/utils/basic"

    table_print = UT.table_print
    tp = UT.table_print
    round = UT.round
    coxpcall = UT.coxpcall
    copcall = UT.copcall
    scope = UT.scope
    printf = UT.printf
    reload = UT.reload
    apairs = UT.apairs

    So that will then inject these functions into the global scope,
    where it is quicker to type in.  This is handy for interactive
    debugging.

]]--

local M = {} -- functions to be exported.

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


--[[
    round()

    Round number to nearest integer value.
]]--
function M.round(num) return math.floor(num+.5) end


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
-------------------------------------------------------------------------------

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


--[[
	scope()

	John Belmonte's 'Exceptions in Lua' from Lua Programming Gems, Chapter 13

	Modified to use copcall() instead.

    For how to use this, see the examples here:

      http://partiallyappliedlife.blogspot.com/2009/08/resource-cleanup-in-lua.html

    Just put a require statement like this at the beginning of the test code:

        local scope = require("aima/utils/basic").scope

    John has put this code into the public domain (communicated via private email).
]]--

function M.scope(f)
    local function run(list, err)
        for _, f in ipairs(list) do f(err) end
    end
    local success_funcs, failure_funcs, exit_funcs = {}, {}, {}
    local manager = {
        on_success = function(f) table.insert(success_funcs, f) end,
        on_failure = function(f) table.insert(failure_funcs, f) end,
        on_exit =    function(f) table.insert(exit_funcs,    f) end,
    }
    local old_fenv = getfenv(f)
    setmetatable(manager, {__index = old_fenv})
    setfenv(f, manager)
    local status, err = M.copcall(f)
    setfenv(f, old_fenv)
    -- NOTE: behavior undefined if a hook function raises an error
    run(status and success_funcs or failure_funcs, err)
    run(exit_funcs, err)
    if not status then error(err, 2) end
end


-- printf
function M.printf(...) io.write(string.format(...)) end


-- reload module
function M.reload(mod)
    package.loaded[mod] = nil
    return require(mod)
end


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


return M
