
--[[
    Project: Lua Tuple
    Release: 1.1
    Title  : Internalized Tokens that Represent a Tuple of Values
    Authors: Renato Maia <maia@inf.puc-rio.br>, James Graves <ansible@xnet.com>

]]--

require "table"
local class = require("loop.base").class

local _M = {}  -- exported functions

local WeakKeys   = class{__mode="k"}
local WeakValues = class{__mode="v"}
local WeakTable  = class{__mode="kv"}

-- from a tuple to values (weak mode == "kv")
local ParentOf   = WeakTable()
local ValueOf    = WeakTable()
local SizeOf     = WeakKeys()

local UseTrapOf     -- trap to be collected when a tuple is not used (see below)
local UseMarkOf     = WeakKeys() -- mark that a tuple uses its parent
local UseTrapCnt    -- number of available/freed usetraps (see 'clearpools')
local UseTrapPool   -- list of available/freed usetraps (see 'clearpools')


--[[
    simple_memoize()

    Creates a memoize table that caches the results of a function.

    Creates a table that caches the results of a function that accepts a
    single argument and returns a single value.

    @param func Function which returned values must be cached.                   
    @param weak [optional] String used to define the weak mode of the created table.                                                                  
    @return Memoize table created.                                               

    @usage SquareRootOf = loop.table.memoize(math.sqrt)                          

    Author: Renato Maia <maia@inf.puc-rio.br>
]]--
                                                                                
local function simple_memoize(func, weak)                                                    
        return setmetatable({}, {                                               
            __mode  = weak,                                                  
            __index = function(self, input)                                 
                local output = func(input)                              
                if output ~= nil then                                   
                    rawset(self, input, output)                     
                end                                                     
                return output                                           
            end,                                                            
        })                                                                      
end 


local function unpack_tuple(tuple)
	local values = {}
	local size = SizeOf[tuple]
	for i = size, 1, -1 do
		tuple, values[i] = ParentOf[tuple], ValueOf[tuple]
	end
	return unpack(values, 1, size)
end


local function tuple_size(tuple)
	return SizeOf[tuple]
end


-- free all resources of a tuple if it is not used anymore
local function free_tuple(tuple)
	while next(tuple) == nil do -- no [value]=subtuple nor [map]=usetrap
		local usetrap = UseTrapOf[tuple]
		if usetrap then
			UseTrapOf[tuple] = nil
			UseTrapCnt = UseTrapCnt + 1
			UseTrapPool[UseTrapCnt] = usetrap
		end
		local value = ValueOf[tuple]
		ValueOf[tuple] = nil
		if tuple ~= index then SizeOf[tuple] = nil end
		UseMarkOf[tuple] = nil
		tuple, ParentOf[tuple] = ParentOf[tuple], nil
		if tuple == nil then break end
		if value ~= nil then tuple[value] = nil end
	end
end

local function unused(trap)
	local tuple = getmetatable(trap).tuple
	if tuple ~= nil then -- the tuple was not collected yet
		free_tuple(tuple)
	end
end

-- traps that are collected when the tuple is not used anymore
UseTrapOf = simple_memoize(function(tuple)
	local trap
	if UseTrapCnt == 0 then
		trap = newproxy(true)
		local meta = getmetatable(trap)
		WeakValues(meta) -- allow that value of field 'tuple' be collected
		meta.tuple = tuple
		meta.__gc = unused -- won't be collected because it is a local function
	else
		trap = UseTrapPool[UseTrapCnt]
		UseTrapPool[UseTrapCnt] = nil
		UseTrapCnt = UseTrapCnt-1
		getmetatable(trap).tuple = tuple
	end
	return trap
end, "kv")



-- from values to a tuple (weak mode == "k")
local Tuple = class{__mode = "k", __len = tuple_size}

function Tuple:__index(value)
	local tuple = Tuple()
	ParentOf[tuple] = self
	ValueOf[tuple] = value
	SizeOf[tuple] = SizeOf[self]+1
	UseMarkOf[tuple] = UseTrapOf[self] -- avoid collection of parent's usetrap
	self[value] = tuple
	return tuple
end

function Tuple:__call(i)
	if i == nil then return unpack_tuple(self) end
	local size = SizeOf[self]
	if i == "#" then return size end
	if i > 0 then i = i-size-1 end
	if i < 0 then
		for _ = 1, -i-1 do
			self = ParentOf[self]
		end
		return ValueOf[self]
	end
end

function Tuple:__tostring()
	local values = {}
	for i = SizeOf[self], 1, -1 do
		self, values[i] = ParentOf[self], tostring(ValueOf[self])
	end
	return "<"..concat(values, ", ")..">"
end

-- main tuple that represents the empty tuple
index = Tuple()
SizeOf[index] = 0

-- find a tuple given its values
function create(...)
	local tuple = index
	for i = 1, select("#", ...) do
		tuple = tuple[select(i, ...)]
	end
	return tuple
end



local EntryTrapCnt -- number of available/freed entrytraps
local EntryTrapPool -- list of available/freed entrytraps

-- called when the *weak value* of a map entry is collected
local function entrytrap(self)
	self = self.__index
	self.__gc = nil -- metafields should not interfere in the interation below
	self.__index = nil
	self.__newindex = nil
	for tuple, map in pairs(self) do
		tuple[map] = nil -- tuple not used in this map, usetrap may become garbage
	end
end

local function newentrytrap()
	local trap
	if EntryTrapCnt == 0 then
		trap = newproxy(true)
		local meta = getmetatable(trap)
		WeakKeys(meta) -- allow that trapped tuple be collected
		meta.__gc = entrytrap
		meta.__index = meta -- easy/fast access to table
		meta.__newindex = meta -- easy/fast access to table
	else
		trap = EntryTrapPool[EntryTrapCnt]
		EntryTrapPool[EntryTrapCnt] = nil
		EntryTrapCnt = EntryTrapCnt-1
	end
	return trap
end

local function freeentry(trapof, map, tuple, value)
	local trap = trapof[value]
	trap[tuple] = nil -- remove tuple from list of entries to be removed by trap
	for tuple, val in pairs(trap.__index) do
		if val == map then return end -- used for other entries with same 'value'
	end -- free trap to be reused later
	trapof[value] = nil
	EntryTrapCnt = EntryTrapCnt+1
	EntryTrapPool[EntryTrapCnt] = trap
end



local Collectable = {
	["function"] = true,
	table = true,
	thread = true,
	userdata = true,
}

local EntryTrapsOf = simple_memoize(function(map)
	local meta = getmetatable(map)
	if meta then
		local mode = meta.__mode
		if mode and mode:find("v", 1, true) then
			return simple_memoize(newentrytrap, "k") -- use entry GC traps
		end
	end
	return false
end, "k")

function setkey(map, tuple, value)
	local trap = EntryTrapsOf[map]
	if trap then
		local old = map[tuple]
		if old ~= nil and Collectable[type(old)] then
			freeentry(trap, map, tuple, old)
		end
	end
	map[tuple] = value
	if value == nil then
		tuple[map] = nil -- allow collection of usetrap if tuple not used anymore
	else
		tuple[map] = UseTrapOf[tuple] -- avoid collection of usetrap of tuple
		if trap and Collectable[type(value)] then
			trap[value][tuple] = map -- setup an EntryTrap for this entry (tuple)
		end
	end
end

function getkey(map, tuple)
	local value = map[tuple]
	if value == nil then free_tuple(tuple) end
	return value
end



function clearpools()
	UseTrapCnt = 0
	UseTrapPool = {}
	EntryTrapCnt = 0
	EntryTrapPool = {}
end

clearpools()

function emptystate()
	return (next(ParentOf) == nil)
	   and (next(ValueOf) == nil)
	   and (next(SizeOf) == index and next(SizeOf, index) == nil)
	   and (next(UseTrapOf) == nil)
	   and (next(UseMarkOf) == nil)
	   and (next(index) == nil)
	
	or (function()
		local Viewer = require "loop.debug.Viewer"
		Viewer:print("ParentOf ", ParentOf)
		Viewer:print("ValueOf  ", ValueOf)
		Viewer:print("SizeOf   ", SizeOf)
		Viewer:print("UseTrapOf", UseTrapOf)
		Viewer:print("UseMarkOf", UseMarkOf)
		Viewer:print("index    ", index)
	end)()
end

function emptystate()
	return (_G.next(ParentOf) == nil)
	   and (_G.next(ValueOf) == nil)
	   and (_G.next(SizeOf) == index and _G.next(SizeOf, index) == nil)
	   and (_G.next(index) == nil)
	
	--or (function()
	--	local Viewer = _G.require "loop.debug.Viewer"
	--	Viewer:print("ParentOf ", ParentOf)
	--	Viewer:print("ValueOf  ", ValueOf)
	--	Viewer:print("SizeOf   ", SizeOf)
	--	Viewer:print("index    ", index)
	--end)()
end

