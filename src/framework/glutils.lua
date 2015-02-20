local ffi = require("ffi")
local gl  = require("ffi.OpenGLES2")

local function validate(shader)
  local int = ffi.new( "GLint[1]", 0 )
  gl.glGetShaderiv( shader, gl.GL_COMPILE_STATUS, int )
  if int[0] == gl.GL_TRUE then
    return true
  else
    print( "Shader Compliler: Unable to compile shader.")

    gl.glGetShaderiv( shader, gl.GL_INFO_LOG_LENGTH, int )
    if int[0] <= 0 then
      return true
    end

    local buffer = ffi.new( "char[?]", int[0]+1 )
    gl.glGetShaderInfoLog( shader, int[0], int, buffer )
    print( "Shader Compiler Error:"..ffi.string(buffer) )
    assert(true, "Exiting due to shader errors.")
  end
end


local function create(src,type)
  local shader=gl.glCreateShader(type)
  if shader==0 then
    print( "Unable to Create Shader Object: glGetError: " .. tonumber( gl.glGetError()) )
    return 0
  end

  local tsrc = ffi.new( "char["..(string.len(src)+1).."]", src )
  local srcs = ffi.new( "const char*[1]", tsrc )

  gl.glShaderSource( shader, 1, srcs, nil )
  gl.glCompileShader ( shader )
  print('shader',shader)
  validate(shader)
  return shader
end

local function compile(vShader, fShader)
  local vs = create( vShader, gl.GL_VERTEX_SHADER )
  local fs = create( fShader, gl.GL_FRAGMENT_SHADER )

  local prog = gl.glCreateProgram()
  print('aqui',vs,prog)
  gl.glAttachShader( prog, vs )
  gl.glAttachShader( prog, fs )

  gl.glLinkProgram( prog )
  gl.glUseProgram( prog )

  return vs,fs,prog
end

local uniformCache={}

local function getUniform(program,label)
  uniformCache[program] = uniformCache[program] or {}
  return uniformCache[program][label]
end

local function cacheUniform(program,label) 
  uniformCache[program] = uniformCache[program] or {}
  uniformCache[program][label]=gl.glGetUniformLocation(program,label)
end

local function genBuffer()
  local bufId = ffi.new("int[1]")
  gl.glGenBuffers(1, bufId)
  return bufId[0]
end

local function genFramebuffer()
  local bufId = ffi.new("int[1]")
  gl.glGenFramebuffers(1, bufId)
  return bufId[0]
end

local function genRenderbuffer()
  local bufId = ffi.new("int[1]")
  gl.glGenRenderbuffers(1, bufId)
  return bufId[0]
end

local function genTexture()
  local bufId = ffi.new("int[1]")
  gl.glGenTextures(1, bufId)
  return bufId[0]
end


local function createTarget( width, height ) 

  local target = {};

  target.framebuffer = genFramebuffer();
  target.renderbuffer = genRenderbuffer();
  target.texture = genTexture();

  -- set up framebuffer

  gl.glBindTexture( gl.GL_TEXTURE_2D, target.texture );
  gl.glTexImage2D( gl.GL_TEXTURE_2D, 0, gl.GL_RGBA, width, height, 0, gl.GL_RGBA, gl.GL_UNSIGNED_BYTE, nil);

  gl.glTexParameteri( gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP_TO_EDGE );
  gl.glTexParameteri( gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP_TO_EDGE );

  gl.glTexParameteri( gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_NEAREST );
  gl.glTexParameteri( gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_NEAREST );

  gl.glBindFramebuffer( gl.GL_FRAMEBUFFER, target.framebuffer );
  gl.glFramebufferTexture2D( gl.GL_FRAMEBUFFER, gl.GL_COLOR_ATTACHMENT0, gl.GL_TEXTURE_2D, target.texture, 0 );

  -- set up renderbuffer

  gl.glBindRenderbuffer( gl.GL_RENDERBUFFER, target.renderbuffer );

  gl.glRenderbufferStorage( gl.GL_RENDERBUFFER, gl.GL_DEPTH_COMPONENT16, width, height );
  gl.glFramebufferRenderbuffer( gl.GL_FRAMEBUFFER, gl.GL_DEPTH_ATTACHMENT, gl.GL_RENDERBUFFER, target.renderbuffer );

  -- clean up

  gl.glBindTexture( gl.GL_TEXTURE_2D, 0 );
  gl.glBindRenderbuffer( gl.GL_RENDERBUFFER, 0 );
  gl.glBindFramebuffer( gl.GL_FRAMEBUFFER, 0);

  return target;
end



return {
  validate=validate,
  create=create, 
  compile=compile,
  createTarget=createTarget,
  genBuffer=genBuffer,
  genTexture=genTexture,
  genFramebuffer=genFramebuffer,
  genRenderbuffer=genRenderbuffer,
  cacheUniform=cacheUniform,
  getUniform=getUniform
}