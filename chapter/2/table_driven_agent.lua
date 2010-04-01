#!/usr/bin/env lua

local A = require "aima.agents"

-- Simple test of table-driven agents.

local hist = { [{ 1, 2 }] = "foo",
               [{ 1, 3 }] = "bar",
               [{ 3 }] = "baz3",
               [{ 2 }] = "baz2",
               [{ 1 }] = "baz1" }

agent2 = A.Simple_Table_Driven_Agent{ "agent2", hist }

agent3 = A.Trace_Agent(agent2)

print("1:")
print(agent3:program(1))  -->  returns "baz1"
print("2:")
print(agent3:program(2))  -->  returns "foo"
print("3:")
print(agent3:program(3))  -->  returns nil
print("agent3:", agent3)
