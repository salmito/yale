if luajava then
  local buffer=luajava.bindClass('java.nio.ByteBuffer')
  local order=luajava.bindClass('java.nio.ByteOrder')

  local sizes={
    ['int']=4,
    ['float']=4,
    ['double']=8,
    ['int64']=8
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
    elseif tp=='float' then
        local b=buffer:allocateDirect(size*sizes[tp]):order(order:nativeOrder()):asFloatBuffer()
        buf=setmetatable(b,bufmt)
    else
      error('invalid buffer type')
    end
    if buf and t then
      for i=1,#t do
        buf[i-1]=t[i]
      end
    end
    return buf
  end

  return {
    newBuffer=newBuffer
  }
elseif pcall(require,'ffi') then
  local ffi=require'ffi'
  local function newBuffer(tp,size,t)
    return ffi.new(tp..'['..size..']',t)
  end
  return {
    newBuffer=newBuffer
  }
end