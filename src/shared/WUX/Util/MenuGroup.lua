-- a component which shares multiple guis
-- only allows one menu to be open at a time
-- has callbacks and stuff
local Component = require(script.Parent.Parent.Component)

local MenuGroup = Component(function(self)
	self.menus = {}
	self.currentOpen = nil
end)

function MenuGroup:open(menu)
	if self.current and not (self.current == menu) then
		self.current:close()
	end
	self.current = menu
	return menu:open()
end

function MenuGroup:close()
	if self.current then
		return self.current:close()
	end
end

return MenuGroup