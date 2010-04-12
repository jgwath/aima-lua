#!/usr/bin/env lua

local A = require "aima.agents"

-- Simple test of table-driven agents.

print("Table Driven agent:")
local hist = { [{ 1, 2 }] = "foo",
               [{ 1, 3 }] = "bar",
               [{ 3 }] = "baz3",
               [{ 2 }] = "baz2",
               [{ 1 }] = "baz1" }

agent2 = A.Simple_Table_Driven_Agent{ "agent2", hist }
agent2 = A.Trace_Agent(agent2)

action = agent2:program(1)  -->  returns "baz1"
action = agent2:program(2)  -->  returns "foo"
action = agent2:program(3)  -->  returns nil

