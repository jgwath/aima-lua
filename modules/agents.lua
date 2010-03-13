
require "object"  -- injects Object from stdlib into globals
require "io"
require "string"
local p = require "python_compat"

local M = {} -- Will contain all exported functions.

M.Object = Object

function M.Object:__tostring() return self.name or "Object" end

-- Agent class
M.Agent = Object { _init = { "name" }, alive = true }

function M.Agent:prompt_program(percept)
    io.write(string.format("Percept=%s; action? ", percept))
    return io.read()
end


-- TODO : should this really be a part of the environment?
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

    AIMA3e, Figure 2.7, page 47

    First version is a simple table match against the entire
    history of the percepts.  See below for a more useful 
    version of this.

    For example use refer to chapter/2/table_driven_agent.lua .

]]--

--[[
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
                                        percept_history = {} }
                                          
function M.Simple_Table_Driven_Agent:program(percept)
    table.insert(self.percept_history, percept)
    for i, v in pairs(self.percept_lookup) do
        if p.list_compare(i, self.percept_history) then return v end
    end
    -- else return nil
end


--[[
    Table Driven Agent / Simple Reflex Agent

    This will be somewhat of a divergence from the book.  A table driven agent 
    that can only look at the entire history of percepts isn't very
    useful.  However, doing a lookup based on N number of recent percepts is
    much more feasable, and might actually be useful.
    
    The previous percepts can be stored in a tree, with a single percept
    the link between nodes, and actions at the nodes.


    An small example history tree:

        [[1] = 'a', [2] = 'b']
        \_____________________'x'___[[1] = 'c', [2] = 'd', [3] = 'f']
         \
          \___________________'y'___[[1] = 'd', [2] = 'g']
                                    \
                                     \_______'z'___[[1] = 'e']
                                      \
                                       \_____'y'___[[1] = 'f']

    So if the current percept doesn't match 'x' or 'y', then we will
    choose either 'a' or 'b' as the action.

    If the current percept is 'x', then we will choose either 'c', 'd'
    or 'f' as the action.

    If the current percept is 'y', then we will look at the previous
    percept.  If that was again 'y', then 'f' is the action.  If it
    was 'z', then 'e' is the action.  And if it was neither of those, then we
    will choose 'd' or 'g' as the action.

    So we're just trying to do a best match based on the percepts, weighted
    towards what we've seen most recently.  Going further into the tree is 
    refining what the agent does, but it can take action based on just the
    current percept too.

    The action tree will get hard to specify for longer sequences, in
    the sense that the actions specified further into the tree still
    correspond to the percepts at the root of the tree too.

    A better way of specifying this is desired.  For instance, taking a
    list of percept sequences (going forward in time) and an action, and
    then inverting those as they are being insterted into a tree.
        
    To Use:
        ag1 = Table_Driven_Agent {"my_ag1", tree, 3}

]]--

--[[
    Simple Reflex Agent

    AIMA3e, Figure 2.10, page 49

    The simple reflex agent is a special case of the table driven agent
    with only one level of percepts.
]]--

M.Table_Driven_Agent = M.Agent { _init = { "name", "depth", "lookup_tree" }, 
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
            -- This works because the percepts are not integer indices.
            return p.random_choice(node)
        end
    end
end


--[[
    Random Agent
]]--
M.Random_Agent = M.Agent { _init = {"name", "actions"} }

function M.Random_Agent:program(percept)
    return p.random_choice(self.actions)
end


--[[
    Model Based Reflex Agent

    AIMA3e, Figure 2.12, page 51
]]--

return M
