local class=require'Class'
local Object=require'Object'

local gl  = require( "gl")
local egl = require( "ffi/egl" )

local table=require'table'
local wm=require'win.wm'

local Window=class(Object,function(self,name,width,height,fullscreen)
    Object.init(self)
    self.name=name
    self.handle=wm.InitSDL(width, height, fullscreen)
    self.fullscreen=fullscreen
    self.handle.eglInfo = wm.InitEGL(self.handle)	
    self.handle.runApp = self.handle:update()
    self.objects={}
    gl.glClearColor ( 0.0, 0.0, 0.0, 0.0 )
    self:setSize(width,height)
  end)

function Window:__tostring()
  return "Window: "..self.name
end

function Window:setSize(w,h)
  self.width=w
  self.height=h
  gl.glViewport( 0, 0, w, h);
end

function Window:finalize()
  self.handle:exit()
end

function Window:setTitle(title,iconTitle)
    self.handle.setCaption(title,iconTitle)
end

function Window:add(obj)
  assert(Object.is_a(obj,Object),"Value is not a object")
  table.insert(self.objects,obj)
end

function Window:remove(obj) 
  table.remove(self.objects,obj)
end

function Window:prerender() 
  for _,obj in ipairs(self.objects) do
    obj:prerender(self)
  end
end

function Window:render()
  for _,obj in ipairs(self.objects) do
    obj:render(self)
  end
  
  gl.glFinish()
  egl.eglSwapBuffers( self.handle.eglInfo.dpy, self.handle.eglInfo.surf )
end

function Window:on(tp,f)
  self.handle.on(tp,f)
end

function Window:loop()
  while self.handle:update() do
    self:prerender()
    self:render()
  end
end

return Window
