if luajava then
  local gl=luajava.bindClass('android.opengl.GLES20')
  local cache={}

  local function getCache(_,name)
    if cache[name] then return cache[name] end
    if type(gl[name])=='function' then
      cache[name]=function(...)
        local ret=gl[name](gl,...)
        local glErr=tonumber(gl:glGetError())
        local err=(glErr ~= gl.GL_NO_ERROR)
        if err then
            print(name,err,glErr)
            error("OpengGL Error")
        end
        print(err)
        return ret
      end
      return cache[name]
    end
    return gl[name]
  end

  return setmetatable({},{__index=getCache})
elseif pcall(require,'ffi') then
  local ffi=require'ffi'
  local gl=require( "lib.ffi.OpenGLES2")
  local cache={}
  local function getCache(_,name)
    if cache[name] then return cache[name] end
    if type(gl[name])=='cdata' then
        print(name,gl[name],type(gl[name]))
      cache[name]=function(...)
        local ret=gl[name](...)
        print((tonumber(gl.glGetError()) == tonumber(gl.GL_NO_ERROR)))
        assert(tonumber(gl.glGetError()) == tonumber(gl.GL_NO_ERROR),"OpenGL ES2 error: "..gl.glGetError().." "..gl.GL_NO_ERROR)
        return ret
      end
      return cache[name]
    end
    return gl[name]
  end 
  return setmetatable({},{__index=getCache})
end
