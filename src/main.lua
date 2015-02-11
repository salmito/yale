local _VERSION="0.1.0prealpha"

do --init package info
package.path 		= package.path..";src\\?.lua;src\\engine\\?.lua;lua/?.lua;"

print(package.path)
print(package.cpath)

end

do --init display window
  --
  local display=require'Window'
  
  local Object=require'Object'
  
  --enter loop
  while display.handle:update() do
    display:prerender()
    --call objects
    display:render()
  end
  
end






