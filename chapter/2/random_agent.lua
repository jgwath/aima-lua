#!/usr/bin/env lua

local A = require "aima.agents"

print("Random Agent:")
agent4 = A.Random_Agent{"agent4", {"foo", "bar", "baz"}}
agent4 = A.Trace_Agent(agent4)

action = agent4:program(1)
action = agent4:program(1)
action = agent4:program(2)
action = agent4:program(3)
