
			     aima-lua

Lua implementation of algorithms from Norvig And Russell's "Artificial
Intelligence - A Modern Approach", 3rd Ed.

----------------------------------------------------------------------

This is a project to create Lua implementations of all the algorithms
and exercises for the Stuart Russell and Peter Norvig book "Artificial
Intelligence - A Modern Approach" 3rd edition.

One of the main goals is for the code to be clear and elegant as
possible, while taking advantage of Lua's unique capabilities.

Another goal is to produce Lua code nicely modularized so that it can
readily be incorporated into other projects.

DISCLAIMER: This project is not officially sanctioned by the authors of
the book. It is intended to be a learning exercise and a (hopefully)
good example of Lua coding practices.

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

	examples
		Example code using the library, following the chapter
		structure of the book.

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

----------------------------------------------------------------------

Sites to visit:

http://www.lua.org			The Lua Programming Language
http://www.lua-users.org		Lua wiki and mailing list
http://aima.cs.berkeley.edu/		AIMA Book website
http://luaforge.net/projects/stdlib/	Reuben Thomas' stdlib project

----------------------------------------------------------------------

All code in this project is released under the MIT License.

