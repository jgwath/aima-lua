
require "object"
require "io"
require "string"

local _M = {} -- Will contain all exported functions.

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

_M.Table_Driven_Agent = _M.Agent { _init = { "percept_table" }, percepts = {}}

return _M
