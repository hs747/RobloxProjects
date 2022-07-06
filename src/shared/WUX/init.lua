-- fuck fusion and roact, all my homies hate state management
local Source = script

return {
	-- core functionality
	Component = require(Source.Component),
	New = require(Source.New),
	Children = require(Source.Instance.Children),
	OnEvent = require(Source.Instance.OnEvent),
	TweenOn = require(Source.Instance.TweenOn),
	
	-- util
	Tween = require(Source.Util.Tween),
	MenuGroup = require(Source.Util.MenuGroup),
}