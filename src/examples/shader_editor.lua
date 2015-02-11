local gl  = require( "gl")
local sdl = require( "ffi/sdl" )
local ffi = require( "ffi" )

local Window=require'Window'
local Object=require'Object'
local Program=require'Program'

local shader=require'framework.glutils'
local buffer=shader.genBuffer()

local bufferData=ffi.new('float[12]',{- 1.0, - 1.0, 1.0, - 1.0, - 1.0, 1.0, 1.0, - 1.0, 1.0, 1.0, - 1.0, 1.0})
local shaders=require'examples.shaders'
local curShader=0


local function compile(fragment)
  local vertex='attribute vec3 position; void main() { gl_Position = vec4( position, 1.0 ); }'

  local currentProgram = Program(vertex,fragment,{'time','mouse','resolution'},{'position'});
  currentProgram:use()

  -- Set up buffers
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, buffer);
  gl.glVertexAttribPointer( currentProgram:getAttr('position'), 3, gl.GL_FLOAT, gl.GL_FALSE, 0, bufferData )

  return currentProgram
end

local width,height=1024,768

local surface=Window("Main",width,height,false)

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


local main=Object(function(self)
    gl.glEnable(gl.GL_BLEND)
    gl.glBindBuffer( gl.GL_ARRAY_BUFFER, buffer );
    gl.glBufferData( gl.GL_ARRAY_BUFFER,12, bufferData, gl.GL_STATIC_DRAW)
    self.frontTarget=shader.createTarget(width,height)
    self.backTarget=shader.createTarget(width,height)
    self.mouse={x=0,y=0}
    self.screenProgram = Program(vertex,fragment,{'resolution','texture'},{'position'})
    self.currentProgram=compile(shaders[1])
    self.lastTime=os.clock()
  end)

surface:on(sdl.SDL_VIDEORESIZE,function(evt)
    local w,h=evt.resize.w,evt.resize.h
    surface:setSize(w, h) 
    
    main.frontTarget=shader.createTarget(w,h)
    main.backTarget=shader.createTarget(w,h)
end)

surface:on(sdl.SDL_KEYDOWN,function(evt)
    if evt.key.keysym.scancode==sdl.SDL_SCANCODE_LEFT then
      main.lastTime=os.clock()
      if curShader==0 then curShader=#shaders-1 else curShader=curShader-1 end
      main.currentProgram=compile(shaders[curShader+1])
    elseif evt.key.keysym.scancode==sdl.SDL_SCANCODE_RIGHT then
      main.lastTime=os.clock()
      curShader=(curShader+1)%#shaders
      main.currentProgram=compile(shaders[curShader+1])
    end
  end)

surface:on(sdl.SDL_MOUSEMOTION,function(evt) 
    main.mouse.x=evt.motion.x
    main.mouse.y=evt.motion.y
end)

surface:on(sdl.SDL_WINDOWEVENT,function(evt) 
    surface:setSize(surface.width,surface.height)
end)



function main:render(surface)
    if not self.currentProgram then return end
    self.currentProgram:use()

    gl.glUniform1f(self.currentProgram:getUniform('time'), os.clock()-self.lastTime);
    gl.glUniform2f(self.currentProgram:getUniform('mouse'), self.mouse.x, self.mouse.y );
    gl.glUniform2f(self.currentProgram:getUniform('resolution'),surface.width, surface.height);

    gl.glActiveTexture( gl.GL_TEXTURE0 );
    gl.glBindTexture( gl.GL_TEXTURE_2D, self.backTarget.texture );
    gl.glBindFramebuffer( gl.GL_FRAMEBUFFER, self.frontTarget.framebuffer );

    gl.glClear( gl.GL_COLOR_BUFFER_BIT + gl.GL_DEPTH_BUFFER_BIT );
    gl.glDrawArrays( gl.GL_TRIANGLES, 0, 6 );

    -- Set uniforms for screen shader

    self.screenProgram:use();

    gl.glUniform2f(self.screenProgram:getUniform('resolution'), surface.width, surface.height);
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

surface:setTitle("Live shader editor","test")

surface:add(main)

surface:loop()
