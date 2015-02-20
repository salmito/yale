--
-- Created by IntelliJ IDEA.
-- User: Tiago
-- Date: 19/02/2015
-- Time: 15:54
-- To change this template use File | Settings | File Templates.
--
local gl=luajava.bindClass('android.opengl.GLES20')

local cache={}

local function getCache(_,name)
    if cache[name] then return cache[name] end
    if type(gl[name])=='function' then
        cache[name]=function(...)
            return gl[name](gl,...)
        end
        return cache[name]
    end
    return gl[name]
end

return setmetatable({},{__index=getCache})

