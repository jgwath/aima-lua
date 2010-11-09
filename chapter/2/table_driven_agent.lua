#!/usr/bin/env lua

local U = require "aima.utils.basic"
local A = require "aima.agents"

-- Simple test of table-driven agents.

print("Table Driven agent:")

local hist = { "buzz",
                x = { "foo" },
                y = { "bar", z = {"bingo"}, y = {"raffle"}}
                }

agent2 = A.Table_Driven_Agent{ "agent2", 2, hist }
agent2 = A.Trace_Agent(agent2)

percept_list = { "v", "x", "y", "y", "z", "x", "z", "y", "y", "x" }
for _, v in ipairs(percept_list) do
    action = agent2:program(v)
end

