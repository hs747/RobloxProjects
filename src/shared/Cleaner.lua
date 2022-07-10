-- waffle's clone of maid
local cleaner = {}
cleaner.__index = cleaner

local function clean(object: Cleanable)
	if typeof(object) == "Instance" then
		pcall(object.Destroy, object)
	elseif typeof(object) == "RBXScriptConnection" then
		pcall(object.Disconnect, object)
	elseif type(object) == "table" and cleaner:_isCleaner(object) then
		pcall(object.clean, object)
	end
end

function cleaner.new(): Cleanable
	local self = setmetatable({}, cleaner)
	self._items = {}
	self._isCleaning = false
	return self
end

function cleaner:_isCleaner(object: any)
	return getmetatable(object) == cleaner
end

function cleaner:add(object: Cleanable)
	table.insert(self._items, object)
	return self -- for add chaining
end

function cleaner:clean(verbose)
	-- don't clean if a cleaner chain loops
	if self._isCleaning then
		return
	end
	self._isCleaning = true
	for _, object in ipairs(self._items) do
		if verbose then
			print("Cleaning:", object, "Type:", typeof(object))
		end
		clean(object)
	end
end

-- type decls
export type Cleaner = typeof(cleaner.new())
type Cleanable = Instance | RBXScriptConnection | Cleaner

return cleaner