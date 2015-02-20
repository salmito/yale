local gl = require'gl'
local buffer=require'lib.buffer'.newBuffer
local ffi

if pcall(require,'ffi') then
  ffi=require'ffi'
end

local function validate(shader)
    local int = buffer('int',1,{0})
    gl.glGetShaderiv( shader, gl.GL_COMPILE_STATUS, int )
    if int[0] == gl.GL_TRUE then
        return true
    else
        print( "Shader Compliler: Unable to compile shader.")

        gl.glGetShaderiv( shader, gl.GL_INFO_LOG_LENGTH, int )
        if int[0] <= 0 then
            return true
        end
        if ffi then
            local buffer = ffi.new( "char[?]", int[0]+1 )
            gl.glGetShaderInfoLog( shader, int[0], int, buffer )
            err=ffi.string(buffer)
        else
          err=gl.glGetShaderInfoLog(shader)
        end
        print( "Shader Compiler Error:"..err)
        error( "Exiting due to shader errors:" ..err)
    end
end


local function create(src,type)
  print(type)
    local shader=gl.glCreateShader(type)
    if shader==0 then
        error( "Unable to Create Shader Object: glGetError: " .. gl.glGetError())
        return 0
    end
    if ffi then 
      local tsrc = ffi.new( "char["..(string.len(src)+1).."]", src )
      local srcs = ffi.new( "const char*[1]", tsrc )
      gl.glShaderSource(shader, 1, srcs, nil )
    else 
      gl.glShaderSource(shader, src)--1, srcs, nil )
    end
    gl.glCompileShader(shader)
    validate(shader)
    return shader
end

local function compile(vShader, fShader)
    local vs = create( vShader, gl.GL_VERTEX_SHADER )
    local fs = create( fShader, gl.GL_FRAGMENT_SHADER )

    local prog = gl.glCreateProgram()

    gl.glAttachShader( prog, vs )
    gl.glAttachShader( prog, fs )

    gl.glLinkProgram( prog )
    gl.glUseProgram( prog )

    return vs,fs,prog
end

local function genBuffer()
    local bufId = buffer('int',1,{0})
    gl.glGenBuffers(1, bufId)
    print('buf',bufId[0])
    return bufId[0]
end

local function genFramebuffer()
    local bufId = buffer('int',1,{0})
    gl.glGenFramebuffers(1, bufId)
    print('framebuf',bufId[0])
    return bufId[0]
end

local function genRenderbuffer()
    local bufId = buffer('int',1,{0})
    gl.glGenRenderbuffers(1, bufId)
    print('renderbuf',bufId[0])
    return bufId[0]
end

local function genTexture()
    local bufId = buffer('int',1,{0})
    gl.glGenTextures(1, bufId)
    print('texture',bufId[0])
    return bufId[0]
end


local function createTarget(width, height)

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
}