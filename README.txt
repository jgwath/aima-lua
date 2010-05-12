
			     aima-lua

Lua implementation of algorithms from Norvig And Russell's "Artificial
Intelligence - A Modern Approach", 3rd Ed.

----------------------------------------------------------------------

This is a project to create Lua implementations of all the algorithms
and exercises for the Stuart Russell and Peter Norvig book "Artificial
Intelligence - A Modern Approach", 3rd edition.

One of the main goals is for the code to be clear and elegant as
possible, while taking advantage of Lua's unique capabilities.  This
project is a learning exercise and a (hopefully) good example of Lua
coding practices.

Another goal is to produce Lua code nicely modularized so that it can
readily be incorporated into other projects.

----------------------------------------------------------------------

DISCLAIMER: This project is not officially sanctioned by the authors of
the AIMA3e book.

----------------------------------------------------------------------

LICENSE and COPYRIGHT: 

	Code is Copyright (c) 2010 by James Graves (ansible@xnet.com).

	All code in this project is released under the MIT License.
	Please see the COPYRIGHT file for details.

----------------------------------------------------------------------

Requirements:

Lua 5.1:
	http://www.lua.org

	Or you can just install Lua via your operating system's
	package manager.

Reuben Thomas's stdlib:

	http://luaforge.net/projects/stdlib/

	For the object module, getopt, etc.

----------------------------------------------------------------------

Directory structure:

	aima
		The main library codebase.

		Generally speaking, this will be code that might be of
		use to other projects.  Strong emphasis will be on
		producing clean and clear module interfaces and good
		documentation for this code.  When algorithms are
		developed over the course of a chapter, only the final
		version will be represented here.

		Eventually, divergent implements of the AIMA book
		concepts will be implemented, where they provide
		significant benefits over the book's algorithms.

	chapter
		
		The subdirectories correspond to the chapters of the
		AIMA book.  These will contain runnable scripts that
		demonstrate the algorithms being presented in the
		book.

		The example programs will try to follow the pseudocode
		of the book as closely as possible, and use the main
		library code where possible.

		When algorithms are being developed over the course of
		a chapter, the earlier versions will appear here.

		Exercise solutions will also be located here.

		If you are working your way through the AIMA book,
		start right here in chapter/2.

	aima/utils
		Utility libraries.

	docs
		General documentation of the library, as well as other
		documents like coding style.

	extras
		Example programs, and other fun stuff not directly
		related to the AIMA3e book.  This will contain
		extended examples of AI use in games.

----------------------------------------------------------------------

Library Usage:

You will need to add the aima-lua directory to your LUA_PATH environment
variable.  For example, if /bin/bash is your command shell:

	# ... other LUA_PATH elements ...
	export LUA_PATH+=";/path/to/aima-lua/?.lua"

In your Lua code, to use a library module, you will need to assign it to
a local variable like this:

	local agents = require "aima.agents"
	local PC = require "aima.utils.python_compat"

	-- Now use something from the agents module.
	myagent2 = agents.Random_Agent(percept_table)

	-- now use python_compat
	door = PC.random_choice(door_list)

Please see docs/coding_style.txt for more information on module
declarations.

----------------------------------------------------------------------

Sites to visit:

http://aima.cs.berkeley.edu/		AIMA Book website
http://www.lua.org			The Lua Programming Language

http://www.lua-users.org		Lua wiki and mailing list
http://luaforge.net/projects/stdlib/	Reuben Thomas' stdlib project

