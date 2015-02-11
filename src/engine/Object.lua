local class=require'Class'

local Object=class(function(o)
end)

function Object:__gc()
  self:finish()
end

function Object:__tostring()
  return "Object: "--addr
end

function Object:prerender()
end

function Object:render()
end

function Object:finish()
end

return Object