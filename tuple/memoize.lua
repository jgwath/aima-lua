--------------------------------------------------------------------------------
-- Creates a memoize table that caches the results of a function.               
--                                                                              
-- Creates a table that caches the results of a function that accepts a single                                                                        
-- argument and returns a single value.                                         
--                                                                              
-- @param func Function which returned values must be cached.                   
-- @param weak [optional] String used to define the weak mode of the created table.                                                                  
--                                                                              
-- @return Memoize table created.                                               
--                                                                              
-- @usage SquareRootOf = loop.table.memoize(math.sqrt)                          
                                                                                
local function memoize(func, weak)                                                    
        return setmetatable({}, {                                               
                __mode = weak,                                                  
                __index = function(self, input)                                 
                        local output = func(input)                              
                        if output ~= nil then                                   
                                rawset(self, input, output)                     
                        end                                                     
                        return output                                           
                end,                                                            
        })                                                                      
end 

return {["memoize"] = memoize}
