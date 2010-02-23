
require "object"  -- Object from stdlib
require "io"
require "string"
local u = require "aima_utils"

local _M = {} -- Will contain all exported functions.

_M.Object = Object

function _M.Object:__tostring() return self.name or "Object" end

-- Agent class
function prompt_program(percept)
    io.write(string.format("Percept=%s; action? ", percept))
    return io.read()
end

_M.Agent = Object { alive = true, program = prompt_program }


-- TODO : use logging facility instead
function _M.TraceAgent(agent)
    old_program = agent.program
    function new_program(percept)
        local action = old_program(percept)
        printf("%s perceives %s and does %s\n", agent, precept, action)
        return action
    end
    agent.program = new_program
    return agent
end


--[[

    Table driven agent

    First version is a simple table match.

    This code looks a little odd.  We're trying to match the style
    of the Python code where the 'program' function does not have 
    general access to the internals of the agent.

    Example Use:

        local hist = { [{ 2, 1 }] = "foo",
                       [{ 3, 1 }] = "bar",
                       [{ 3 }] = "baz3",
                       [{ 2 }] = "baz2",
                       [{ 1 }] = "baz1" }
        agent2 = A.Simple_Table_Driven_Agent{ hist }

        agent2:program(1)  -->  returns "baz1"
        agent2:program(2)  -->  returns "foo"
        agent2:program(3)  -->  returns nil


]]--

local function simple_td_program(history, percept, lookup)
    table.insert(history, percept)
    for i, v in pairs(lookup) do
        if u.list_compare(i, history) then return v end
    end
end

_M.Simple_Table_Driven_Agent = _M.Agent { _init = { "percept_lookup" }, 
                                          name = "Simple Table Driven Agent",
                                          percept_history = {},
                                          td_program = simple_td_program }

function _M.Simple_Table_Driven_Agent:program(percept)
    return self.td_program(self.percept_history, percept, self.percept_lookup)
end

--[[
    Table driven agent

    Eventually....
    
    This will be somewhat of a divergence from the book.  A table driven agent 
    that can only look at the entire history of percepts isn't very
    useful.  However, doing a search based on N number of recent percepts is
    much more feasable.
    
    The previous percepts can be stored in an arbitrary tree, with
    actions at the leaves.


]]--

--[[
    Random Agent
]]--
_M.Random_Agent = _M.Agent { _init = {"actions"}}

function _M.Random_Agent:program(percept)
    return u.random_choice(self.actions)
end

return _M
