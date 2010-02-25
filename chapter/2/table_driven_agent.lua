local u = require "utilities"
local A = require "agents"


local hist = { [{ 1, 2 }] = "foo",
               [{ 1, 3 }] = "bar",
               [{ 3 }] = "baz3",
               [{ 2 }] = "baz2",
               [{ 1 }] = "baz1" }

agent2 = A.Simple_Table_Driven_Agent{ "agent2", hist }

print("1:")
print(agent2:program(1))  -->  returns "baz1"
print("2:")
print(agent2:program(2))  -->  returns "foo"
print("3:")
print(agent2:program(3))  -->  returns nil
print("agent2:")
tp(agent2)
