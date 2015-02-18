local class=require'Class'
local Object=require'Object'

local gl=require'gl'

local shader=require'framework.glutils'

local Program=class(Object,function(self,vertex,fragment,uniforms,attribs) 
    self.vs,self.fs,self.id=shader.compile(vertex,fragment)
    self.unif={}
    self.attr={}
    for _,u in ipairs(uniforms or {}) do
      self.unif[u]=gl.glGetUniformLocation(self.id,u)
    end
    for _,a in ipairs(attribs or {}) do
      self.attr[a] = gl.glGetAttribLocation(self.id, a);
      gl.glEnableVertexAttribArray(self.attr[a]);
    end
end)

function Program:getAttr(name)
  return self.attr[name]
end

function Program:getUniform(name)
  return self.unif[name]
end

function Program:use()
  return gl.glUseProgram(self.id)
end

function Program:setUniform(tp,uniform,...)
  local f=gl["glUniform"..tp]
  asset(type(f)=='function',"Invalid uniform type")
  f(self:getUniform(uniform),...)
end

function Program:finalize()
  return gl.glDeleteProgram(self.id)
end

return Program
