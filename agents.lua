
require "object"
require "utils"

-- Since we already have an 'Object' class, just re-use it.
--[[
function Object:repr()
    return self.name
end
]]--

-- don't really need is_alive() because nil is also false

-- Agent class
function prompt_program(percept)
    io.write("Percept=%s; action? ":format(percept))
    return io.read()
end

Agent = Object { alive = true, program = prompt_program }

function TraceAgent(agent)
    old_program = agent.program
    function new_program(percept)
        local action = old_program(percept)
        printf("%s perceives %s and does %s\n", agent, precept, action)
        return action
    end
    agent.program = new_program
    return agent
end
