local _VERSION="0.1.0prealpha"

do --init package info
package.path 		= package.path..";src\\?.lua;src\\engine\\?.lua;src\\lib\\?.lua;"

print(package.path)
print(package.cpath)

end
return require'examples.shader_editor'
