print('starting main script',...)

local gl = require'gl'

local Program=require'engine.Program'

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

local p=Program(vertex,fragment,{'resolution','texture'},{'position'})
print('created program',p)
