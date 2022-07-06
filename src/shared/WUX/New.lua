-- --!strict

-- constructor function for instances
-- core of this library as it allows for faster in-script ui development (*cough* rojo & git *cough*)

local Source = script.Parent
local Dictionary = require(Source.Internal.Dictionary)
local Types = require(Source.Internal.Types)
local Tween = require(Source.Util.Tween)

local CHILDREN_PROPERTY = require(script.Parent.Instance.Children)
local PARENT_PROPERTY = "Parent"
local INSTANCE_TYPE = "Instance"
local TABLE_TYPE = "table"
local FUNCTION_TYPE = "function"
local STRING_TYPE = "string"

local function applyEvent(instance: Instance, eventName: string, input: (any)|Types.SpecialEventCallback)
	if typeof(input) == INSTANCE_TYPE then
		if input:IsA("Tween") then
			(instance :: Instance)[eventName]:Connect(function() 
				input:Play()
			end)
		end
	elseif type(input) == TABLE_TYPE then
		if input.onEventSpecial == Dictionary.SpecialEvent.Tween then
			local tween = Tween(instance, input.tweenInfo, input.tweenGoal)
			instance[eventName]:Connect(function() 
				tween:Play()
			end)
		end
	elseif type(input) == FUNCTION_TYPE then
		(instance:: any)[eventName]:Connect(input)
	end
end

local function applyProperty(instance: Instance, propertyName: string, propertyValue: any)
	(instance :: any)[propertyName] = propertyValue
end

local function applySpecial(instance: Instance, propertyName: string|Types.SpecialProperty, propertyValue)
	if propertyName.propertySpecial == Dictionary.SpecialProperty.OnEvent then
		local succ, err = pcall(applyEvent, instance, propertyName.eventName, propertyValue)
		if not succ then
			error(("Can't assign callback to event: %s. Reason %s."):format(tostring(propertyName.eventName), err))
		end
	end
end

local function construct(className: string, properties: {[any]: any})
	-- create rblx instance
	local instance
	local succ, instance = pcall(Instance.new, className)
	if not succ then
		error(("Can't create instance of classname: %s. Reason: %s"):format(className, instance))
	end
	-- apply properties
	for propertyName, propertyValue in pairs(properties) do
		if propertyName == CHILDREN_PROPERTY or propertyName == PARENT_PROPERTY then
			continue
		end
		if type(propertyName) == TABLE_TYPE and propertyName.propertySpecial then
			applySpecial(instance, propertyName, propertyValue)
		end
		-- apply as a normal property
		if type(propertyName) == STRING_TYPE then
			local succ, err = pcall(applyProperty, instance, propertyName, propertyValue)
			if not succ then
				error(("Classname: %s can't apply property: %s with value: %s. Reasion: %s"):format(className, propertyName, propertyValue, err))
			end
		end
	end
	-- parent children to instance
	if properties[CHILDREN_PROPERTY] then
		for _, child in ipairs(properties[CHILDREN_PROPERTY]) do
			if typeof(child) == INSTANCE_TYPE then
				child.Parent = instance
			end
		end
	end
	-- last, apply parent to instance
	if properties[PARENT_PROPERTY] then
		instance.Parent = properties[PARENT_PROPERTY]
	end
	
	return instance
end

return function(className) 
	return function(properties) 
		return construct(className, properties)
	end
end