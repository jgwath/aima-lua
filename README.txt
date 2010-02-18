
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
the AIMA book.

----------------------------------------------------------------------

LICENSE and COPYRIGHT: 

	Code is Copyright (c) 2010 by James Graves (ansible@xnet.com).

	All code in this project is released under the MIT License.

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

	modules
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

----------------------------------------------------------------------

Library Usage:

To use a library module, you will need to assign it to a local
variable like this:

	local agents = require "agents"

	... 

	myagent2 = agents.TraceAgent(myagent1)

You may of course name the module whatever you want in the local
namespace.  So this is equivalent to the above:

	local A = require "agents"

	... 

	myagent2 = A.TraceAgent(myagent1)

We are not using the Lua module() function, so it is always necessary
to use an assignment as shown above.

Please see the Lua wiki for the rationale behind this approach:

    http://lua-users.org/wiki/LuaModuleFunctionCritiqued

----------------------------------------------------------------------

Sites to visit:

http://www.lua.org			The Lua Programming Language
http://www.lua-users.org		Lua wiki and mailing list
http://aima.cs.berkeley.edu/		AIMA Book website
http://luaforge.net/projects/stdlib/	Reuben Thomas' stdlib project

