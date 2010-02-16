
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

return _M
