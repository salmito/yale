local callbacks = {}

local function init(self, surface, width, height, view)
    self.surface = surface
    self.view = view
    self.view:setWindowObject(self)
end

local function loop(self)
    --NOOP
end

local function fire(self, ev)
    if callbacks[ev.type] then
        for _,f in ipairs(callbacks[event.type]) do f(ev) end
    end
end

local function on(self, tp, f)
    callbacks[tp] = callbacks[tp] or {}
    callbacks[tp][#callbacks[tp] + 1] = f
    print('Loading callback', tp, callbacks[tp])
end

local function draw(self)
    self.surface:prerender()
    self.surface:render()
end


return {
    init = init,
    loop = loop,
    fire = fire,
    draw = draw,
    on = on,
    VIDEORESIZE = "VIDEORESIZE"
}