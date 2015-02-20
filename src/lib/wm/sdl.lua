local ffi = require"ffi"
local egl = require"ffi.EGL"
local gl  = require"ffi.OpenGLES2"

local function init(self, width, height)
  self.init=false
  local sdl = require( "ffi.sdl" )
  self.width=width
  self.height=height
  local screen = sdl.SDL_SetVideoMode( width, height, 32, sdl.SDL_RESIZABLE )
  local wminfo = ffi.new( "SDL_SysWMinfo" )
  sdl.SDL_GetVersion( wminfo.version )
  sdl.SDL_GetWMInfo( wminfo )
  local systems = { "win", "x11", "dfb", "cocoa", "uikit" }
  local subsystem = tonumber(wminfo.subsystem)
  local wminfo = wminfo.info[systems[subsystem]]
  self.window = wminfo.window
  self.display = nil
  if systems[subsystem]=="x11" then
    display = wminfo.display
  end	      
  local event = ffi.new( "SDL_Event" )
  local prev_time, curr_time, fps = 0, 0, 0

  local callbacks={}

  local dpy,ctx, surf

  self.update=function()
    while sdl.SDL_PollEvent( event ) ~= 0 do
      if callbacks[event.type] then
        for _,f in ipairs(callbacks[event.type]) do f(event) end
      end
      if event.type == sdl.SDL_QUIT then
        egl.eglDestroyContext( dpy, ctx )
        egl.eglDestroySurface( dpy, surf )
        egl.eglTerminate( dpy )
        return false
      end
      if event.type == sdl.SDL_KEYUP and event.key.keysym.sym == sdl.SDLK_ESCAPE then
        event.type = sdl.SDL_QUIT
        sdl.SDL_PushEvent( event )
      end
    end
    return true
  end
  self.exit=function() sdl.SDL_Quit() end

  self.on = function(self,tp, f)
    callbacks[tp]=callbacks[tp] or {}
    callbacks[tp][#callbacks[tp]+1]=f
    print('Loading callback',tp,callbacks[tp])
  end

  --init egl
  if self.display == nil then
    self.display = egl.EGL_DEFAULT_DISPLAY
  end

  dpy      = egl.eglGetDisplay( ffi.cast("intptr_t", self.display ))
  local r        = egl.eglInitialize( dpy, nil, nil)
  print('wm.display/dpy/r', self.display, dpy, r)

  local cfg_attr = ffi.new( "EGLint[3]", egl.EGL_RENDERABLE_TYPE, egl.EGL_OPENGL_ES2_BIT, egl.EGL_NONE )
  local ctx_attr = ffi.new( "EGLint[3]", egl.EGL_CONTEXT_CLIENT_VERSION, 2, egl.EGL_NONE )

  local cfg      = ffi.new( "EGLConfig[1]" )
  local n_cfg    = ffi.new( "EGLint[1]"    )

  print('wm.window', self.window)

  local r0       = egl.eglChooseConfig(dpy, cfg_attr, cfg, 1, n_cfg )

  local c = cfg[0]

--  for i=0,10 do
--    if c[i]==egl.EGL_FALSE then break end
--    print(i,c[i])
--  end

  surf     = egl.eglCreateWindowSurface( dpy, cfg[0], self.window, nil )
  ctx      = egl.eglCreateContext(dpy, cfg[0], nil, ctx_attr )
  local r        = egl.eglMakeCurrent(dpy, surf, surf, ctx)
  print('surf/ctx', surf, r0, ctx, r, n_cfg[0])

  self.flip=function()
    gl.glFinish()
    egl.eglSwapBuffers(dpy, surf)
  end

  return self
end

return {init=init}

