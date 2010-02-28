
require "object"  -- Object from stdlib
require "io"
require "string"
local u = require "aima_utils"

local M = {} -- Will contain all exported functions.

M.Object = Object

function M.Object:__tostring() return self.name or "Object" end

-- Agent class
function prompt_program(percept)
    io.write(string.format("Percept=%s; action? ", percept))
    return io.read()
end

M.Agent = Object { alive = true, program = prompt_program }


-- TODO : use logging facility instead
function M.Trace_Agent(agent)
    local old_program = agent.program
    function new_program(self, percept)
        local action = old_program(self, percept)
        local print_self = tostring(self)
        local print_percept = tostring(percept)
        local print_action = tostring(action)
        printf("%s perceives %s and does %s\n", print_self, print_percept, print_action)
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

    Example Use: See chapter/2/table_driven_agent.lua

]]--

local function simple_td_program(history, percept, lookup)
    table.insert(history, percept)
    for i, v in pairs(lookup) do
        if u.list_compare(i, history) then return v end
    end
    -- else return nil
end

M.Simple_Table_Driven_Agent = M.Agent { _init = { "name", "percept_lookup" }, 
                                          name = "Simple Table Driven Agent",
                                          percept_history = {},
                                          td_program = simple_td_program }

function M.Simple_Table_Driven_Agent:program(percept)
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
M.Random_Agent = M.Agent { _init = {"actions"}}

function M.Random_Agent:program(percept)
    return u.random_choice(self.actions)
end

return M
