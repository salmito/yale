local buffer=luajava.bindClass('java.nio.ByteBuffer')
local order=luajava.bindClass('java.nio.ByteOrder')

local sizes={
    ['int']=4
}

local bufmt={
    __index=function(buf,i)
        return buf:get(i)
    end,
    __newindex=function(buf,i,v)
        buf:put(i,v)
    end
}

local function newBuffer(tp,size,t)
    local buf
    if tp=='int' then
        local b=buffer:allocateDirect(size*sizes[tp]):order(order:nativeOrder()):asIntBuffer()
        buf=setmetatable(b,bufmt)
    else
        error('invalid buffer type')
    end
    if buf and t then
        for i=1,#t do
            b[i]=t[i]
        end
    end
    return buf
end

return {
    new=newBuffer
}
