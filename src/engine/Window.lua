local class=require'Class'
local Object=require'Object'
local Program=require'Program'
local gl  = require( "gl")
local egl = require( "ffi/egl" )
local sdl = require( "ffi/sdl" )
local ffi=require'ffi'

local shaders=require'test.shaders'
local curShader=0

local shader=require'framework.shader'
local wm=require'win.wm'

local buffer=shader.genBuffer()
local bufferData=ffi.new('float[12]',{- 1.0, - 1.0, 1.0, - 1.0, - 1.0, 1.0, 1.0, - 1.0, 1.0, 1.0, - 1.0, 1.0})

local function compile(fragment)
  local vertex='attribute vec3 position; void main() { gl_Position = vec4( position, 1.0 ); }'

  local currentProgram = Program(vertex,fragment,{'time','mouse','resolution'},{'position'});
  currentProgram:use()

  -- Set up buffers
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, buffer);
  gl.glVertexAttribPointer( currentProgram:getAttr('position'), 3, gl.GL_FLOAT, gl.GL_FALSE, 0, bufferData )

  return currentProgram
end

local Window=class(Object,function(self,name,width,height,fullscreen)
    Object.init(self,name)
    self.name=name
    self.wm=wm
    self.handle=wm.InitSDL(width, height, fullscreen)
    self.width=width
    self.height=height
    self.fullscreen=fullscreen
    self.handle.eglInfo = wm.InitEGL(self.handle)	
    self.handle.runApp = self.handle:update()
    gl.glClearColor ( 1.0, 0.5, 0.0, 0.0 )
    gl.glEnable(gl.GL_BLEND)
    self:setSize(width,height)
    gl.glBindBuffer( gl.GL_ARRAY_BUFFER, buffer );
    gl.glBufferData( gl.GL_ARRAY_BUFFER,12, bufferData, gl.GL_STATIC_DRAW)


    self.frontTarget=shader.createTarget(width,height)
    self.backTarget=shader.createTarget(width,height)

    local fragment = [[#ifdef GL_ES
			precision highp float;
			#endif

			uniform vec2 resolution;
			uniform sampler2D texture;

			void main() {

				vec2 uv = gl_FragCoord.xy / resolution.xy;
				gl_FragColor = texture2D( texture, uv );
			}
    ]]
    local vertex = [[attribute vec3 position;
			void main() {
				gl_Position = vec4( position, 1.0 );

			}
    ]]

    --local vs,fs,program=shader.compile(vertex,fragment)

    self.screenProgram = Program(vertex,fragment,{'resolution','texture'},{'position'})

    self.currentProgram=compile(shaders[1])

    self:on(sdl.SDL_VIDEORESIZE,function(evt) self:setSize(evt.resize.w, evt.resize.h) end)
    self:on(sdl.SDL_KEYDOWN,function(evt) 
        if evt.key.keysym.scancode==sdl.SDL_SCANCODE_LEFT then
          if curShader==0 then curShader=#shaders-1 else curShader=curShader-1 end
          self.currentProgram=compile(shaders[curShader+1])
        elseif evt.key.keysym.scancode==sdl.SDL_SCANCODE_RIGHT then
          curShader=(curShader+1)%#shaders
          self.currentProgram=compile(shaders[curShader+1])
        end
      end)
      print("Window started: ",self.name)
    end)

  function Window:__tostring()
    return "Window: "..self.name
  end

  function Window:setSize(w,h)
    self.width=w
    self.height=h
    self.frontTarget=shader.createTarget(w,h)
    self.backTarget=shader.createTarget(w,h)

    gl.glViewport( 0, 0, w, h);
    print('Window size',w,h)
  end

  function Window:finish()
    self.handle:exit()
  end

  function Window:prerender() 
    if not self.currentProgram then return end
    self.currentProgram:use()

    for k,v in pairs(self.handle.KeyDown) do
      if v.sym == 99 then

      end
    end

    gl.glUniform1f(self.currentProgram:getUniform('time'), os.clock());
    gl.glUniform2f(self.currentProgram:getUniform('mouse'), self.handle.MouseMove.x, self.handle.MouseMove.y );
    gl.glUniform2f(self.currentProgram:getUniform('resolution'),self.width, self.height);

    gl.glActiveTexture( gl.GL_TEXTURE0 );
    gl.glBindTexture( gl.GL_TEXTURE_2D, self.backTarget.texture );
    gl.glBindFramebuffer( gl.GL_FRAMEBUFFER, self.frontTarget.framebuffer );

    gl.glClear( gl.GL_COLOR_BUFFER_BIT + gl.GL_DEPTH_BUFFER_BIT );
    gl.glDrawArrays( gl.GL_TRIANGLES, 0, 6 );

    -- Set uniforms for screen shader

    self.screenProgram:use();

    gl.glUniform2f(self.screenProgram:getUniform('resolution'), self.width, self.height);
    gl.glUniform1i(self.screenProgram:getUniform('texture'), 1 );

    gl.glBindBuffer( gl.GL_ARRAY_BUFFER, buffer );

    gl.glVertexAttribPointer( self.screenProgram:getAttr('position'), 2, gl.GL_FLOAT, false, 0, bufferData );
    gl.glEnableVertexAttribArray( self.screenProgram:getAttr('position') );

    gl.glActiveTexture(gl.GL_TEXTURE1 );
    gl.glBindTexture(gl.GL_TEXTURE_2D, self.frontTarget.texture);

    -- Render front buffer to screen

    gl.glBindFramebuffer( gl.GL_FRAMEBUFFER, 0);

    gl.glClear( gl.GL_COLOR_BUFFER_BIT + gl.GL_DEPTH_BUFFER_BIT );
    gl.glDrawArrays( gl.GL_TRIANGLES, 0, 6 );

    self.frontTarget,self.backTarget=self.backTarget,self.frontTarget
  end

  function Window:render()
    gl.glFinish()
    egl.eglSwapBuffers( self.handle.eglInfo.dpy, self.handle.eglInfo.surf )
  end

  function Window:on(tp,f)
    self.handle.on(tp,f)
  end

  return Window('Main window',1280,720,false)
