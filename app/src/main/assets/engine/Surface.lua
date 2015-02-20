local class=require'engine.Class'
local Object=require'engine.Object'
local table=require'table'
local gl = require'gl'

local wm=require'wm'

local Surface=class(Object,function(self,width,height,...)
    Object.init(self)
    wm:init(self,width, height,...)
    self:setSize(width,height)
    self.wm=wm
    self.objects={}
    gl.glClearColor ( 0.0, 1.0, 0.0, 0.0 )
end)

function Surface:__tostring()
    return "Surface: ("..self.width.."x"..self.height..")"
end

function Surface:setSize(w,h)
    self.width=w
    self.height=h
    gl.glViewport( 0, 0, w, h);
end

function Surface:finalize()
    self.wm:exit()
end

function Surface:setTitle(title,iconTitle)
end

function Surface:add(obj)
    assert(Object.is_a(obj,Object),"Value is not a object")
    table.insert(self.objects,obj)
end

function Surface:remove(obj)
    table.remove(self.objects,obj)
end

function Surface:prerender()
    for _,obj in ipairs(self.objects) do
        obj:prerender(self)
    end
end

function Surface:render()
    for _,obj in ipairs(self.objects) do
        obj:render(self)
    end
end

function Surface:on(tp,f)
    self.wm:on(tp,f)
end

function Surface:loop()
    return self.wm:loop()
end

return Surface