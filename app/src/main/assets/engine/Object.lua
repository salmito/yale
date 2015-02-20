local class=require'engine.Class'

local Object=class(function(o,f)
    if f then f(o) end
end)

Object.Class=class

function Object:__gc()
  self:finish()
end

function Object:__tostring()
  return "Object"
end

function Object:prerender()
end

function Object:render()
end

function Object:finalize()
end

return Object