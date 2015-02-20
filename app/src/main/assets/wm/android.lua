local callbacks={}

local function init(self, surface, width, height)
    self.surface=surface
end

local function loop(self)
    return
end

local function on(self,tp,f)

end


return {
    init=init,
    loop=loop,
    on=on
}