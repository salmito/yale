local class=require'Class'
local Object=require'Object'

local gl  = require'gl'

local table=require'table'
local wm=require'wm.sdl'

local Window=class(Object,function(self,name,width,height)
    Object.init(self)
    wm:init(width, height)
    self.name=name
    self.wm=wm
    self:setSize(width,height)
    self.objects={}
    gl.glClearColor ( 0.0, 0.0, 0.0, 0.0 )
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
  self.wm:exit()
end

function Window:setTitle(title,iconTitle)
    --self.handle.setCaption(title,iconTitle)
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
end

function Window:on(tp,f)
  self.wm:on(tp,f)
end

function Window:loop()
  while self.wm:update() do
    self:prerender()
    self:render()
    self.wm:flip()
  end
end

return Window
