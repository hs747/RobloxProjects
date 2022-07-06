local Component = {}
Component.__index = Component

function Component.new(interface)
	local self = setmetatable(interface, Component)
end

function Component:destroy()
	if self.instance then
		self.instance:Destroy()
	end
end

function Component:mount(parent: Instance)
	if self.instance then
		self.instance.Parent = parent
	end
end

return function(constructor)
	local tab = {}
	tab.__index = tab
	setmetatable(tab, {
		__index = Component,
		__call = function(...) 
			local self = setmetatable({}, tab)
			return constructor(self, ...)
		end
	})	
	return tab
end

--[==[ 	
example syntax:

local button = Component(function(self, ...) 
	self.instance = make some stuff
end)

function button:update()
	...
end

function button:mount()
	...
end

]==]