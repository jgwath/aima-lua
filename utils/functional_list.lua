 -- Functional List Library for Lua
 --
 -- @file    functional_list.lua
 -- @author  James Graves
 -- @date    2010/03/01
 --
 -- @brief   List functions from the Data.List library of Haskell.

--[[
    The MIT License

    Copyright (c) 2009, James Graves <ansible@xnet.com>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
]]--

local M = {} -- Will store exported objects.

--[[
    This library assumes that tables are used like arrays / lists.
    So for any table, the keys are integers starting with 1.

    Function names are taken from Data.List of Haskell.  Semantics
    are as close as possible to their Haskell counterparts.  However,
    the functions map(), filter(), zip() and unzip() are n-ary, meaning
    that they can take one or more lists as arguments.
    
    So Haskell functions like zipWith(), zipWith3(), zip4(), unzip5(), 
    etc. are not defined.
]]--


--[[
    zip_with_helper ()

    This is a generalized version of Haskell's zipWith, but instead
    of running a function and appending that result to the list of results
    returned, we instead call a helper function instead.

    So this function does most of the work for map(), filter(), and zip().

    result_helper may do a variety of things with the function to
    be called and the arguments.  The results, if any, are appended
    to the resutls_l table.
]]--
local function zip_with_helper(result_helper, ...)
     local results_l= {}
     local args = {...}     -- a table of the argument lists
     local args_pos = 1     -- position on each of the individual argument lists
     local have_args = true

     while have_args do
        local arg_list = {}
        for i, v in ipairs(args) do
            local a = nil
            a = v[args_pos]
            if a then
                arg_list[i] = a
            else
                have_args = false
                break
            end
        end
        if have_args then
            result_helper(arg_list, results_l)
        end
        args_pos = args_pos + 1
    end
                    
     return results_l
end


--[[
    zip([one or more tables])

    For the given tables, create a tuple (for Lua this means another table)
    that contains the first element of table1, table2, table3, etc.  The same
    for the second element of table1, table2, etc.

    The length of the output list is the length of the shortest of
    the input lists.  

    zip({1,2,3}, {4, 5, 6})   ->  {1, 4}, {2, 5}, {3, 6}
        
]]--

function M.zip(...)
    return zip_with_helper(
        function (arg_list, results_l)
            table.insert(results_l, arg_list)
        end,
        ...)
end


 --[[
    map(function, [one or more tables])

    Examples:
        function double(x) return x * 2 end
        function add(x,y) return x + y end

        map(double, {1,2,3})                -> {2,4,6}
        map(add, {1,2,3}, {10, 20, 30})     -> {11, 22, 33}

    This also implements the functionality of 
        zipWith, zipWith3, zipWith4, etc. 
    in Haskell.

    func() should be a function that takes as many
    arguments as tables provided.  map() returns a list of just the
    first return values from each call to func().
 ]]--

function M.map(func, ...)
    return zip_with_helper(
        function (arg_list, results_l)
            table.insert(results_l, func(unpack(arg_list)))
        end,
        ...)
end


 --[[
    filter(func, [one or more tables])

    Selects the items from the argument list(s), calls
    func() on that, and if the result is true, the arguments
    are appended to the results list.

    Note that if func() takes only one argument and one
    list of arguments is given, the result will be a table
    that contains the values from the argument list directly.

    If there are two or more argument lists, then the 
    result table will contain a list of lists of arguments that matched
    the condition implemented by func().

    Examples:
        function is_equal (x, y) return x == y end
        function is_even (x) return x % 2 == 0 end

        filter(is_even, {1,2,3,4}) -> {2,4}

        filter(is_equal, {10, 22, 30, 44, 40}, {10, 20, 30, 40})    -> {{10,10}, {30, 30}}

 ]]--

function M.filter(func, ...)
    return zip_with_helper(
        function (arg_list, results_l)
            local result = func(unpack(arg_list))
            if result then
                if #arg_list == 1 then
                    table.insert(results_l, arg_list[1])
                else
                    table.insert(results_l, arg_list)
                end
            end
        end,
        ...)
end


 --[[
    tail(table)

    Return the list starting at the second list item.

    Note that this makes a shallow copy of the list,
    and does not modify the original list itself.
    If the original list is length 1 or less, this returns an empty
    table instead of nil because that seemed more useful.

    Example:
        tail({1,2,3})  ->  {2,3}
 ]]--
function M.tail(list)
    local newlist = {}
    if #list > 1 then
        for i = 2, #list do
            newlist[i - 1] = list[i]
        end
    end
    return newlist
end


 --[[
    foldr() - list fold right, with initial value

    foldr(function, default_value, table)

    Example:
        function mul(x, y) return x * y end
        function div(x, y) return x / y end

        foldr(mul, 1, {1,2,3,4,5})  ->  120
        foldr(div, 2, {35, 15, 6})  ->  7
 ]]--
function M.foldr(func, val, tbl)
    for i = #tbl, 1, -1 do
        val = func(tbl[i], val)
    end
    return val
end


--[[
    foldr1() - list fold right

    foldr(function, list)

    Example:
        function add(x, y) return x + y end

        foldr1(add, {1,2,3,4})  ->  10
]]--
function M.foldr1(func, tbl)
    return M.foldr(func, tbl[1], M.tail(tbl))
end


--[[
    foldl() - list fold left with initial value

    Example:
        foldl(div, 120, {2, 3, 5})  ->  4
]]--
function M.foldl(func, val, tbl)
    for i, v in ipairs(tbl) do
        val = func(val, v)
    end
    return val
end


--[[
    foldl1() - list fold left

    Example:
        foldl1(div, {120, 2, 3, 5})  ->  4
]]--
function M.foldl1(func, tbl)
    return M.foldl(func, tbl[1], M.tail(tbl))
end


--[[
    unzip()

    For example:

        If given a single table of tables, it unzips
        then and returns a single table of tables:

        unzip({{10, 20, 30}, {40, 50, 60}})  -> {{10, 40}, {20, 50}, {30, 60}}

    Other uses:

        This is an n-ary function, so if given multiple tables as
        arguments, these are unzipped and returned as multiple tables
        (and not a single table of tables):

        two tables of three items:      return three tables of two:
        unzip({1, 2, 3}, {4, 5, 6})  -> {1, 4}, {2, 5}, {3, 6}

    Notes:
        This also implements the Data.List function transpose when
        given just one list of lists.

]]--
function M.unzip(...)
    local tables = {...}
    local result_tables = {}
    local multi_return = #tables > 1

    if not multi_return then
        tables = tables[1]  -- Given a table of tables, so unzip that.
    end

    for rowidx, row_val in ipairs(tables) do
    	for colidx, col_val in ipairs(row_val) do
            if rowidx == 1 then
                result_tables[colidx] = {}
            end
            result_tables[colidx][rowidx] = col_val
        end
    end

    if multi_return then
        return unpack(result_tables)
    else
        return result_tables
    end
end
M.transpose = M.unzip


--[[
    reverse()

    Returns a shallow copy of the items in the list, in 
    reverse order.

    Example:
        reverse({1, 2, 3, 4})  ->  {4, 3, 2, 1}
]]--
function M.reverse(tbl)
    local new_tbl = {}
    local tbl_len = #tbl
    for i, v in ipairs(tbl) do
        new_tbl[tbl_len + 1 - i] = v
    end
    return new_tbl
end


--[[
    intersperse()

    Inserts an item in between each previously existing item of a list.

    Example:
        intersperse(9, {1, 2, 3, 4})   ->  {1, 9, 2, 9, 3, 9, 4}
]]--
function M.intersperse(item, tbl)
    local new_tbl = {}
    for i, v in ipairs(tbl) do
        table.insert(new_tbl, v)
        if i ~= #tbl then
            table.insert(new_tbl, item)
        end
    end
    return new_tbl
end


--[[
    take()

    Returns a shallow copy of the first N items of the given list.

    Example:
        take(3, {1, 2, 3, 4, 5})  -> {1, 2, 3}
]]--
function M.take(n, tbl)
    local new_tbl = {}
    for i, v in ipairs(tbl) do
        if i <= n then
            new_tbl[i] = v
        else
            break
        end
    end
    return new_tbl
end


--[[
    drop()

    Returns a shallow copy of the list without the first N items.

    Example:
        drop(3, {1, 2, 3, 4, 5})  -> {4, 5}
]]--
function M.drop(n, tbl)
    local new_tbl = {}
    for i, v in ipairs(tbl) do
        if i > n then
            table.insert(new_tbl, v)
        end
    end
    return new_tbl
end


--[[
    concat_single(tbl)

    Helper for n-ary concat() below.
]]--
local function concat_single(tbl)
    local new_tbl = {}
    for i, sublist in ipairs(tbl) do
        for j, item in ipairs(sublist) do
            table.insert(new_tbl, item)
        end
    end
    return new_tbl
        
end


--[[
    concat()

    Takes a list of lists, and return a single list with all the elements.

    If given multiple lists as arguments, combine each of the list
    contents into a single list.

    Examples (note the different table nesting):
        concat({{1, 2}, {{10, 20}, {30, 40}}})  -> {1, 2, {10, 20}, {30, 40}}
        
        concat({1, 2}, {{10, 20}, {100, 200}})  -> {1, 2, {10, 20}, {100, 200}}
]]--
function M.concat(...)
    local args = {...}     -- a table of the argument lists
    if #args == 1 then
        return concat_single(args[1])
    else
        return concat_single(args)
    end
end


--[[
    and()

function and(tbl)
    return foldr(operator.and, true, tbl)
end
]]--

return M
