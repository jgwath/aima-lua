
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


-- TODO : use logging facility instead?
function M.Trace_Agent(agent)
    local old_program = agent.program
    function new_program(self, percept)
        local action = old_program(self, percept)
        printf("%s perceives %s and does %s\n", 
               tostring(self), tostring(percept), tostring(action))
        return action
    end
    agent.program = new_program
    return agent
end


--[[

    Simple Table Driven Agent

    First version is a simple table match against the entire
    history of the percepts.  See below for a more useful 
    version of this.

    For example use refer to chapter/2/table_driven_agent.lua .

    Notes:

    There is mention in the Python version that the 'program'
    method should be defined so that it doesn't have access
    to the rest of the internals of the agent, and therefore
    can't "cheat".

    However, if we are truly in an adversarial situation where
    parts of the agent code are untrusted, then we need to take
    many further steps to sandbox the various parts of the agent
    code.  In particular, we must only pass in immutable objects, and
    have other infrastructure to support a true object-capability style.

    So we're not going to do that for now, but we may return to this
    subject later.

]]--

M.Simple_Table_Driven_Agent = M.Agent { _init = { "name", "percept_lookup" }, 
                                          name = "Simple Table Driven Agent",
                                          percept_history = {} }
                                          

function M.Simple_Table_Driven_Agent:program(percept)
    table.insert(self.percept_history, percept)
    for i, v in pairs(self.percept_lookup) do
        if u.list_compare(i, self.percept_history) then return v end
    end
    -- else return nil
end


--[[
    Table driven agent

    This will be somewhat of a divergence from the book.  A table driven agent 
    that can only look at the entire history of percepts isn't very
    useful.  However, doing a search based on N number of recent percepts is
    much more feasable.
    
    The previous percepts can be stored in a tree, with a single percept
    the link between nodes, and actions at the leaves.

    The case where there is only one level of history provided is basically
    what the Simple Reflex Agent does.

    To Use:
        ag1 = Table_Driven_Agent {"my_ag1", tree, 3}


    An small example history tree:

        [[1] = 'a', [2] = 'b']
        \_____________________'x'___[[1] = 'c', [2] = 'd']
         \
          \___________________'y'___[[1] = 'd', [2] = 'g']
                                    \
                                     \_______'x'___[[1] = 'e']
                                      \
                                       \_____'y'___[[1] = 'f']

    So if the current percept doesn't match 'x' or 'y', then we will
    choose either 'a' or 'b' as the action.

    If the current percept is 'x', then we will choose either 'c' or 'd'
    as the action.

    If the current percept is 'y', then we will look at the previous
    percept.  If that was again 'y', then 'f' is the action.  If it
    was 'x', then 'e' is the action.  And if it was neither of those, then we
    will choose 'd' or 'g' as the action.

        
]]--

M.Table_Driven_Agent = M.Agent { _init = { "name", "lookup_tree", "depth" }, 
                                          name = "Table Driven Agent",
                                          percept_history = {}
                                          }

function M.Table_Driven_Agent:program(percept)
    local hist = self.percept_history
    if #hist >= self.depth then
        table.remove(hist) -- oldest 
    end
    table.insert(hist, 1, percept)

    local hindex = 1
    local node = self.lookup_tree
    for i, curr_percept in ipairs(hist) do
        local next_node = node[curr_percept]
        if next_node then
            node = next_node
        else    
            return u.random_choice(node)
        end
    end
end


--[[
    Random Agent
]]--
M.Random_Agent = M.Agent { _init = {"name", "actions"}
                           name = "A Random Agent" }

function M.Random_Agent:program(percept)
    return u.random_choice(self.actions)
end

return M
