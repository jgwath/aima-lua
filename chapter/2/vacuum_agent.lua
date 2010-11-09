
local A = require "aima.agents"

--[[

    Simple_Table_Driven_Vacuum_Agent

    AIMA3e, Chapter 2, Figure 2.3, page 36

    Percept Sequence                        Action

    [A, Clean]                              Right
    [A, Dirty]                              Suck
    [B, Clean]                              Left
    [B, Dirty]                              Suck

    [A, Clean], [A, Clean]                  Right
    [A, Clean], [A, Dirty]                  Suck

    [A, Clean], [A, Clean], [A, Clean]      Right
    [A, Clean], [A, Clean], [A, Dirty]      Suck
]]--

--[[
    Table_Driven_Vacuum_Agent

    Not in the book.

]]--

--[[

    Reflex_Vacuum_Agent

    AIMA3e, Chapter 2, Figure 2.8, page 48
]]--


