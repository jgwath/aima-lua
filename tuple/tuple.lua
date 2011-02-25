-- Project: Lua Tuple
-- Release: 1.0 alpha
-- Title  : Internalized Tokens that Represent a Tuple of Values
-- Author : Renato Maia <maia@inf.puc-rio.br>


local _G = require "_G"
local select = _G.select
local tostring = _G.tostring

local table = require "table"
local concat = table.concat
local unpacktab = unpack

local oo = require "loop.base"
local class = oo.class

module(...)

local WeakKeys = class{__mode="k"}



-- from a tuple to its values (weak mode == "k")
local ParentOf = WeakKeys()
local ValueOf = WeakKeys()
local SizeOf = WeakKeys()
local fake_nil = {}

function unpack_tuple(tuple)
	local values = {}
	local size = SizeOf[tuple]
	for i = size, 1, -1 do
        local val
		tuple, val = ParentOf[tuple], ValueOf[tuple]
        if val ~= fake_nil then
            values[i] = val
        end
	end
	return unpacktab(values, 1, size)
end

function size(tuple)
	return SizeOf[tuple]
end



-- from values to a tuple (weak mode == "kv")
local Tuple = class{__mode="kv", __len=size}

function Tuple:__index(value)
	local tuple = Tuple()
	ParentOf[tuple] = self
	ValueOf[tuple] = value
	SizeOf[tuple] = SizeOf[self]+1
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

index = Tuple() -- main tuple that represents the empty tuple
SizeOf[index] = 0

-- find a tuple given its values
function create(...)
	local tuple = index
	for i = 1, select("#", ...) do
        local val = select(i, ...)
        if val == nil then
            val = fake_nil
        end
		tuple = tuple[val]
	end
	return tuple
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
