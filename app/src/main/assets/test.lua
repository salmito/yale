print('starting tests 3')

local gl = require'gl'

print('gl',type(gl.glEnable),type(gl.GL_BLEND))
gl.glEnable(gl.GL_BLEND)
gl.glClearColor(0.0, 0.0, 1.0, 1.0);
print('ok')