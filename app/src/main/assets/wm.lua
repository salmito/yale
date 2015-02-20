if luajava then
  local wm=require'wm.android'
  return wm
else
  local wm=require'wm.sdl'
  return wm
end